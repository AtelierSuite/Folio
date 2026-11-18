"""Plays recorded instruments from the local Logic Pro sound library, for the alarm sounds.

Reads Sampler (EXS) instruments, whose zones map key ranges onto frame ranges of one consolidated recording,
and single recorded notes, pitch-shifting either with cubic interpolation. Files are decoded with afconvert,
so any format Logic ships (ALAC, AIFF, PCM) works. Everything is mixed down to mono at 44.1 kHz.
"""

import array
import math
import os
import struct
import subprocess
import tempfile

LIBRARY = os.path.expanduser("~/Music/Logic Pro Library.bundle")
INSTRUMENTS = os.path.join(LIBRARY, "Plug-In Settings/Sampler")
SAMPLES = os.path.join(LIBRARY, "Samples")
IMPULSE_RESPONSES = os.path.join(LIBRARY, "Impulse Responses")
SAMPLE_RATE = 44100

_decoded = {}


def decode(path):
    """Returns the recording as mono float samples, decoded once and kept for later notes."""
    if path not in _decoded:
        if not os.path.exists(path):
            raise FileNotFoundError(f"The alarm sounds need Logic Pro's sound library: {path} is missing")
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as handle:
            wav_path = handle.name
        subprocess.run(["afconvert", "-f", "WAVE", "-d", f"LEF32@{SAMPLE_RATE}", "-c", "1", path, wav_path],
                       check=True)
        with open(wav_path, "rb") as handle:
            data = handle.read()
        os.remove(wav_path)
        position = 12
        while position < len(data):
            kind, size = data[position:position + 4], struct.unpack("<I", data[position + 4:position + 8])[0]
            if kind == b"data":
                samples = array.array("f")
                body = data[position + 8:position + 8 + size]
                samples.frombytes(body[:len(body) // 4 * 4])
                _decoded[path] = samples
                break
            position += 8 + size + (size & 1)
        else:
            raise ValueError(f"No audio data in {path}")
    return _decoded[path]


def key_number(name):
    """MIDI key for a note name such as C4 or F#5, with middle C as C4."""
    offsets = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
    letter, rest = name[0], name[1:]
    offset = offsets[letter]
    if rest.startswith("#"):
        offset, rest = offset + 1, rest[1:]
    elif rest.startswith("b"):
        offset, rest = offset - 1, rest[1:]
    return 12 * (int(rest) + 1) + offset


def lowpass(samples, cutoff):
    """A 4th-order Butterworth lowpass, as two cascaded biquads."""
    angle = 2 * math.pi * cutoff / SAMPLE_RATE
    cosine = math.cos(angle)
    for quality in (0.5411961, 1.3065630):
        alpha = math.sin(angle) / (2 * quality)
        b0 = b2 = (1 - cosine) / 2 / (1 + alpha)
        b1 = (1 - cosine) / (1 + alpha)
        a1, a2 = -2 * cosine / (1 + alpha), (1 - alpha) / (1 + alpha)
        x1 = x2 = y1 = y2 = 0.0
        output = [0.0] * len(samples)
        for index, value in enumerate(samples):
            result = b0 * value + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
            x2, x1, y2, y1 = x1, value, y1, result
            output[index] = result
        samples = output
    return samples


def shift(samples, semitones, limit=None):
    """Resamples to a new pitch with 4-point cubic Hermite interpolation. Raising the pitch first filters out
    whatever would land above the top of the audible band, which would otherwise fold back down as harsh,
    out-of-tune tones."""
    ratio = 2 ** (semitones / 12)
    if limit is not None:
        samples = samples[:int(limit * ratio) + 4]
    if ratio > 1.0001:
        samples = lowpass(samples, 0.45 * SAMPLE_RATE / ratio)
    count = len(samples)
    length = int((count - 3) / ratio)
    if limit is not None:
        length = min(length, limit)
    output = [0.0] * max(0, length)
    for index in range(len(output)):
        position = 1 + index * ratio
        whole = int(position)
        fraction = position - whole
        before, current, after, later = samples[whole - 1], samples[whole], samples[whole + 1], samples[whole + 2]
        slope_current = 0.5 * (after - before)
        slope_after = 0.5 * (later - current)
        difference = current - after
        weight = slope_current + difference
        curve = weight + difference + slope_after
        output[index] = ((curve * fraction - weight - curve) * fraction + slope_current) * fraction + current
    return output


def impulse_response(name):
    """A recorded room from Logic's Space Designer library, scaled to unit energy so a reverb's mix sets the
    level of the wet sound against the dry one."""
    samples = decode(os.path.join(IMPULSE_RESPONSES, name))
    energy = math.sqrt(sum(value * value for value in samples)) or 1
    return [value / energy for value in samples]


def normalized(samples):
    loudest = max((abs(value) for value in samples), default=0) or 1
    return [value / loudest for value in samples]


class Multisample:
    """A Logic Sampler instrument: zones choose the recording nearest the key, by velocity and round robin."""

    def __init__(self, instrument, recording):
        self.recording = os.path.join(SAMPLES, recording)
        self.groups, self.zones = [], []
        with open(os.path.join(INSTRUMENTS, instrument), "rb") as handle:
            data = handle.read()
        position = 0
        while position + 84 <= len(data):
            signature, size = struct.unpack("<II", data[position:position + 8])
            name = data[position + 20:position + 84].split(b"\0")[0].decode("latin-1")
            body = data[position + 84:position + 84 + size]
            kind = (signature >> 24) & 0x0F
            if kind == 1:
                self.zones.append({
                    "root": body[1], "fine": struct.unpack("b", body[2:3])[0], "low": body[6], "high": body[7],
                    "start": struct.unpack("<i", body[12:16])[0], "end": struct.unpack("<i", body[16:20])[0],
                    "group": struct.unpack("<i", body[88:92])[0]})
            elif kind == 2:
                self.groups.append({"name": name, "low": body[5], "high": body[6]})
            position += 84 + size

    def note(self, key, velocity=100, take=0, length=None):
        matches = []
        for zone in self.zones:
            group = self.groups[zone["group"]] if 0 <= zone["group"] < len(self.groups) else None
            if group and not group["low"] <= velocity <= group["high"]:
                continue
            if zone["low"] <= key <= zone["high"]:
                matches.append(zone)
        if not matches:
            raise ValueError(f"No zone for key {key} at velocity {velocity}")
        zone = matches[take % len(matches)]
        recording = decode(self.recording)[zone["start"]:zone["end"]]
        limit = int(length * SAMPLE_RATE) if length else None
        return shift(recording, key - zone["root"] - zone["fine"] / 100, limit)


class OneShot:
    """A single recorded note, pitch-shifted to other keys. Start and end pick one strike out of a longer
    recording, and the silence before the strike is trimmed so notes land on the beat."""

    def __init__(self, recording, root, start=0.0, end=None):
        self.recording = os.path.join(SAMPLES, recording)
        self.root = root
        self.start = start
        self.end = end

    def strike(self):
        samples = decode(self.recording)
        first = int(self.start * SAMPLE_RATE)
        last = int(self.end * SAMPLE_RATE) if self.end else len(samples)
        region = samples[first:last]
        threshold = 0.05 * max(abs(value) for value in region)
        onset = next(index for index, value in enumerate(region) if abs(value) > threshold)
        return region[max(0, onset - SAMPLE_RATE // 1000):]

    def note(self, key, velocity=100, take=0, length=None):
        limit = int(length * SAMPLE_RATE) if length else None
        return shift(self.strike(), (key if key is not None else self.root) - self.root, limit)
