#!/usr/bin/env python3
"""Synthesizes Folio's alarm sounds, ten of them, from a mellow touch to an alarm that can't be slept through.

Usage: python3 generate_alarms.py <output directory> [Alarm-Name ...]

Each sound is one short phrase repeated to just under 30 seconds, since AlarmKit is reported to stop custom
sounds at about that length. The phrase is rendered as a steady loop, with its reverb and echo tails folded
back onto its start, so the repeats run on seamlessly and the file also loops cleanly if the system repeats it.

Sounds get louder and brighter through the list. Written at 22.05 kHz, as 16-bit linear PCM like the
notification sounds, to keep 30 seconds of audio near a megabyte. Reuses generate.py's voices and encoder.
"""

import math
import os
import sys

import generate
from generate import Instruments, TAU, echo, highpass, level, lowpass, reverb

generate.SAMPLE_RATE = 22050
SAMPLE_RATE = generate.SAMPLE_RATE
MAXIMUM_LENGTH = 29.0


class AlarmInstruments(Instruments):
    """Plays at written pitch, unlike the notification sounds, so urgent alarms can sit in the bright band
    the ear catches first. Adds sustained, gated tones for the digital alarms."""

    @staticmethod
    def frequency(pitch):
        return generate.note(pitch)

    def tone(self, start, frequency, amplitude, length, attack=0.004, release=0.012):
        first = int(start * SAMPLE_RATE)
        held = int(length * SAMPLE_RATE)
        tail = int(release * SAMPLE_RATE)
        step = TAU * frequency / SAMPLE_RATE
        for index in range(max(0, min(len(self) - first, held + tail))):
            time = index / SAMPLE_RATE
            envelope = min(1.0, time / attack)
            if index > held:
                envelope *= 1 - (index - held) / tail
            self.samples[first + index] += amplitude * envelope * math.sin(step * index)

    def beep(self, start, pitch, length, amplitude=1.0, harmonics=1):
        """A clean digital beep: a sine, or with harmonics a band-limited square of odd partials."""
        frequency = self.frequency(pitch)
        for order in range(1, 2 * harmonics, 2):
            self.tone(start, frequency * order, amplitude / order, length)


class Loop:
    """Renders a phrase as one period of a seamless loop and repeats it to fill the file."""

    def __init__(self, period, tail=3.0):
        self.period = period
        self.track = AlarmInstruments(period + tail)

    def render(self, room=0.0, mix=0.0, damping=0.5, delay=None, brightness=4000, loudness=-20.0):
        samples = self.track.samples
        if delay:
            samples = echo(samples, *delay)
        if mix:
            wet = reverb(samples, room, damping)
            samples = [dry * (1 - mix * 0.5) + effect * mix for dry, effect in zip(samples, wet)]
        length = int(self.period * SAMPLE_RATE)
        folded = [0.0] * length
        for index, value in enumerate(samples):
            folded[index % length] += value
        cycle = self.filter(folded * 4, brightness)[-length:]
        repeated = cycle * int(MAXIMUM_LENGTH // self.period)
        fade = int(0.03 * SAMPLE_RATE)
        for index in range(fade):
            repeated[index] *= index / fade
        return level(repeated, target_decibels=loudness)

    @staticmethod
    def filter(samples, brightness):
        return lowpass(lowpass(highpass(samples, 150), brightness), brightness)


def sequence(track, voice, notes, **options):
    for start, pitch in notes:
        voice(track, start, pitch, **options)


def evenly(spacing, pitches, offset=0.0):
    return [(offset + index * spacing, pitch) for index, pitch in enumerate(pitches)]


def yoake():
    """Daybreak: a soft vibraphone slowly opening up an F major ninth, with plenty of room to breathe."""
    loop = Loop(4.8)
    sequence(loop.track, Instruments.vibraphone, evenly(0.55, ("F4", "A4", "C5", "E5", "G5")),
             amplitude=0.6, decay=1.1, tone=0.6)
    return loop.render(room=0.6, mix=0.25, brightness=3500, loudness=-19.0)


def komorebi():
    """Sunlight Through Leaves: a kalimba lullaby, gently rising and falling."""
    loop = Loop(3.6)
    sequence(loop.track, Instruments.kalimba, evenly(0.22, ("C5", "E5", "G5", "E5", "D5", "G5")),
             amplitude=0.6, decay=0.5, tone=0.8)
    loop.track.kalimba(1.32, "C5", 0.55, decay=0.8, tone=0.8)
    loop.track.kalimba(1.32, "E5", 0.35, decay=0.8, tone=0.8)
    return loop.render(room=0.4, mix=0.15, brightness=3800, loudness=-18.0)


def hibari():
    """Skylark: a celesta and glockenspiel trilling up a G major chord, twice, like birdsong at dawn."""
    loop = Loop(3.2)
    for offset in (0.0, 0.9):
        sequence(loop.track, Instruments.celesta, evenly(0.11, ("G5", "B5", "D6", "G6"), offset),
                 amplitude=0.5, decay=0.4, tone=1.2)
        loop.track.glockenspiel(offset + 0.44, "B6", 0.35, decay=0.5)
    return loop.render(room=0.3, mix=0.1, brightness=5000, loudness=-17.0)


def shiokaze():
    """Sea Breeze: a lively marimba figure rolling around A minor."""
    loop = Loop(2.4)
    sequence(loop.track, Instruments.marimba,
             evenly(0.15, ("A4", "C5", "E5", "A5", "E5", "C5", "E5", "G5")), amplitude=0.75, tone=1.1)
    loop.track.marimba(1.2, "A5", 0.8, decay=0.5, tone=1.1)
    return loop.render(room=0.25, mix=0.08, brightness=4500, loudness=-16.0)


def kane():
    """Temple Bell: two firm glass bell chords, struck and left to ring."""
    loop = Loop(3.0)
    for start in (0.0, 0.55):
        for pitch, amplitude in (("A4", 0.7), ("E5", 0.5), ("A5", 0.3)):
            loop.track.bell(start, pitch, amplitude, decay=0.9, tone=1.3)
    return loop.render(room=0.5, mix=0.2, brightness=5000, loudness=-15.0)


def hibiki():
    """Echo: a bright synth pluck arpeggio up a C major chord, with echoes trailing behind."""
    loop = Loop(2.0)
    sequence(loop.track, Instruments.synth_pluck,
             evenly(0.1, ("C5", "E5", "G5", "C6", "G5", "E5", "G5", "C6")), amplitude=0.55, decay=0.25, tone=1.3)
    return loop.render(room=0.25, mix=0.08, delay=(0.3, 0.3, 0.25), brightness=5500, loudness=-14.0)


def tsubame():
    """Swallow: quick bell trills darting between two notes, insisting a little more each time."""
    loop = Loop(1.6)
    trill = [(index * 0.06, "D6" if index % 2 == 0 else "A5") for index in range(9)]
    sequence(loop.track, Instruments.bell, trill, amplitude=0.55, decay=0.18, tone=1.5)
    return loop.render(room=0.2, mix=0.06, brightness=6000, loudness=-13.0)


def arashi():
    """Storm: a pair of rising digital beeps, softened by a touch of harmonic warmth."""
    loop = Loop(1.2)
    for start, pitch in ((0.0, "E6"), (0.16, "E6"), (0.32, "A6")):
        loop.track.beep(start, pitch, 0.1, 0.6, harmonics=2)
    return loop.render(brightness=6000, loudness=-12.0)


def hayate():
    """Gale: the classic alarm clock, four quick square-wave beeps and a breath."""
    loop = Loop(1.0)
    for index in range(4):
        loop.track.beep(index * 0.12, "A6", 0.07, 0.6, harmonics=4)
    return loop.render(brightness=7000, loudness=-10.5)


def kaminari():
    """Thunder: a relentless two-tone square-wave alarm, for mornings that cannot be missed."""
    loop = Loop(0.8)
    for index in range(6):
        loop.track.beep(index * 0.11, "C7" if index % 2 == 0 else "F#6", 0.09, 0.6, harmonics=5)
    return loop.render(brightness=8000, loudness=-9.0)


SOUNDS = {
    "Alarm-Yoake": yoake,
    "Alarm-Komorebi": komorebi,
    "Alarm-Hibari": hibari,
    "Alarm-Shiokaze": shiokaze,
    "Alarm-Kane": kane,
    "Alarm-Hibiki": hibiki,
    "Alarm-Tsubame": tsubame,
    "Alarm-Arashi": arashi,
    "Alarm-Hayate": hayate,
    "Alarm-Kaminari": kaminari,
}


def main():
    output = sys.argv[1] if len(sys.argv) > 1 else "."
    only = set(sys.argv[2:])
    os.makedirs(output, exist_ok=True)
    for name, generator in SOUNDS.items():
        if only and name not in only:
            continue
        samples = generator()
        peak = generate.write_without_clipping(samples, os.path.join(output, f"{name}.caf"))
        print(f"{name}: {len(samples) / SAMPLE_RATE:.2f}s, peak {20 * math.log10(peak):.2f} dBFS")


if __name__ == "__main__":
    main()
