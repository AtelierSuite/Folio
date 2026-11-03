#!/usr/bin/env python3
"""Synthesizes Folio's notification sounds: short, clean motifs named after Japanese nature.

Kept soft, short and professional in tone, so they suit a quiet meeting room.

Usage: python3 generate.py <output directory>

Writes one .caf (16-bit linear PCM, mono, 44.1 kHz) per sound, checked to peak below -1 dBFS once
decoded. IMA4 would be a quarter of the size, but its noise floor sits only 35 dB under these soft
tones and crackles like clipping. Pure standard library, seeded, so every run produces identical files.
Requires macOS for afconvert, and Logic Pro's sound library for the sampled Steinway in Hoshizora and Kiri.
"""

import array
import math
import os
import random
import struct
import subprocess
import sys
import tempfile
import wave

SAMPLE_RATE = 44100
ENCODING = "BEI16"
TAU = 2 * math.pi


def note(name):
    names = {"C": -9, "D": -7, "E": -5, "F": -4, "G": -2, "A": 0, "B": 2}
    letter, rest = name[0], name[1:]
    offset = names[letter]
    if rest.startswith("#"):
        offset, rest = offset + 1, rest[1:]
    elif rest.startswith("b"):
        offset, rest = offset - 1, rest[1:]
    return 440.0 * 2 ** ((offset + (int(rest) - 4) * 12) / 12)


LOGIC_LIBRARY = os.path.expanduser("~/Music/Logic Pro Library.bundle")
STEINWAY_INSTRUMENT = os.path.join(
    LOGIC_LIBRARY, "Plug-In Settings/Sampler/z_Legacy/Keyboard/Acoustic Piano/Steinway Grand Piano 2.exs")
STEINWAY_SAMPLES = os.path.join(LOGIC_LIBRARY, "Samples/z_Legacy/Keyboard/Steinway Piano_consolidated.caf")


class SampledPiano:
    """Plays Logic Pro's Steinway Grand from the local Logic library, which has to be installed.

    Reads the legacy EXS instrument directly: each zone names a velocity group, a key range, a root
    key and a frame range inside one consolidated CAF holding every note."""

    _shared = None

    @classmethod
    def shared(cls):
        if cls._shared is None:
            cls._shared = cls(STEINWAY_INSTRUMENT, STEINWAY_SAMPLES)
        return cls._shared

    def __init__(self, instrument_path, samples_path):
        if not os.path.exists(instrument_path) or not os.path.exists(samples_path):
            raise FileNotFoundError("The piano sounds need Logic Pro's Steinway Grand Piano sound library")
        self.samples_path = samples_path
        self.groups, self.zones = [], []
        with open(instrument_path, "rb") as handle:
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
        self.data_offset = self._data_offset()

    def _data_offset(self):
        with open(self.samples_path, "rb") as handle:
            handle.read(8)
            position = 8
            while True:
                header = handle.read(12)
                kind, size = header[:4], struct.unpack(">q", header[4:])[0]
                if kind == b"desc":
                    rate, format_id, flags, packet_bytes, _, channels, bits = struct.unpack(">d4sIIIII", handle.read(32))
                    if (rate, format_id, flags, packet_bytes, channels, bits) != (SAMPLE_RATE, b"lpcm", 0, 4, 2, 16):
                        raise ValueError("Unexpected sample format in the Steinway library")
                    handle.seek(size - 32, 1)
                elif kind == b"data":
                    return position + 12 + 4
                else:
                    handle.seek(size, 1)
                position += 12 + size

    def note(self, key, velocity):
        """Returns the note as mono samples, pitch-shifted from the nearest sampled key. The piano is
        stretch-tuned, about half a cent sharper per key above middle C, so that is taken back out
        to sit in tune with the synthesized pads."""
        for zone in self.zones:
            group = self.groups[zone["group"]] if 0 <= zone["group"] < len(self.groups) else None
            if (group and group["low"] <= velocity <= group["high"] and zone["low"] <= key <= zone["high"]
                    and "Dampers" not in group["name"] and "pedal" not in group["name"]):
                break
        else:
            raise ValueError(f"No Steinway zone for key {key} at velocity {velocity}")
        frames = zone["end"] - zone["start"]
        with open(self.samples_path, "rb") as handle:
            handle.seek(self.data_offset + zone["start"] * 4)
            raw = struct.unpack(f">{frames * 2}h", handle.read(frames * 4))
        mono = [(raw[index] + raw[index + 1]) / 65536 for index in range(0, len(raw), 2)]
        stretch = max(0, key - 60) * 0.5
        ratio = 2 ** ((key - zone["root"] - (zone["fine"] + stretch) / 100) / 12)
        shifted = []
        position = 0.0
        while position < len(mono) - 1:
            whole = int(position)
            fraction = position - whole
            shifted.append(mono[whole] * (1 - fraction) + mono[whole + 1] * fraction)
            position += ratio
        return shifted


class Track:
    def __init__(self, seconds):
        self.samples = [0.0] * int(seconds * SAMPLE_RATE)

    def __len__(self):
        return len(self.samples)

    def partial(self, start, frequency, amplitude, decay, attack=0.003, tremolo=None):
        """Adds a sine with a short linear attack, an exponential decay and an optional tremolo."""
        first = int(start * SAMPLE_RATE)
        length = min(len(self) - first, int(decay * 7 * SAMPLE_RATE))
        step = TAU * frequency / SAMPLE_RATE
        rate, depth = tremolo or (0.0, 0.0)
        for index in range(max(0, length)):
            time = index / SAMPLE_RATE
            envelope = min(1.0, time / attack) * math.exp(-time / decay)
            if depth:
                envelope *= 1 - depth * (0.5 - 0.5 * math.cos(TAU * rate * time))
            self.samples[first + index] += amplitude * envelope * math.sin(step * index)

    def finish(self, room=0.0, mix=0.0, damping=0.5, fade=0.15, delay=None, brightness=3000):
        samples = self.samples
        if delay:
            samples = echo(samples, *delay)
        if mix:
            wet = reverb(samples, room, damping)
            samples = [dry * (1 - mix * 0.5) + echo * mix for dry, echo in zip(samples, wet)]
        samples = lowpass(lowpass(highpass(samples, 150), brightness), brightness)
        samples = trim(samples)
        fade_length = int(fade * SAMPLE_RATE)
        for index in range(fade_length):
            samples[-1 - index] *= index / fade_length
        return level(samples)


def trim(samples, floor_decibels=-50.0, tail=0.12):
    """Cuts the file shortly after the sound has died away, so no sound trails on in silence."""
    threshold = max(abs(value) for value in samples) * 10 ** (floor_decibels / 20)
    last = max((index for index, value in enumerate(samples) if abs(value) > threshold), default=len(samples) - 1)
    return samples[:min(len(samples), last + int(tail * SAMPLE_RATE))]


def level(samples, target_decibels=-20.0, ceiling=0.8):
    """Matches perceived loudness across sounds, softly limiting peaks instead of clipping them.

    Loudness is measured with the treble lifted by about 4 dB, roughly like K-weighting,
    so brighter sounds are turned down to feel as loud as the mellow ones."""
    loudest = max(abs(value) for value in samples) or 1
    weighted = [value + 0.58 * treble for value, treble in zip(samples, highpass(samples, 1500))]
    power = math.sqrt(sum(value * value for value in weighted) / len(weighted)) or 1
    gain = min(10 ** (target_decibels / 20) / power, 1.6 * ceiling / loudest)
    knee = ceiling * 0.7

    def limit(value):
        magnitude = abs(value)
        if magnitude <= knee:
            return value
        squeezed = knee + (ceiling - knee) * math.tanh((magnitude - knee) / (ceiling - knee))
        return math.copysign(squeezed, value)

    return [limit(value * gain) for value in samples]


def lowpass(samples, cutoff):
    coefficient = 1 - math.exp(-TAU * cutoff / SAMPLE_RATE)
    previous = 0.0
    output = []
    for value in samples:
        previous += coefficient * (value - previous)
        output.append(previous)
    return output


def echo(samples, seconds, feedback, mix):
    """A soft feedback delay, darker on each repeat, for the synth-pop sparkle."""
    delay = int(seconds * SAMPLE_RATE)
    line = [0.0] * delay
    store = 0.0
    output = []
    for index, value in enumerate(samples):
        repeated = line[index % delay]
        store = 0.6 * repeated + 0.4 * store
        line[index % delay] = value + store * feedback
        output.append(value + repeated * mix)
    return output


def highpass(samples, cutoff):
    coefficient = 1 / (1 + TAU * cutoff / SAMPLE_RATE)
    previous_input = previous_output = 0.0
    output = []
    for value in samples:
        previous_output = coefficient * (previous_output + value - previous_input)
        previous_input = value
        output.append(previous_output)
    return output


def reverb(samples, room, damping):
    """Schroeder reverb: parallel damped combs into series allpasses."""
    scale = SAMPLE_RATE / 44100
    combs = [int(delay * scale) for delay in (1557, 1617, 1491, 1422, 1277, 1356)]
    feedback = 0.6 + 0.3 * room
    total = [0.0] * len(samples)
    for delay in combs:
        buffer = [0.0] * delay
        store = 0.0
        position = 0
        for index, value in enumerate(samples):
            out = buffer[position]
            store = out * (1 - damping) + store * damping
            buffer[position] = value + store * feedback
            position = (position + 1) % delay
            total[index] += out / len(combs)
    for delay in (225, 556, 441):
        buffer = [0.0] * delay
        position = 0
        output = []
        for value in total:
            buffered = buffer[position]
            result = -value + buffered
            buffer[position] = value + buffered * 0.5
            position = (position + 1) % delay
            output.append(result)
        total = output
    return total


class Instruments(Track):
    """A small, clean palette of tuned percussion and plucks, in the spirit of professional
    notification sounds. Sounds sharing a voice set its tone, from mellow (below 1) to bright (above 1),
    so each still has its own colour. Melodies sound an octave below their written pitch so they sit around
    250 Hz to 1 kHz, below the 2 to 4 kHz band where the ear is most sensitive."""

    @staticmethod
    def frequency(pitch):
        return note(pitch) / 2

    def bell(self, start, pitch, amplitude=1.0, decay=0.6, tone=1.0):
        """A clean glass bell: harmonic, crisply struck, with a brief glassy ping on top."""
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.002)
        self.partial(start, frequency * 2.0, amplitude * 0.22 * tone, decay * 0.45, attack=0.002)
        self.partial(start, frequency * 3.0, amplitude * 0.07 * tone, decay * 0.25, attack=0.002)
        self.partial(start, frequency * 5.4, amplitude * 0.05 * tone, decay * 0.05, attack=0.001)

    def glockenspiel(self, start, pitch, amplitude=1.0, decay=0.8):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.003)
        self.partial(start, frequency + 0.8, amplitude * 0.12, decay, attack=0.003)
        self.partial(start, frequency * 2.0, amplitude * 0.1, decay * 0.25, attack=0.003)
        self.partial(start, frequency * 3.0, amplitude * 0.03, decay * 0.12, attack=0.003)

    def celesta(self, start, pitch, amplitude=1.0, decay=0.6, tone=1.0):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.004)
        self.partial(start, frequency * 2.0, amplitude * 0.25 * tone, decay * 0.4, attack=0.004)
        self.partial(start, frequency * 3.0, amplitude * 0.08 * tone, decay * 0.25, attack=0.004)
        self.partial(start, frequency * 4.0, amplitude * 0.03 * tone, decay * 0.15, attack=0.004)

    def marimba(self, start, pitch, amplitude=1.0, decay=0.35, tone=1.0):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.003)
        self.partial(start, frequency * 3.93, amplitude * 0.35 * tone, decay * 0.35, attack=0.003)
        self.partial(start, frequency * 9.8, amplitude * 0.08 * tone, decay * 0.1, attack=0.002)

    def vibraphone(self, start, pitch, amplitude=1.0, decay=0.9, tone=1.0):
        """Bars tuned 1:4:10, with just a hint of the motor's tremolo."""
        frequency = self.frequency(pitch)
        tremolo = (5.5, 0.08)
        self.partial(start, frequency, amplitude, decay, attack=0.003, tremolo=tremolo)
        self.partial(start, frequency * 4.0, amplitude * 0.22 * tone, decay * 0.35, attack=0.003, tremolo=tremolo)
        self.partial(start, frequency * 10.0, amplitude * 0.04 * tone, decay * 0.1, attack=0.003)

    def piano(self, start, pitch, amplitude=1.0, velocity=100, hold=0.45, release=0.08):
        """A firmly struck Steinway grand note from Logic Pro's library, damped after it is held."""
        key = round(69 + 12 * math.log2(self.frequency(pitch) / 440))
        recording = SampledPiano.shared().note(key, velocity)
        loudest = max(abs(value) for value in recording) or 1
        first = int(start * SAMPLE_RATE)
        held = int(hold * SAMPLE_RATE)
        for index, value in enumerate(recording[:max(0, len(self) - first)]):
            damper = 1.0 if index < held else math.exp(-(index - held) / (release * SAMPLE_RATE))
            if damper < 1e-4:
                break
            self.samples[first + index] += amplitude * 0.8 * damper * value / loudest

    def kalimba(self, start, pitch, amplitude=1.0, decay=0.45, tone=1.0):
        """A thumb piano tine: a quick pluck with a short, woody overtone."""
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.003)
        self.partial(start, frequency * 2.0, amplitude * 0.3 * tone, decay * 0.6, attack=0.003)
        self.partial(start, frequency * 3.0, amplitude * 0.1 * tone, decay * 0.35, attack=0.003)
        self.partial(start, frequency * 5.9, amplitude * 0.25 * tone, decay * 0.1, attack=0.002)
        self.partial(start, frequency * 1.006, amplitude * 0.06, decay * 0.7, attack=0.003)

    def synth_pluck(self, start, pitch, amplitude=1.0, decay=0.45, tone=1.0):
        """A synth pluck: a detuned sawtooth whose filter closes as it decays."""
        frequency = self.frequency(pitch)
        for order in range(1, 9):
            for detune in (0.997, 1.003):
                level = amplitude * 0.5 / order * (tone if order > 1 else 1.0)
                self.partial(start, frequency * order * detune, level, decay / (1 + 0.9 * (order - 1)), attack=0.004)


def sequence(track, voice, notes, **options):
    for start, pitch in notes:
        voice(track, start, pitch, **options)


# Event sounds: short melodic motifs that announce something is starting.

def furin():
    """Wind Chime: glass bells climbing a C major ninth."""
    track = Instruments(2.0)
    sequence(track, Instruments.bell,
             ((0.0, "C6"), (0.1, "E6"), (0.2, "G6"), (0.3, "B6"), (0.4, "D7")), amplitude=0.6, decay=0.6, tone=1.3)
    return track.finish(room=0.25, mix=0.08, brightness=5000)


def asahi():
    """Sunrise: a marimba climbing a G major chord to a held high note."""
    track = Instruments(2.0)
    sequence(track, Instruments.marimba, ((0.0, "G5"), (0.09, "B5"), (0.18, "D6"), (0.27, "G6")), amplitude=0.8)
    track.marimba(0.42, "B6", 0.85, decay=0.6, tone=1.1)
    return track.finish(room=0.25, mix=0.08, brightness=4500)


def sakura():
    """Cherry Blossom: soft piano notes drifting down onto a G add9 chord."""
    track = Instruments(2.0)
    sequence(track, Instruments.piano, ((0.0, "E6"), (0.13, "D6"), (0.26, "B5"), (0.39, "G5")), amplitude=0.7,
             velocity=50, hold=0.6)
    for pitch in ("G5", "A5", "D6"):
        track.piano(0.62, pitch, 0.45, velocity=50, hold=0.8)
    return track.finish(room=0.4, mix=0.15, brightness=9000)


def uguisu():
    """Warbler: two bright grace-note leaps, then a high bell."""
    track = Instruments(1.8)
    for start, low, high in ((0.0, "D6", "G6"), (0.3, "D6", "B6")):
        track.bell(start, low, 0.35, decay=0.2, tone=0.9)
        track.bell(start + 0.05, high, 0.6, decay=0.4, tone=0.9)
    track.bell(0.6, "D7", 0.55, decay=0.6, tone=0.9)
    return track.finish(room=0.25, mix=0.08, brightness=5000)


def seseragi():
    """Brook: a kalimba rippling up and down an F major seventh."""
    track = Instruments(2.0)
    notes = ("F5", "A5", "C6", "E6", "G6", "E6", "C6", "E6")
    sequence(track, Instruments.kalimba, [(index * 0.08, pitch) for index, pitch in enumerate(notes)],
             amplitude=0.6)
    track.kalimba(0.68, "F6", 0.7, decay=0.6)
    track.kalimba(0.68, "C6", 0.4, decay=0.6)
    return track.finish(room=0.25, mix=0.08, brightness=4200)


def hoshizora():
    """Starry Sky: four piano notes twinkling across a D major seventh, ringing out in a large room."""
    track = Instruments(2.8)
    sequence(track, Instruments.piano, ((0.0, "A6"), (0.22, "E6"), (0.44, "B6"), (0.66, "F#6")), amplitude=0.6,
             hold=1.0, release=0.3)
    return track.finish(room=0.75, mix=0.35, brightness=9000)


def niji():
    """Rainbow: a quick synth pluck run up a C major scale, landing on a chord."""
    track = Instruments(1.8)
    notes = ("C6", "D6", "E6", "G6", "A6", "C7")
    sequence(track, Instruments.synth_pluck, [(index * 0.07, pitch) for index, pitch in enumerate(notes)],
             amplitude=0.5, tone=1.2)
    for pitch in ("E6", "G6"):
        track.synth_pluck(0.35, pitch, 0.25, decay=0.5, tone=1.2)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


def kumo():
    """Clouds: a vibraphone settling gently down an F major chord."""
    track = Instruments(2.0)
    sequence(track, Instruments.vibraphone, ((0.0, "C6"), (0.25, "A5"), (0.5, "F5")), amplitude=0.7, decay=0.7, tone=0.7)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


def nami():
    """Waves: a rolling marimba call and answer, settling on a long, ringing note."""
    track = Instruments(2.0)
    sequence(track, Instruments.marimba,
             ((0.0, "E6"), (0.13, "C6"), (0.26, "G5"), (0.52, "A5"), (0.65, "C6"), (0.78, "D6")),
             amplitude=0.8, tone=0.75)
    track.marimba(0.92, "E6", 0.85, decay=0.6, tone=0.75)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


def kaze():
    """Breeze: a light glockenspiel falling down an E major chord."""
    track = Instruments(1.8)
    sequence(track, Instruments.glockenspiel,
             ((0.0, "B6"), (0.12, "G#6"), (0.24, "E6"), (0.36, "C#6")), amplitude=0.5, decay=0.6)
    return track.finish(room=0.25, mix=0.08, brightness=4500)


# Reminder sounds: two or three notes, softer still, a gentle nudge.

def shizuku():
    """Dewdrop: two soft marimba notes, a fourth apart."""
    track = Instruments(1.0)
    sequence(track, Instruments.marimba, ((0.0, "B5"), (0.12, "E6")), amplitude=0.8, decay=0.25, tone=1.5)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


def hotaru():
    """Firefly: three vibraphone notes glowing up an E major chord."""
    track = Instruments(1.2)
    sequence(track, Instruments.vibraphone, ((0.0, "E6"), (0.1, "G#6"), (0.2, "B6")), decay=0.5, tone=1.3)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


def momiji():
    """Maple Leaf: a soft piano note falling, then a lighter one above, left to ring."""
    track = Instruments(2.0)
    sequence(track, Instruments.piano, ((0.0, "A5"), (0.16, "E5")), amplitude=0.7, velocity=50, hold=1.0,
             release=0.25)
    track.piano(0.4, "C#6", 0.55, velocity=50, hold=1.0, release=0.25)
    return track.finish(room=0.6, mix=0.28, brightness=9000)


def tsuki():
    """Moon: one calm glass bell chord of a fifth, with a faint octave."""
    track = Instruments(1.3)
    for pitch, amplitude in (("A5", 0.8), ("E6", 0.5), ("A6", 0.15)):
        track.bell(0.0, pitch, amplitude, decay=0.7, tone=0.6)
    return track.finish(room=0.25, mix=0.08, brightness=4500)


def kiri():
    """Morning Mist: a single, clear piano fifth."""
    track = Instruments(1.2)
    track.piano(0.0, "A5", 0.45, hold=0.5)
    track.piano(0.0, "E6", 0.6, hold=0.5)
    return track.finish(room=0.25, mix=0.08, brightness=9000)


def hamon():
    """Ripple: a single kalimba note with echoes spreading out."""
    track = Instruments(1.2)
    track.kalimba(0.0, "C6", decay=0.4, tone=0.7)
    return track.finish(room=0.25, mix=0.08, delay=(0.15, 0.3, 0.3), brightness=4000)


def suzu():
    """Little Bell: two small glass bells, high then a fourth below."""
    track = Instruments(1.0)
    sequence(track, Instruments.bell, ((0.0, "D7"), (0.09, "A6")), amplitude=0.7, decay=0.3, tone=1.6)
    return track.finish(room=0.25, mix=0.08, brightness=5000)


def hana():
    """Flower: a celesta opening up an A minor seventh."""
    track = Instruments(1.1)
    sequence(track, Instruments.celesta, ((0.0, "C6"), (0.09, "E6"), (0.18, "A6")), decay=0.45, tone=1.3)
    return track.finish(room=0.25, mix=0.08, brightness=4200)


def yuki():
    """Snow: three hushed celesta notes settling down a D major chord."""
    track = Instruments(1.2)
    sequence(track, Instruments.celesta, ((0.0, "F#6"), (0.16, "D6"), (0.32, "A5")), amplitude=0.7, decay=0.5, tone=0.6)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


def mejiro():
    """White-eye: a quick grace-note hop and a reply on a synth pluck."""
    track = Instruments(0.9)
    track.synth_pluck(0.0, "D6", 0.3, decay=0.15, tone=0.6)
    track.synth_pluck(0.04, "A6", 0.6, decay=0.3, tone=0.6)
    track.synth_pluck(0.2, "F#6", 0.55, decay=0.35, tone=0.6)
    return track.finish(room=0.25, mix=0.08, brightness=4000)


SOUNDS = {
    "Calendar-Furin": furin,
    "Calendar-Asahi": asahi,
    "Calendar-Sakura": sakura,
    "Calendar-Uguisu": uguisu,
    "Calendar-Seseragi": seseragi,
    "Calendar-Hoshizora": hoshizora,
    "Calendar-Niji": niji,
    "Calendar-Kumo": kumo,
    "Calendar-Nami": nami,
    "Calendar-Kaze": kaze,
    "Reminder-Shizuku": shizuku,
    "Reminder-Hotaru": hotaru,
    "Reminder-Momiji": momiji,
    "Reminder-Tsuki": tsuki,
    "Reminder-Kiri": kiri,
    "Reminder-Hamon": hamon,
    "Reminder-Suzu": suzu,
    "Reminder-Hana": hana,
    "Reminder-Yuki": yuki,
    "Reminder-Mejiro": mejiro,
}


def quantize(value, generator):
    """Rounds to 16 bits with triangular dither, so quiet tails fade into hiss instead of grain."""
    dither = generator.random() - generator.random()
    return int(max(-32768, min(32767, round(value * 32767 + dither))))


def write(samples, path):
    generator = random.Random(len(samples))
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as handle:
        wav_path = handle.name
    with wave.open(wav_path, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(b"".join(struct.pack("<h", quantize(value, generator)) for value in samples))
    subprocess.run(["afconvert", "-f", "caff", "-d", ENCODING, wav_path, path], check=True)
    os.remove(wav_path)


def decoded_peak(path):
    """Decodes the .caf back to float, as the device will, and returns its loudest sample."""
    with tempfile.NamedTemporaryFile(suffix=".caf", delete=False) as handle:
        float_path = handle.name
    subprocess.run(["afconvert", "-f", "caff", "-d", "LEF32", path, float_path], check=True)
    with open(float_path, "rb") as handle:
        data = handle.read()
    os.remove(float_path)
    position = 8
    while position < len(data):
        kind, size = data[position:position + 4], struct.unpack(">q", data[position + 4:position + 12])[0]
        if kind == b"data":
            body = data[position + 16:] if size < 0 else data[position + 16:position + 12 + size]
            samples = array.array("f")
            samples.frombytes(body[:len(body) // 4 * 4])
            return max(abs(value) for value in samples)
        position += 12 + size
    raise ValueError(f"No audio data in {path}")


def write_without_clipping(samples, path, ceiling_decibels=-1.0):
    """Turns the sound down until the decoded file stays below the ceiling, in case the encoding
    overshoots the source's peaks."""
    ceiling = 10 ** (ceiling_decibels / 20)
    for _ in range(10):
        write(samples, path)
        peak = decoded_peak(path)
        if peak <= ceiling:
            return peak
        samples = [value * ceiling / peak * 0.98 for value in samples]
    raise RuntimeError(f"{path} still peaks at {20 * math.log10(peak):.2f} dBFS")


def main():
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    only = set(sys.argv[2:])
    os.makedirs(output, exist_ok=True)
    for name, generator in SOUNDS.items():
        if only and name not in only:
            continue
        samples = generator()
        peak = write_without_clipping(samples, os.path.join(output, f"{name}.caf"))
        print(f"{name}: {len(samples) / SAMPLE_RATE:.2f}s, peak {20 * math.log10(peak):.2f} dBFS")


if __name__ == "__main__":
    main()
