#!/usr/bin/env python3
"""Synthesizes Folio's notification sounds, inspired by Japanese nature.

Usage: python3 generate.py <output directory>

Writes one .caf (IMA4, mono, 44.1 kHz) per sound. Pure standard library, seeded,
so every run produces identical files. Requires macOS for afconvert.
"""

import math
import os
import random
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

    def partial(self, start, frequency, amplitude, decay, attack=0.002, glide=None, vibrato=None):
        """Adds a sine with an exponential decay. glide is (target frequency, seconds)."""
        first = int(start * SAMPLE_RATE)
        length = min(len(self) - first, int(decay * 7 * SAMPLE_RATE))
        phase = 0.0
        for index in range(max(0, length)):
            time = index / SAMPLE_RATE
            current = frequency
            if glide:
                target, glide_seconds = glide
                progress = min(1.0, time / glide_seconds)
                current = frequency * (target / frequency) ** progress
            if vibrato:
                rate, depth, delay = vibrato
                ramp = min(1.0, max(0.0, (time - delay) / 0.4))
                current *= 1 + depth * ramp * math.sin(TAU * rate * time)
            phase += TAU * current / SAMPLE_RATE
            envelope = min(1.0, time / attack) * math.exp(-time / decay)
            self.samples[first + index] += amplitude * envelope * math.sin(phase)

    def bell(self, start, frequency, amplitude, ratios, levels, decays, beat=0.0):
        for ratio, level, decay in zip(ratios, levels, decays):
            self.partial(start, frequency * ratio, amplitude * level, decay)
            if beat:
                self.partial(start, frequency * ratio + beat, amplitude * level * 0.6, decay)

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

    def noise(self, start, seconds, center, quality, amplitude_curve, rng):
        first = int(start * SAMPLE_RATE)
        length = min(len(self) - first, int(seconds * SAMPLE_RATE))
        source = [rng.uniform(-1, 1) for _ in range(max(0, length))]
        filtered = bandpass(source, center, quality)
        for index, value in enumerate(filtered):
            self.samples[first + index] += value * amplitude_curve(index / length, index / SAMPLE_RATE)

    def pluck(self, start, frequency, amplitude, sustain, brightness, rng, bend=None):
        """Karplus-Strong string. bend is (cents, delay seconds) for a pressed-string rise."""
        first = int(start * SAMPLE_RATE)
        period = SAMPLE_RATE / frequency
        size = int(period) + 2
        line = [rng.uniform(-1, 1) for _ in range(size)]
        line = [(line[index] + line[index - 1]) * 0.5 for index in range(size)]
        previous = 0.0
        length = min(len(self) - first, int(sustain * 6 * SAMPLE_RATE))
        write_index = 0
        output = []
        for index in range(length):
            time = index / SAMPLE_RATE
            current_period = period
            if bend:
                cents, delay = bend
                progress = min(1.0, max(0.0, (time - delay) / 0.12))
                current_period = period / 2 ** (cents * progress / 1200)
            read = (write_index - current_period) % size
            lower = int(read)
            fraction = read - lower
            value = line[lower] * (1 - fraction) + line[(lower + 1) % size] * fraction
            smoothed = brightness * value + (1 - brightness) * previous
            previous = smoothed
            line[write_index] = smoothed * math.exp(-1 / (sustain * frequency))
            write_index = (write_index + 1) % size
            output.append(value)
        for index, value in enumerate(output):
            self.samples[first + index] += amplitude * value

    def click(self, start, amplitude, center, rng, seconds=0.012):
        self.noise(start, seconds, center, 1.2, lambda progress, _: amplitude * (1 - progress) ** 3, rng)

    def finish(self, room=0.0, mix=0.0, damping=0.4, fade=0.15):
        samples = self.samples
        if mix:
            wet = reverb(samples, room, damping)
            samples = [dry * (1 - mix * 0.5) + echo * mix for dry, echo in zip(samples, wet)]
        samples = highpass(samples, 90)
        fade_length = int(fade * SAMPLE_RATE)
        for index in range(fade_length):
            samples[-1 - index] *= index / fade_length
        return level(samples)


def level(samples, target_decibels=-16.0, ceiling=0.9):
    """Matches loudness across sounds, softly limiting peaks instead of clipping them."""
    loudest = max(abs(value) for value in samples) or 1
    power = math.sqrt(sum(value * value for value in samples) / len(samples)) or 1
    gain = min(10 ** (target_decibels / 20) / power, 1.6 * ceiling / loudest)
    knee = ceiling * 0.7

    def limit(value):
        magnitude = abs(value)
        if magnitude <= knee:
            return value
        squeezed = knee + (ceiling - knee) * math.tanh((magnitude - knee) / (ceiling - knee))
        return math.copysign(squeezed, value)

    return [limit(value * gain) for value in samples]


def bandpass(samples, center, quality):
    omega = TAU * center / SAMPLE_RATE
    alpha = math.sin(omega) / (2 * quality)
    b0, b2 = alpha, -alpha
    a0, a1, a2 = 1 + alpha, -2 * math.cos(omega), 1 - alpha
    x1 = x2 = y1 = y2 = 0.0
    output = []
    for value in samples:
        result = (b0 * value + b2 * x2 - a1 * y1 - a2 * y2) / a0
        x2, x1, y2, y1 = x1, value, y1, result
        output.append(result)
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


# Calendar sounds: clearer, a little longer, meant to announce an event.

def furin(rng):
    """Furin: a glass wind bell touched by a summer breeze."""
    track = Track(2.6)
    ratios, levels, decays = (1, 2.32, 4.25, 6.63), (1, 0.45, 0.25, 0.12), (0.9, 0.5, 0.3, 0.18)
    for start, pitch, level in ((0.0, "E6", 1.0), (0.34, "B6", 0.75), (0.61, "G#6", 0.6), (1.05, "E6", 0.4)):
        track.click(start, 0.25 * level, 6000, rng)
        track.bell(start, note(pitch), level, ratios, levels, decays, beat=2.1)
    return track.finish(room=0.5, mix=0.25)


def shishiodoshi(rng):
    """Shishi-odoshi: water fills the bamboo, which tips and knocks against stone."""
    track = Track(2.0)
    track.noise(0.0, 0.7, 900, 3, swell(0.4, 0.3), rng)
    for start in (0.08, 0.22, 0.37, 0.5):
        track.partial(start, rng.uniform(700, 1000), 0.12, 0.03, glide=(1700, 0.04))
    track.click(0.72, 0.9, 2500, rng, seconds=0.02)
    track.partial(0.72, 392, 1.0, 0.16)
    track.partial(0.72, 392 * 2.9, 0.35, 0.05)
    track.partial(0.72, 196, 0.5, 0.11)
    return track.finish(room=0.85, mix=0.55, damping=0.3)


def bonsho(rng):
    """Bonsho: a temple bell heard from across the valley."""
    track = Track(3.2)
    track.noise(0.0, 0.05, 300, 0.8, lambda progress, _: 0.6 * (1 - progress) ** 2, rng)
    track.bell(
        0.0, 196, 1.0,
        (0.5, 1.0, 1.19, 1.51, 2.0, 2.68, 3.02, 4.17),
        (0.35, 1.0, 0.6, 0.5, 0.45, 0.3, 0.2, 0.12),
        (2.4, 1.8, 1.5, 1.2, 1.0, 0.7, 0.5, 0.35),
        beat=0.9,
    )
    return track.finish(room=0.8, mix=0.35, fade=0.6)


def suikinkutsu(rng):
    """Suikinkutsu: drops falling into a buried jar, ringing back up through the stones."""
    track = Track(2.8)
    for start, pitch in ((0.0, "E6"), (0.42, "B5"), (0.7, "A5"), (1.25, "E6"), (1.5, "D6")):
        frequency = note(pitch)
        track.partial(start, frequency * 0.6, 0.35, 0.025, glide=(frequency, 0.02))
        track.bell(start + 0.01, frequency, 0.8, (1, 2.01, 3.02), (1, 0.3, 0.12), (0.7, 0.35, 0.2))
    return track.finish(room=0.92, mix=0.6, damping=0.2)


def uguisu(rng):
    """Uguisu: the bush warbler's spring call, hoo hokekyo."""
    track = Track(2.3)
    harmonics = (1.0, 0.12, 0.04)
    track.tone(0.05, 0.62, lambda progress, time: 1250 + 60 * progress + 12 * math.sin(TAU * 7 * time),
               swell(0.35, 0.15), harmonics)
    track.tone(0.82, 0.12, lambda progress, _: 1700 + 300 * progress, swell(0.2, 0.3), harmonics)
    track.tone(0.97, 0.1, lambda progress, _: 2100 + 900 * progress, swell(0.15, 0.3), harmonics)
    track.tone(1.1, 0.34, lambda progress, _: 3100 - 1200 * progress ** 0.7, swell(0.08, 0.5), harmonics)
    return track.finish(room=0.7, mix=0.4)


def koto(rng):
    """Koto: a few plucked strings in the hirajoshi scale, the last one pressed."""
    track = Track(2.2)
    for start, pitch, level in ((0.0, "A4", 0.8), (0.16, "Bb4", 0.7), (0.32, "D5", 0.8), (0.48, "E5", 0.9)):
        track.pluck(start, note(pitch), level, 0.5, 0.55, rng)
    track.pluck(0.9, note("A5"), 1.0, 0.7, 0.6, rng, bend=(100, 0.25))
    return track.finish(room=0.55, mix=0.3)


def shakuhachi(rng):
    """Shakuhachi: a breathy bamboo flute phrase with a gentle meri bend."""
    track = Track(2.6)
    breath = lambda progress, _: 0.25 * swell(0.2, 0.25)(progress, 0)
    track.tone(0.0, 0.7, lambda progress, _: note("A4") * 2 ** (-0.8 * (1 - min(1, progress * 3)) / 12),
               swell(0.25, 0.2), (1.0, 0.35, 0.12))
    track.noise(0.0, 0.7, 1800, 1.5, breath, rng)
    track.tone(0.65, 1.7, lambda progress, time: note("D5") * (1 + 0.012 * min(1, time) * math.sin(TAU * 5 * time)),
               swell(0.12, 0.45), (1.0, 0.3, 0.1))
    track.noise(0.65, 1.7, 2400, 1.5, breath, rng)
    return track.finish(room=0.7, mix=0.35)


def sakura(rng):
    """Sakura: petals drifting down on miyako-bushi bells."""
    track = Track(2.4)
    for index, pitch in enumerate(("C7", "B6", "A6", "F6", "E6", "B5")):
        start = index * 0.17 + rng.uniform(-0.02, 0.02)
        track.bell(start, note(pitch), 0.8 - index * 0.06, (1, 3.0, 4.07), (1, 0.18, 0.06), (0.6, 0.15, 0.08))
    return track.finish(room=0.6, mix=0.35)


def seseragi(rng):
    """Seseragi: a clear mountain stream burbling over pebbles."""
    track = Track(2.2)
    track.noise(0.0, 2.2, 1400, 1.2, lambda progress, _: 0.08 * swell(0.2, 0.35)(progress, 0), rng)
    time = 0.05
    while time < 1.8:
        frequency = rng.uniform(500, 1300)
        track.partial(time, frequency, rng.uniform(0.25, 0.5), 0.035, glide=(frequency * 2.1, 0.035))
        time += rng.uniform(0.04, 0.13)
    return track.finish(room=0.5, mix=0.3)


def higurashi(rng):
    """Higurashi: the evening cicada's falling kana-kana-kana."""
    track = Track(2.6)
    start, gap, level = 0.0, 0.11, 1.0
    for _ in range(13):
        pitch = 4300 * (0.97 + 0.06 * level)
        track.tone(start, 0.085,
                   lambda progress, _, base=pitch: base - 500 * progress,
                   lambda progress, time, size=level: size * swell(0.1, 0.4)(progress, 0)
                   * (0.55 + 0.45 * math.sin(TAU * 90 * time)),
                   (1.0, 0.15))
        start += gap
        gap *= 1.05
        level *= 0.86
    return track.finish(room=0.75, mix=0.4)


# Reminder sounds: softer and shorter, meant as a gentle nudge.

def shizuku(rng):
    """Shizuku: dew dripping from a leaf."""
    track = Track(1.3)
    track.partial(0.0, 900, 1.0, 0.09, glide=(1900, 0.05))
    track.partial(0.38, 1100, 0.5, 0.07, glide=(2300, 0.04))
    return track.finish(room=0.7, mix=0.45)


def hotaru(rng):
    """Hotaru: fireflies glowing one after another over a rice paddy."""
    track = Track(1.7)
    for start, pitch in ((0.0, "E7"), (0.22, "G7"), (0.44, "B7")):
        track.partial(start, note(pitch) / 2, 0.8, 0.35, attack=0.03)
        track.partial(start, note(pitch) / 2 * 2.01, 0.2, 0.2, attack=0.03)
    return track.finish(room=0.6, mix=0.4)


def kaeru(rng):
    """Kaeru: a tree frog's soft kero kero after rain."""
    track = Track(1.2)
    for croak_start in (0.0, 0.42):
        for syllable, pitch in ((0.0, 720), (0.12, 600)):
            for pulse in range(5):
                track.partial(croak_start + syllable + pulse * 0.016, pitch, 0.6, 0.006)
                track.partial(croak_start + syllable + pulse * 0.016, pitch * 2.5, 0.15, 0.003)
    return track.finish(room=0.4, mix=0.25)


def suzumushi(rng):
    """Suzumushi: a bell cricket's ringing riin in autumn grass."""
    track = Track(1.4)
    for start, seconds, level in ((0.0, 0.42, 1.0), (0.55, 0.28, 0.7)):
        track.tone(start, seconds, lambda progress, _: 4100 - 80 * progress,
                   lambda progress, time, size=level: size * swell(0.08, 0.3)(progress, 0)
                   * (0.5 + 0.5 * math.sin(TAU * 42 * time)))
    return track.finish(room=0.55, mix=0.3)


def momiji(rng):
    """Momiji: a maple leaf falling, two soft wooden notes."""
    track = Track(1.3)
    for start, pitch in ((0.0, "A5"), (0.2, "E5")):
        track.partial(start, note(pitch), 1.0, 0.28)
        track.partial(start, note(pitch) * 3.93, 0.25, 0.04)
        track.click(start, 0.15, 3000, rng)
    return track.finish(room=0.5, mix=0.3)


def take(rng):
    """Take: hollow bamboo tubes knocking together in the grove."""
    track = Track(1.4)
    for start, pitch in ((0.0, "D5"), (0.11, "A5"), (0.3, "F5")):
        track.click(start, 0.3, 1800, rng)
        track.partial(start, note(pitch), 0.9, 0.12)
        track.partial(start, note(pitch) * 2.75, 0.3, 0.05)
    return track.finish(room=0.6, mix=0.35)


def mejiro(rng):
    """Mejiro: a white-eye's quick chirps among plum blossoms."""
    track = Track(1.1)
    for start, low, high in ((0.0, 3200, 4600), (0.09, 4400, 3300), (0.25, 3400, 5000), (0.33, 4800, 3500)):
        track.tone(start, 0.06, lambda progress, _, a=low, b=high: a + (b - a) * progress,
                   swell(0.2, 0.4), (1.0, 0.08))
    return track.finish(room=0.5, mix=0.3)


def kiri(rng):
    """Kiri: morning mist lifting off a lake."""
    track = Track(1.9)
    for pitch, level in (("A4", 0.6), ("E5", 0.5), ("B5", 0.35), ("F#6", 0.2)):
        track.tone(0.0, 1.85, lambda progress, time, base=note(pitch): base * (1 + 0.002 * math.sin(TAU * 3 * time)),
                   lambda progress, _, size=level: size * swell(0.3, 0.55)(progress, 0))
    return track.finish(room=0.7, mix=0.35, fade=0.05)


def hamon(rng):
    """Hamon: a pebble dropped in a pond, its ripples spreading out."""
    track = Track(1.5)
    track.partial(0.0, 420, 0.8, 0.05, glide=(1250, 0.04))
    for index in range(4):
        track.partial(0.12 + index * 0.17, note("E6"), 0.5 * 0.6 ** index, 0.12, attack=0.01)
    return track.finish(room=0.75, mix=0.45)


def rin(rng):
    """Rin: a small singing bowl rung at a quiet shrine."""
    track = Track(2.2)
    track.click(0.0, 0.2, 5000, rng)
    track.bell(0.0, 1180, 1.0, (1, 2.71, 5.15, 8.2), (1, 0.4, 0.15, 0.06), (1.1, 0.6, 0.3, 0.15), beat=3.0)
    return track.finish(room=0.6, mix=0.3, fade=0.4)


SOUNDS = {
    "Calendar-Furin": furin,
    "Calendar-ShishiOdoshi": shishiodoshi,
    "Calendar-Bonsho": bonsho,
    "Calendar-Suikinkutsu": suikinkutsu,
    "Calendar-Uguisu": uguisu,
    "Calendar-Koto": koto,
    "Calendar-Shakuhachi": shakuhachi,
    "Calendar-Sakura": sakura,
    "Calendar-Seseragi": seseragi,
    "Calendar-Higurashi": higurashi,
    "Reminder-Shizuku": shizuku,
    "Reminder-Hotaru": hotaru,
    "Reminder-Kaeru": kaeru,
    "Reminder-Suzumushi": suzumushi,
    "Reminder-Momiji": momiji,
    "Reminder-Take": take,
    "Reminder-Mejiro": mejiro,
    "Reminder-Kiri": kiri,
    "Reminder-Hamon": hamon,
    "Reminder-Rin": rin,
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
        samples = generator(random.Random(name))
        write(samples, os.path.join(output, f"{name}.caf"))
        print(f"{name}: {len(samples) / SAMPLE_RATE:.2f}s")


if __name__ == "__main__":
    main()
