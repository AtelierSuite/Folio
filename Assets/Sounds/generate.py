#!/usr/bin/env python3
"""Synthesizes Folio's notification sounds: bright synth-pop motifs named after Japanese nature.

Kept soft and short, with gentle attacks, so they suit a quiet meeting room.

Usage: python3 generate.py <output directory>

Writes one .caf (IMA4, mono, 44.1 kHz) per sound. Pure standard library, seeded,
so every run produces identical files. Requires macOS for afconvert.
"""

import math
import os
import struct
import subprocess
import sys
import tempfile
import wave

SAMPLE_RATE = 44100
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


class Track:
    def __init__(self, seconds):
        self.samples = [0.0] * int(seconds * SAMPLE_RATE)

    def __len__(self):
        return len(self.samples)

    def partial(self, start, frequency, amplitude, decay, attack=0.003):
        """Adds a sine with a short linear attack and an exponential decay."""
        first = int(start * SAMPLE_RATE)
        length = min(len(self) - first, int(decay * 7 * SAMPLE_RATE))
        step = TAU * frequency / SAMPLE_RATE
        for index in range(max(0, length)):
            time = index / SAMPLE_RATE
            envelope = min(1.0, time / attack) * math.exp(-time / decay)
            self.samples[first + index] += amplitude * envelope * math.sin(step * index)

    def tone(self, start, seconds, frequency_curve, amplitude_curve, harmonics=(1.0,)):
        """Adds a sustained tone shaped by curves that map progress 0...1 to a value."""
        first = int(start * SAMPLE_RATE)
        length = min(len(self) - first, int(seconds * SAMPLE_RATE))
        phase = 0.0
        for index in range(max(0, length)):
            progress = index / length
            phase += TAU * frequency_curve(progress, index / SAMPLE_RATE) / SAMPLE_RATE
            amplitude = amplitude_curve(progress, index / SAMPLE_RATE)
            value = sum(level * math.sin(phase * (order + 1)) for order, level in enumerate(harmonics))
            self.samples[first + index] += amplitude * value

    def finish(self, room=0.0, mix=0.0, damping=0.5, fade=0.15, delay=None):
        samples = self.samples
        if delay:
            samples = echo(samples, *delay)
        if mix:
            wet = reverb(samples, room, damping)
            samples = [dry * (1 - mix * 0.5) + echo * mix for dry, echo in zip(samples, wet)]
        samples = lowpass(lowpass(highpass(samples, 150), 3000), 3000)
        fade_length = int(fade * SAMPLE_RATE)
        for index in range(fade_length):
            samples[-1 - index] *= index / fade_length
        return level(samples)


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


def swell(attack, release):
    def curve(progress, _):
        return min(1.0, progress / attack) * min(1.0, (1 - progress) / release)
    return curve




class Instruments(Track):
    """Warm, rounded voices. Melodies sound an octave below their written pitch so they sit
    around 250 Hz to 1 kHz, below the 2 to 4 kHz band where the ear is most sensitive.
    Overtones are kept harmonic and quiet, and attacks are soft so nothing pings."""

    @staticmethod
    def frequency(pitch):
        return note(pitch) / 2

    def glockenspiel(self, start, pitch, amplitude=1.0, decay=0.8):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.008)
        self.partial(start, frequency + 0.8, amplitude * 0.3, decay, attack=0.008)
        self.partial(start, frequency * 2.0, amplitude * 0.08, decay * 0.25, attack=0.008)
        self.partial(start, frequency * 3.0, amplitude * 0.02, decay * 0.12, attack=0.008)

    def celesta(self, start, pitch, amplitude=1.0, decay=0.6):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.01)
        self.partial(start, frequency * 2.0, amplitude * 0.1, decay * 0.3, attack=0.01)
        self.partial(start, frequency * 3.0, amplitude * 0.02, decay * 0.15, attack=0.01)

    def music_box(self, start, pitch, amplitude=1.0, decay=0.5):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.007)
        self.partial(start, frequency * 2.0, amplitude * 0.08, decay * 0.25, attack=0.007)
        self.partial(start, frequency * 4.0, amplitude * 0.02, decay * 0.1, attack=0.007)

    def marimba(self, start, pitch, amplitude=1.0, decay=0.35):
        frequency = self.frequency(pitch)
        self.partial(start, frequency, amplitude, decay, attack=0.008)
        self.partial(start, frequency * 3.93, amplitude * 0.05, decay * 0.12, attack=0.008)

    def pad(self, start, seconds, pitches, amplitude=0.25, attack=0.35, release=0.5):
        for pitch in pitches:
            for detune in (0.9975, 1.0025):
                self.tone(start, seconds, lambda progress, time, base=note(pitch) * detune: base,
                          swell(attack, release), (amplitude, amplitude * 0.12, amplitude * 0.04))


def sequence(track, voice, notes, **options):
    for start, pitch in notes:
        voice(track, start, pitch, **options)


# Event sounds: short melodic motifs that announce something is starting.

def furin():
    """Wind Chime: a glockenspiel climbing a C major ninth over a soft pad."""
    track = Instruments(2.2)
    track.pad(0.0, 1.9, ("C5", "E5", "G5"), amplitude=0.08)
    sequence(track, Instruments.glockenspiel,
             ((0.0, "C6"), (0.1, "E6"), (0.2, "G6"), (0.3, "B6"), (0.4, "D7")), amplitude=0.6)
    return track.finish(room=0.5, mix=0.25, delay=(0.18, 0.3, 0.3))


def asahi():
    """Sunrise: marimba steps up a G major chord to a ringing high bell."""
    track = Instruments(2.2)
    track.pad(0.25, 1.8, ("G4", "D5", "B5"), amplitude=0.07, attack=0.4)
    sequence(track, Instruments.marimba, ((0.0, "G5"), (0.14, "D6"), (0.28, "B5")))
    track.glockenspiel(0.42, "G6", 0.7, decay=0.9)
    return track.finish(room=0.5, mix=0.25, delay=(0.21, 0.3, 0.25))


def sakura():
    """Cherry Blossom: celesta notes drifting down onto a G add9 chord."""
    track = Instruments(2.2)
    sequence(track, Instruments.celesta, ((0.0, "E6"), (0.13, "D6"), (0.26, "B5"), (0.39, "G5")))
    for pitch in ("G5", "A5", "D6"):
        track.celesta(0.62, pitch, 0.6, decay=0.8)
    return track.finish(room=0.55, mix=0.3, delay=(0.2, 0.25, 0.2))


def uguisu():
    """Warbler: two playful grace-note leaps, then a bright high note."""
    track = Instruments(1.9)
    for start, low, high in ((0.0, "D6", "G6"), (0.3, "D6", "B6")):
        track.glockenspiel(start, low, 0.35, decay=0.25)
        track.glockenspiel(start + 0.05, high, 0.6, decay=0.5)
    track.glockenspiel(0.6, "D7", 0.55, decay=0.8)
    return track.finish(room=0.45, mix=0.25, delay=(0.15, 0.3, 0.25))


def seseragi():
    """Brook: a music box rippling up and down an F major seventh."""
    track = Instruments(2.0)
    notes = ("F5", "A5", "C6", "E6", "G6", "E6", "C6", "E6")
    sequence(track, Instruments.music_box, [(index * 0.08, pitch) for index, pitch in enumerate(notes)],
             amplitude=0.6)
    track.music_box(0.68, "F6", 0.7, decay=0.8)
    track.music_box(0.68, "C6", 0.4, decay=0.8)
    return track.finish(room=0.5, mix=0.25, delay=(0.16, 0.3, 0.25))


def hoshizora():
    """Starry Sky: slow twinkling celesta over a D major seventh pad."""
    track = Instruments(2.3)
    track.pad(0.0, 2.1, ("D5", "F#5", "A5", "C#6"), amplitude=0.06, attack=0.3)
    sequence(track, Instruments.celesta, ((0.0, "A6"), (0.22, "E6"), (0.44, "B6"), (0.66, "F#6")),
             amplitude=0.55, decay=0.7)
    return track.finish(room=0.6, mix=0.3, delay=(0.22, 0.35, 0.3))


def niji():
    """Rainbow: a quick music box run that blooms into a C add9 chord."""
    track = Instruments(2.1)
    notes = ("C6", "D6", "E6", "G6", "A6", "C7")
    sequence(track, Instruments.music_box, [(index * 0.07, pitch) for index, pitch in enumerate(notes)],
             amplitude=0.55)
    track.pad(0.35, 1.6, ("C5", "E5", "G5", "D6"), amplitude=0.07, attack=0.3)
    return track.finish(room=0.5, mix=0.25, delay=(0.14, 0.3, 0.25))


def kumo():
    """Clouds: a soft F major seventh pad with two quiet bells on top."""
    track = Instruments(2.0)
    track.pad(0.0, 1.9, ("F4", "A4", "C5", "E5"), amplitude=0.08, attack=0.25)
    track.celesta(0.15, "C6", 0.6, decay=0.7)
    track.celesta(0.5, "A5", 0.5, decay=0.8)
    return track.finish(room=0.6, mix=0.3)


def nami():
    """Waves: a rolling marimba call and answer, settling on a high bell."""
    track = Instruments(2.0)
    sequence(track, Instruments.marimba,
             ((0.0, "E6"), (0.13, "C6"), (0.26, "G5"), (0.52, "A5"), (0.65, "C6"), (0.78, "D6")),
             amplitude=0.8)
    track.glockenspiel(0.92, "E6", 0.5, decay=0.8)
    return track.finish(room=0.5, mix=0.25, delay=(0.13, 0.25, 0.2))


def kaze():
    """Breeze: an airy E major pad with a light glockenspiel falling through it."""
    track = Instruments(2.1)
    track.pad(0.0, 2.0, ("E5", "G#5", "B5"), amplitude=0.07, attack=0.25)
    sequence(track, Instruments.glockenspiel,
             ((0.25, "B6"), (0.37, "G#6"), (0.49, "E6"), (0.61, "C#6")), amplitude=0.5, decay=0.6)
    return track.finish(room=0.55, mix=0.3, delay=(0.18, 0.3, 0.25))


# Reminder sounds: two or three notes, softer still, a gentle nudge.

def shizuku():
    """Dewdrop: two soft marimba notes, a fourth apart."""
    track = Instruments(1.0)
    sequence(track, Instruments.marimba, ((0.0, "B5"), (0.12, "E6")), decay=0.25)
    return track.finish(room=0.45, mix=0.25, delay=(0.12, 0.2, 0.2))


def hotaru():
    """Firefly: three glockenspiel notes twinkling up an E major chord."""
    track = Instruments(1.2)
    sequence(track, Instruments.glockenspiel, ((0.0, "E6"), (0.1, "G#6"), (0.2, "B6")), decay=0.5)
    return track.finish(room=0.5, mix=0.25, delay=(0.15, 0.25, 0.25))


def momiji():
    """Maple Leaf: a celesta note falling, then a lighter one above."""
    track = Instruments(1.2)
    sequence(track, Instruments.celesta, ((0.0, "A5"), (0.16, "E5")), decay=0.45)
    track.celesta(0.4, "C#6", 0.5, decay=0.5)
    return track.finish(room=0.5, mix=0.25)


def tsuki():
    """Moon: one calm bell chord of a fifth, with a faint octave."""
    track = Instruments(1.4)
    for pitch, amplitude in (("A5", 0.8), ("E6", 0.6), ("A6", 0.2)):
        track.celesta(0.0, pitch, amplitude, decay=0.7)
    return track.finish(room=0.55, mix=0.3, fade=0.3)


def kiri():
    """Morning Mist: an A major ninth pad that swells up under a single bell."""
    track = Instruments(1.5)
    track.pad(0.0, 1.4, ("A4", "C#5", "E5", "B5"), amplitude=0.08, attack=0.25)
    track.celesta(0.2, "E6", 0.5, decay=0.6)
    return track.finish(room=0.55, mix=0.3, fade=0.05)


def hamon():
    """Ripple: a single celesta note with echoes spreading out."""
    track = Instruments(1.3)
    track.celesta(0.0, "C6", decay=0.4)
    return track.finish(room=0.5, mix=0.25, delay=(0.15, 0.45, 0.5))


def suzu():
    """Little Bell: two small bells, high then a fourth below."""
    track = Instruments(1.0)
    sequence(track, Instruments.glockenspiel, ((0.0, "D7"), (0.09, "A6")), amplitude=0.7, decay=0.4)
    return track.finish(room=0.45, mix=0.25)


def hana():
    """Flower: a music box opening up an A minor seventh."""
    track = Instruments(1.1)
    sequence(track, Instruments.music_box, ((0.0, "C6"), (0.09, "E6"), (0.18, "A6")), decay=0.45)
    return track.finish(room=0.45, mix=0.25, delay=(0.13, 0.25, 0.2))


def yuki():
    """Snow: three hushed celesta notes settling down a D major chord."""
    track = Instruments(1.2)
    sequence(track, Instruments.celesta, ((0.0, "F#6"), (0.16, "D6"), (0.32, "A5")), amplitude=0.7, decay=0.45)
    return track.finish(room=0.55, mix=0.3)


def mejiro():
    """White-eye: a quick grace-note hop and a reply."""
    track = Instruments(0.9)
    track.glockenspiel(0.0, "D6", 0.35, decay=0.2)
    track.glockenspiel(0.04, "A6", 0.7, decay=0.35)
    track.glockenspiel(0.2, "F#6", 0.6, decay=0.4)
    return track.finish(room=0.45, mix=0.25)


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


def write(samples, path):
    with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as handle:
        wav_path = handle.name
    with wave.open(wav_path, "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, value)) * 32767)) for value in samples))
    subprocess.run(["afconvert", "-f", "caff", "-d", "ima4", wav_path, path], check=True)
    os.remove(wav_path)


def main():
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    only = set(sys.argv[2:])
    os.makedirs(output, exist_ok=True)
    for name, generator in SOUNDS.items():
        if only and name not in only:
            continue
        samples = generator()
        write(samples, os.path.join(output, f"{name}.caf"))
        print(f"{name}: {len(samples) / SAMPLE_RATE:.2f}s")


if __name__ == "__main__":
    main()
