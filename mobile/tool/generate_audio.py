#!/usr/bin/env python3
"""Procedural, original retro-modern game sounds (public-domain formulas only).

Pure Python stdlib, 16kHz mono PCM. No third-party samples or copyright assets.
Run: python3 tool/generate_audio.py
"""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1] / "assets" / "audio"
ROOT.mkdir(parents=True, exist_ok=True)
SAMPLE_RATE = 16000
TAU = 2 * math.pi

def write(name, seconds, sample):
    count = int(seconds * SAMPLE_RATE)
    target = ROOT / name
    with wave.open(str(target), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        for i in range(0, count, 4000):
            block = bytearray()
            for j in range(i, min(i + 4000, count)):
                t = j / SAMPLE_RATE
                value = max(-.98, min(.98, sample(t)))
                block.extend(struct.pack("<h", round(value * 32767)))
            wav.writeframes(block)
    print("created", target.name, target.stat().st_size)

# Calm, original 16-second major-key arpeggio, bass and soft pulse.
notes = [261.63, 329.63, 392, 523.25, 440, 392, 329.63, 293.66,
         349.23, 440, 523.25, 587.33, 523.25, 440, 392, 329.63]
def melody(t):
    phase = t % 16
    pos = int(phase * 2) % len(notes)
    note = notes[pos]
    beat = (phase * 2) % 1
    envelope = .12 + .88 * math.exp(-4.2 * beat)
    body = .13 * (math.sin(TAU * note * t) +
                  .24 * math.sin(TAU * note * 2 * t))
    bass_notes = [130.81, 174.61, 196.00, 146.83]
    bass = .13 * math.sin(TAU * bass_notes[int(phase / 4) % 4] * t)
    soft = .035 * math.sin(TAU * 1.5 * t) * math.sin(TAU * 783.99 * t)
    return envelope * body + bass + soft
write("menu_theme.wav", 16, melody)

# Looped rolling wheels and a rhythmic, slightly pitched electric engine.
rng = random.Random(20261113)
noise = [rng.uniform(-1, 1) for _ in range(16000)]
def rolling(t):
    p = t % 3.2
    click = (p * 3.75) % 1
    tick = .11 * math.exp(-48 * click) * math.sin(TAU * 260 * t)
    engine = .055 * math.sin(TAU * (60 + 6 * math.sin(.8 * t)) * t)
    rattle = .09 * noise[int(t * SAMPLE_RATE) % len(noise)] * (
        .5 + .5 * math.sin(TAU * 8.8 * t) ** 2)
    return tick + engine + rattle
write("train_wheels.wav", 3.2, rolling)

# Short, friendly two-tone horn.
def horn(t):
    e = min(1, t * 9) * min(1, (1.5 - t) * 5)
    e = max(0, e)
    f = 392 if t < .72 else 523.25
    return e * (.25 * math.sin(TAU * f * t) +
                .1 * math.sin(TAU * 2 * f * t))
write("train_horn.wav", 1.5, horn)

# Compact UI reward chime.
def chime(t):
    f = 523.25 if t < .22 else 659.25 if t < .43 else 783.99
    return .23 * math.exp(-4 * t) * math.sin(TAU * f * t)
write("success.wav", .75, chime)
