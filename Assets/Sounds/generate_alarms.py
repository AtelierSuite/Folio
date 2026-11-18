#!/usr/bin/env python3
"""Synthesizes Folio's alarm sounds, ten of them, from a mellow touch to an alarm that can't be slept through.

Usage: python3 generate_alarms.py <output directory> [Alarm-Name ...]

Each sound is one short phrase repeated to just under 30 seconds, since AlarmKit is reported to stop custom
sounds at about that length. The phrase is rendered as a steady loop, with its reverb and echo tails folded
back onto its start, so the repeats run on seamlessly and the file also loops cleanly if the system repeats it.

Sounds get louder and brighter through the list, and every one is mastered close to full scale with a
limiter, since an alarm has to carry across a room. Written at 44.1 kHz as 16-bit linear PCM, like the
notification sounds. Reuses generate.py's voices and encoder, including the sampled Steinway, so it needs
Logic Pro's sound library too.
"""

import math
import os
import sys

import generate
from generate import Instruments, SAMPLE_RATE, TAU, echo, highpass, lowpass, reverb

CEILING = 10 ** (-1.2 / 20)
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

    def render(self, room=0.0, mix=0.0, damping=0.5, delay=None, brightness=12000, loudness=-12.0, headroom=6.0):
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
        cycle = master(lowpass(highpass(folded * 4, 180), brightness), length, loudness, headroom)
        repeated = cycle * int(MAXIMUM_LENGTH // self.period)
        fade = int(0.01 * SAMPLE_RATE)
        for index in range(fade):
            repeated[index] *= index / fade
        return repeated


def limit(samples, gain, release=0.08):
    """A peak limiter: reacts instantly to anything over the ceiling, then lets go smoothly."""
    coefficient = math.exp(-1 / (release * SAMPLE_RATE))
    envelope = 0.0
    output = []
    for value in samples:
        boosted = value * gain
        envelope = max(abs(boosted), envelope * coefficient)
        output.append(boosted * (CEILING / envelope if envelope > CEILING else 1.0))
    return output


def master(samples, length, loudness, headroom):
    """Raises the steady loop until its loudness reaches the target, with the limiter holding peaks under the
    ceiling. Headroom caps how many decibels the limiter may squeeze, so soft sounds keep their dynamics.
    Runs over several repeats so the limiter has settled by the cycle that is kept."""
    loudest = max(abs(value) for value in samples) or 1
    gain = CEILING / loudest
    most = gain * 10 ** (headroom / 20)
    target = 10 ** (loudness / 20)
    for _ in range(8):
        limited = limit(samples, gain)
        cycle = limited[-length:]
        power = math.sqrt(sum(value * value for value in cycle) / length) or 1
        if power >= target * 0.97:
            break
        if gain >= most:
            break
        gain = min(most, gain * min(2.0, target / power))
    return cycle


def sequence(track, voice, notes, **options):
    for start, pitch in notes:
        voice(track, start, pitch, **options)


def evenly(spacing, pitches, offset=0.0):
    return [(offset + index * spacing, pitch) for index, pitch in enumerate(pitches)]


def yoake():
    """Daybreak: a Steinway slowly opening up an F major ninth, with a soft vibraphone glow on top."""
    loop = Loop(4.8)
    sequence(loop.track, Instruments.piano, evenly(0.38, ("F3", "C4", "F4", "A4", "C5", "E5", "G5")),
             amplitude=0.7, velocity=70, hold=2.4, release=0.4)
    loop.track.vibraphone(2.28, "G5", 0.3, decay=1.2, tone=0.5)
    return loop.render(room=0.6, mix=0.22, brightness=12000, loudness=-14.0, headroom=4.0)


def komorebi():
    """Dappled Light: a gentle Steinway lullaby, rising and falling onto a warm C major chord."""
    loop = Loop(3.6)
    sequence(loop.track, Instruments.piano, evenly(0.24, ("C5", "E5", "G5", "E5", "D5", "G5")),
             amplitude=0.75, velocity=80, hold=0.5, release=0.2)
    for pitch, amplitude in (("C4", 0.6), ("G4", 0.5), ("E5", 0.6)):
        loop.track.piano(1.44, pitch, amplitude, velocity=80, hold=1.4, release=0.35)
    return loop.render(room=0.45, mix=0.18, brightness=12000, loudness=-13.0, headroom=4.5)


def hibari():
    """Skylark: a celesta and glockenspiel trilling up a G major chord, twice, like birdsong at dawn."""
    loop = Loop(3.2)
    for offset in (0.0, 0.9):
        sequence(loop.track, Instruments.celesta, evenly(0.11, ("G5", "B5", "D6", "G6"), offset),
                 amplitude=0.5, decay=0.45, tone=1.4)
        sequence(loop.track, Instruments.celesta, evenly(0.11, ("G4", "B4", "D5", "G5"), offset),
                 amplitude=0.3, decay=0.45, tone=1.0)
        loop.track.glockenspiel(offset + 0.44, "B6", 0.45, decay=0.6)
    return loop.render(room=0.3, mix=0.1, brightness=14000, loudness=-12.0, headroom=5.0)


def shiokaze():
    """Sea Breeze: a lively marimba figure rolling around A minor, over a low marimba pulse."""
    loop = Loop(2.4)
    sequence(loop.track, Instruments.marimba,
             evenly(0.15, ("A4", "C5", "E5", "A5", "E5", "C5", "E5", "G5")), amplitude=0.75, tone=1.3)
    loop.track.marimba(1.2, "A5", 0.8, decay=0.5, tone=1.3)
    for start, pitch in ((0.0, "A3"), (0.6, "E3"), (1.2, "A3")):
        loop.track.marimba(start, pitch, 0.6, decay=0.45, tone=0.8)
    return loop.render(room=0.25, mix=0.08, brightness=14000, loudness=-11.0, headroom=6.0)


def kane():
    """Temple Bell: two firm bell chords with a struck piano octave beneath, left to ring."""
    loop = Loop(3.0)
    for start in (0.0, 0.55):
        for pitch, amplitude in (("A4", 0.7), ("E5", 0.5), ("A5", 0.35)):
            loop.track.bell(start, pitch, amplitude, decay=0.9, tone=1.5)
        loop.track.piano(start, "A3", 0.45, velocity=110, hold=0.9, release=0.3)
    return loop.render(room=0.5, mix=0.2, brightness=14000, loudness=-10.5, headroom=6.0)


def hibiki():
    """Echo: a bright synth pluck arpeggio up a C major chord over a bass pluck, echoes trailing behind."""
    loop = Loop(2.0)
    sequence(loop.track, Instruments.synth_pluck,
             evenly(0.1, ("C5", "E5", "G5", "C6", "G5", "E5", "G5", "C6")), amplitude=0.55, decay=0.3, tone=1.4)
    loop.track.synth_pluck(0.0, "C3", 0.7, decay=0.5, tone=1.0)
    return loop.render(room=0.25, mix=0.08, delay=(0.3, 0.3, 0.25), brightness=14000, loudness=-10.0,
                       headroom=11.0)


def tsubame():
    """Swallow: quick bell trills darting between two notes, doubled by a glockenspiel."""
    loop = Loop(1.6)
    trill = [(index * 0.06, "D6" if index % 2 == 0 else "A5") for index in range(9)]
    sequence(loop.track, Instruments.bell, trill, amplitude=0.55, decay=0.2, tone=1.6)
    sequence(loop.track, Instruments.glockenspiel, trill, amplitude=0.25, decay=0.2)
    return loop.render(room=0.2, mix=0.06, brightness=15000, loudness=-9.0, headroom=8.0)


def arashi():
    """Storm: a pair of rising digital beeps with a little harmonic edge."""
    loop = Loop(1.2)
    for start, pitch in ((0.0, "E6"), (0.16, "E6"), (0.32, "A6")):
        loop.track.beep(start, pitch, 0.1, 0.6, harmonics=3)
    return loop.render(brightness=16000, loudness=-8.0, headroom=14.0)


def hayate():
    """Gale: the classic alarm clock, four quick square-wave beeps and a breath."""
    loop = Loop(1.0)
    for index in range(4):
        loop.track.beep(index * 0.12, "A6", 0.07, 0.6, harmonics=5)
    return loop.render(brightness=16000, loudness=-7.0, headroom=14.0)


def kaminari():
    """Thunder: a relentless two-tone square-wave alarm, for mornings that cannot be missed."""
    loop = Loop(0.8)
    for index in range(6):
        loop.track.beep(index * 0.11, "C7" if index % 2 == 0 else "F#6", 0.09, 0.6, harmonics=6)
    return loop.render(brightness=16000, loudness=-6.0, headroom=10.0)


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
