#!/usr/bin/env python3
"""Builds Folio's alarm sounds, ten of them, from a mellow touch to an alarm that can't be slept through.

Usage: python3 generate_alarms.py <output directory> [Alarm-Name ...]

Every note is a recorded instrument from Logic Pro's sound library (see logic_samples.py), which has to be
installed: vibraphone, African marimba, Steinway, glockenspiel, kalimba, music box, glass xylophone,
electric piano, fairytale bells and a rattling alarm bell. Roots of the single notes were measured, since
Logic names notes an octave low (middle C is C3) and one recording holds several strikes.

Each sound is one short phrase repeated to just under 30 seconds, since AlarmKit is reported to stop custom
sounds at about that length. The phrase is rendered as a steady loop, with its reverb and echo tails folded
back onto its start, so the repeats run on seamlessly and the file also loops cleanly if the system repeats it.

Sounds get brighter and busier through the list, but every one is mastered to the same perceived loudness
(LOUDNESS, in LUFS) with a limiter, so switching sounds never changes the volume, only the character. Written at 44.1 kHz as 16-bit linear PCM, like the
notification sounds, with generate.py's encoder.
"""

import math
import os
import sys

import generate
import logic_samples
from generate import SAMPLE_RATE, Track, echo, highpass, lowpass, reverb
from logic_samples import Multisample, OneShot

CEILING = 10 ** (-1.2 / 20)
MAXIMUM_LENGTH = 29.0
LOUDNESS = -11.0

VIBRAPHONE = Multisample("Mallet/Vibraphone.exs", "Mallet/Vibraphone_consolidated.caf")
MARIMBA = Multisample("Mallet/African Marimba.exs", "Mallet/African Marimba_consolidated.caf")
GLOCKENSPIEL = OneShot("Alchemy Samples/Mallets/Metal Mallets/Glockenspiel 03.caf", 91.85, end=1.0)
KALIMBA = OneShot("Alchemy Samples/Mallets/Wooden Mallets/Kalimba/Kalimba C4.caf", 72)
MUSIC_BOX = OneShot("Mallet/Toy Music Box.aif", 84.02)
FAIRYTALE_BELLS = OneShot("Synthesizer/Keys/Fairytales Bells Sample.aif", 90.04)
RATTLING_BELL = OneShot("Mallet/Rattling Bell Decay.aif", 72)
ELECTRIC_PIANO_LOW = OneShot("Alchemy Samples/Keys/Electric Pianos/EPiano Mrk 1/EPiano Mrk 1 C3.caf", 60)
ELECTRIC_PIANO_HIGH = OneShot("Alchemy Samples/Keys/Electric Pianos/EPiano Mrk 1/EPiano Mrk 1 F#4.caf", 78)


class AlarmTrack(Track):
    """Places recorded notes, each scaled to the same peak so amplitude alone sets the balance."""

    def play(self, instrument, start, pitch, amplitude=1.0, velocity=100, take=0, hold=None, release=0.1):
        """Plays the note at pitch, or at the recording's own pitch when pitch is None."""
        key = logic_samples.key_number(pitch) if pitch else None
        length = hold + release * 6 if hold else None
        recording = logic_samples.normalized(instrument.note(key, velocity, take, length))
        first = int(start * SAMPLE_RATE)
        held = int(hold * SAMPLE_RATE) if hold else len(recording)
        fall = release * SAMPLE_RATE
        for index, value in enumerate(recording[:max(0, len(self) - first)]):
            damper = 1.0 if index < held else math.exp(-(index - held) / fall)
            self.samples[first + index] += amplitude * damper * value

    def piano(self, start, pitch, amplitude=1.0, velocity=100, hold=0.45, release=0.08):
        """The Steinway from generate.py, which handles that instrument's damper zones."""
        key = logic_samples.key_number(pitch)
        recording = generate.SampledPiano.shared().note(key, velocity)
        loudest = max(abs(value) for value in recording) or 1
        first = int(start * SAMPLE_RATE)
        held = int(hold * SAMPLE_RATE)
        for index, value in enumerate(recording[:max(0, len(self) - first)]):
            damper = 1.0 if index < held else math.exp(-(index - held) / (release * SAMPLE_RATE))
            if damper < 1e-4:
                break
            self.samples[first + index] += amplitude * damper * value / loudest

    def electric_piano(self, start, pitch, amplitude=1.0, hold=None, release=0.1):
        key = logic_samples.key_number(pitch)
        instrument = ELECTRIC_PIANO_LOW if abs(key - 60) < abs(key - 78) else ELECTRIC_PIANO_HIGH
        self.play(instrument, start, pitch, amplitude, hold=hold, release=release)


class Loop:
    """Renders a phrase as one period of a seamless loop and repeats it to fill the file."""

    def __init__(self, period, tail=3.0):
        self.period = period
        self.track = AlarmTrack(period + tail)

    def render(self, room=0.0, mix=0.0, damping=0.5, delay=None, brightness=12000, release=0.08):
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
        cycle = master(lowpass(highpass(folded * 4, 180), brightness), length, release)
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


def biquad(samples, numerator, denominator):
    b0, b1, b2 = (value / denominator[0] for value in numerator)
    a1, a2 = denominator[1] / denominator[0], denominator[2] / denominator[0]
    output = [0.0] * len(samples)
    x1 = x2 = y1 = y2 = 0.0
    for index, value in enumerate(samples):
        result = b0 * value + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1, y2, y1 = x1, value, y1, result
        output[index] = result
    return output


def loudness(samples):
    """Perceived loudness in LUFS, as ITU-R BS.1770 measures it: K-weighted (a high shelf for how the head
    hears treble, and a low cut), averaged over 400 ms blocks, with quiet blocks gated out."""
    gain, quality, frequency = 3.99984385397, 0.7071752369554193, 1681.9744509555319
    shelf = 10 ** (gain / 40)
    angle = 2 * math.pi * frequency / SAMPLE_RATE
    cosine, alpha = math.cos(angle), math.sin(angle) / (2 * quality)
    slope = 2 * math.sqrt(shelf) * alpha
    weighted = biquad(samples,
                      [shelf * ((shelf + 1) + (shelf - 1) * cosine + slope),
                       -2 * shelf * ((shelf - 1) + (shelf + 1) * cosine),
                       shelf * ((shelf + 1) + (shelf - 1) * cosine - slope)],
                      [(shelf + 1) - (shelf - 1) * cosine + slope,
                       2 * ((shelf - 1) - (shelf + 1) * cosine),
                       (shelf + 1) - (shelf - 1) * cosine - slope])
    quality, frequency = 0.5003270373253953, 38.13547087613982
    angle = 2 * math.pi * frequency / SAMPLE_RATE
    cosine, alpha = math.cos(angle), math.sin(angle) / (2 * quality)
    weighted = biquad(weighted, [(1 + cosine) / 2, -(1 + cosine), (1 + cosine) / 2],
                      [1 + alpha, -2 * cosine, 1 - alpha])
    size = int(0.4 * SAMPLE_RATE)
    blocks = [sum(value * value for value in weighted[start:start + size]) / size
              for start in range(0, len(weighted) - size + 1, size // 4)]

    def level(power):
        return -0.691 + 10 * math.log10(power)

    blocks = [power for power in blocks if power > 0 and level(power) > -70]
    gate = level(sum(blocks) / len(blocks)) - 10
    blocks = [power for power in blocks if level(power) > gate]
    return level(sum(blocks) / len(blocks))


def master(samples, length, release):
    """Sets the steady loop to the shared loudness, with the limiter holding peaks under the ceiling, so every
    sound plays at the same perceived volume and only its character sets how urgent it feels. A shorter release
    lets urgent sounds keep their attack. Runs over several repeats so the limiter has settled by the cycle
    that is kept, and measures two cycles so the meter's blocks wrap around the loop."""
    gain = CEILING / (max(abs(value) for value in samples) or 1)
    for _ in range(12):
        limited = limit(samples, gain, release)
        difference = LOUDNESS - loudness(limited[-2 * length:])
        if abs(difference) < 0.1:
            break
        gain *= 10 ** (max(-6.0, min(6.0, difference)) / 20)
    return limited[-length:]


def evenly(spacing, pitches, offset=0.0):
    return [(offset + index * spacing, pitch) for index, pitch in enumerate(pitches)]


def sequence(track, instrument, notes, **options):
    for take, (start, pitch) in enumerate(notes):
        track.play(instrument, start, pitch, take=take, **options)


def yoake():
    """Daybreak: a Steinway slowly opening up an F major ninth, with a vibraphone glowing on top."""
    loop = Loop(4.8)
    for start, pitch in evenly(0.38, ("F3", "C4", "F4", "A4", "C5", "E5", "G5")):
        loop.track.piano(start, pitch, 0.7, velocity=70, hold=2.4, release=0.4)
    loop.track.play(VIBRAPHONE, 2.28, "G5", 0.35, velocity=60)
    loop.track.play(VIBRAPHONE, 2.28, "E5", 0.25, velocity=60)
    return loop.render(room=0.6, mix=0.15, brightness=14000)


def komorebi():
    """Dappled Light: a kalimba lullaby rising and falling onto a soft vibraphone chord."""
    loop = Loop(3.6)
    sequence(loop.track, KALIMBA, evenly(0.24, ("C5", "E5", "G5", "E5", "D5", "G5")), amplitude=0.8)
    for pitch, amplitude in (("C5", 0.5), ("E5", 0.45), ("G5", 0.4)):
        loop.track.play(VIBRAPHONE, 1.44, pitch, amplitude, velocity=70)
    loop.track.play(KALIMBA, 1.44, "C5", 0.7)
    return loop.render(room=0.45, mix=0.12, brightness=14000)


def hibari():
    """Skylark: a music box trilling up a G major chord, twice, with a glockenspiel sparkle."""
    loop = Loop(3.2)
    for offset in (0.0, 0.9):
        sequence(loop.track, MUSIC_BOX, evenly(0.11, ("G5", "B5", "D6", "G6"), offset), amplitude=0.7)
        loop.track.play(GLOCKENSPIEL, offset + 0.44, "B6", 0.5)
    loop.track.play(VIBRAPHONE, 0.0, "G4", 0.35, velocity=70)
    return loop.render(room=0.3, mix=0.1, brightness=15000)


def shiokaze():
    """Sea Breeze: a lively African marimba figure rolling around A minor, over a low marimba pulse."""
    loop = Loop(2.4)
    sequence(loop.track, MARIMBA, evenly(0.15, ("A4", "C5", "E5", "A5", "E5", "C5", "E5", "G5")),
             amplitude=0.8, velocity=100)
    loop.track.play(MARIMBA, 1.2, "A5", 0.85, velocity=110)
    for take, (start, pitch) in enumerate(((0.0, "A3"), (0.6, "E3"), (1.2, "A3"))):
        loop.track.play(MARIMBA, start, pitch, 0.7, velocity=100, take=take)
    return loop.render(room=0.25, mix=0.06, brightness=15000)


def kane():
    """Temple Bell: two chords of fairytale bells over a firmly struck Steinway octave, left to ring."""
    loop = Loop(3.0)
    for start in (0.0, 0.55):
        for pitch, amplitude in (("A5", 0.6), ("E6", 0.45), ("C#6", 0.3)):
            loop.track.play(FAIRYTALE_BELLS, start, pitch, amplitude)
        loop.track.piano(start, "A2", 0.4, velocity=110, hold=1.2, release=0.3)
        loop.track.piano(start, "A3", 0.35, velocity=110, hold=1.2, release=0.3)
    return loop.render(room=0.5, mix=0.12, brightness=15000)


def hibiki():
    """Echo: an electric piano arpeggio up a C major chord over a low root, echoes trailing behind."""
    loop = Loop(2.0)
    for start, pitch in evenly(0.1, ("C5", "E5", "G5", "C6", "G5", "E5", "G5", "C6")):
        loop.track.electric_piano(start, pitch, 0.6, hold=0.18, release=0.08)
    loop.track.electric_piano(0.0, "C3", 0.8, hold=0.9, release=0.2)
    return loop.render(room=0.25, mix=0.06, delay=(0.3, 0.3, 0.25), brightness=15000)


def tsubame():
    """Swallow: quick trills darting between two notes on glockenspiel and music box."""
    loop = Loop(1.6)
    trill = [(index * 0.06, "D6" if index % 2 == 0 else "A5") for index in range(9)]
    sequence(loop.track, GLOCKENSPIEL, trill, amplitude=0.6, hold=0.12, release=0.1)
    sequence(loop.track, MUSIC_BOX, trill, amplitude=0.5, hold=0.12, release=0.1)
    return loop.render(room=0.2, mix=0.05, brightness=16000, release=0.04)


def arashi():
    """Storm: a hard-struck marimba and glockenspiel calling a rising figure, again and again."""
    loop = Loop(1.2)
    for take, (start, pitch) in enumerate(((0.0, "E6"), (0.16, "E6"), (0.32, "A6"))):
        loop.track.play(MARIMBA, start, pitch, 0.9, velocity=127, take=take)
        loop.track.play(GLOCKENSPIEL, start, pitch, 0.55, hold=0.2, release=0.08)
    return loop.render(room=0.15, mix=0.04, brightness=16000, release=0.03)


def hayate():
    """Gale: a real alarm bell ringing in bursts, like an old wind-up alarm clock."""
    loop = Loop(1.2)
    loop.track.play(RATTLING_BELL, 0.0, None, 1.0, hold=0.7, release=0.04)
    return loop.render(brightness=16000, release=0.025)


def kaminari():
    """Thunder: a relentless two-tone alarm on glockenspiel and music box over a ringing alarm bell."""
    loop = Loop(0.8)
    for index in range(6):
        pitch = "C7" if index % 2 == 0 else "F#6"
        start = index * 0.11
        loop.track.play(GLOCKENSPIEL, start, pitch, 0.7, hold=0.09, release=0.03)
        loop.track.play(MUSIC_BOX, start, pitch, 0.5, hold=0.09, release=0.03)
    loop.track.play(RATTLING_BELL, 0.0, None, 0.5, hold=0.62, release=0.04)
    return loop.render(brightness=16000, release=0.02)


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
