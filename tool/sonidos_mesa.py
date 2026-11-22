"""
Builds the sounds in assets/sonidos/: GameSynth instrumental music and roulette effects based
on sonido-mesa.ts in the PWA. The background runs the game's original C# callback offline;
the effects use the same oscillators, noise and filters as the PWA.

- ambiente.wav: calm GameSynth jazz, 86 BPM, four turns of its four-bar progression; no voices.
- rodado_agudo.wav, rodado_grave.wav: low wooden rumble of the wheel under the ball, low-passed
  at 380 and 180 Hz; the app crossfades them with the speed, as the PWA moves its filter.
- clic_<tono>_<n>.wav: the ball against a fret, a burst of noise around each tone the PWA uses
  (3600 Hz on the track down to 2700 Hz among the pockets, 1700 Hz for each bounce), in three
  takes each, as the PWA starts the noise at a random point every time.
- caida.wav: the ball settling in its pocket, a dull knock on wood and a last click.
- encendido.wav: the lamp switching on, a relay click and a short buzz.

The background needs .NET SDK 8+ and the sibling fat-fish-game checkout.
See render_gamesynth.py and assets/sonidos/CREDITS.md for the export and source.
Usage, from the root of the repository:
    python -I tool/sonidos_mesa.py
"""

import math
import os
import random
import struct
import subprocess
import sys
import wave

RATE = 22050
# Base synthesis level of the PWA; per-family makeup gain is applied at export.
MASTER = 0.7 * 2.5

random.seed(7)  # The same files every time


def noise(n):
    return [random.uniform(-1, 1) for _ in range(n)]


def biquad(kind, freq, q):
    """Coefficients of an RBJ cookbook filter, like the BiquadFilterNode of Web Audio."""
    w = 2 * math.pi * freq / RATE
    alpha = math.sin(w) / (2 * q)
    cos = math.cos(w)
    if kind == 'lowpass':
        b = [(1 - cos) / 2, 1 - cos, (1 - cos) / 2]
    else:  # bandpass, 0 dB peak
        b = [alpha, 0, -alpha]
    a = [1 + alpha, -2 * cos, 1 - alpha]
    return [x / a[0] for x in b], [x / a[0] for x in a]


def filtrar(signal, kind, freq, q=0.7071):
    (b0, b1, b2), (_, a1, a2) = biquad(kind, freq, q)
    out, x1, x2, y1, y2 = [], 0.0, 0.0, 0.0, 0.0
    for x in signal:
        y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        out.append(y)
        x2, x1, y2, y1 = x1, x, y1, y
    return out


def bucle(signal, kind, freq, q=0.7071):
    """Filters a noise buffer as if it repeated, so the loop has no click at the seam."""
    doble = filtrar(signal + signal, kind, freq, q)
    return doble[len(signal):]


def decaer(n, desde, hasta, segundos):
    """Exponential ramp like exponentialRampToValueAtTime, then held at the end value."""
    fin = int(segundos * RATE)
    return [
        desde * (hasta / desde) ** (i / fin) if i < fin else hasta for i in range(n)
    ]


def clic(fuerza, tono, n=None):
    n = n or int(0.05 * RATE)
    ruido = filtrar(noise(n), 'bandpass', tono, 5)
    gan = decaer(n, 0.32 * fuerza, 0.001, 0.035)
    return [r * g for r, g in zip(ruido, gan)]


def sumar(*senales):
    n = max(len(s) for s in senales)
    return [sum(s[i] for s in senales if i < len(s)) for i in range(n)]


def guardar(nombre, signal, gain=1):
    ruta = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'assets',
        'sonidos',
        nombre,
    )
    os.makedirs(os.path.dirname(ruta), exist_ok=True)
    escala = MASTER * gain
    pico = max(abs(x) for x in signal) * escala
    if pico > 0.85:
        escala *= 0.85 / pico  # Headroom for simultaneous sounds in the mixer
    with wave.open(ruta, 'wb') as archivo:
        archivo.setnchannels(1)
        archivo.setsampwidth(2)
        archivo.setframerate(RATE)
        archivo.writeframes(
            b''.join(
                struct.pack('<h', int(max(-1, min(1, x * escala)) * 32767))
                for x in signal
            )
        )
    print(f'{ruta}: {os.path.getsize(ruta)} bytes')


def rodado(freq):
    n = 2 * RATE
    return [x * 0.08 for x in bucle(noise(n), 'lowpass', freq)]


# Tones of the clicks; the app plays the nearest one.
TONOS = [3600, 3300, 3000, 2700, 1700]
TOMAS = 3


def caida():
    n = int(0.25 * RATE)
    fase, golpe = 0.0, []
    gan = decaer(n, 0.22, 0.001, 0.2)
    for i in range(n):
        t = i / RATE
        freq = 190 * (85 / 190) ** min(1, t / 0.12)
        fase += freq / RATE
        triangulo = 4 * abs(fase - math.floor(fase + 0.5)) - 1
        golpe.append(triangulo * gan[i] if t < 0.22 else 0.0)
    return sumar(golpe, clic(0.5, 2200))


def encendido():
    n = int(0.75 * RATE)
    fase, sierra = 0.0, []
    for i in range(n):
        fase += 120 / RATE
        sierra.append(2 * (fase - math.floor(fase + 0.5)))
    zumbido = filtrar(sierra, 'bandpass', 1800, 2)
    gan = []
    for i in range(n):
        t = i / RATE
        if t < 0.02:
            g = 0.0
        elif t < 0.12:
            g = 0.05
        elif t < 0.2:
            g = 0.01
        else:
            g = 0.05 * (0.0001 / 0.05) ** min(1, (t - 0.2) / 0.5)
        gan.append(g)
    return sumar(clic(0.8, 3000), [z * g for z, g in zip(zumbido, gan)])


if __name__ == '__main__':
    subprocess.run([sys.executable, '-I',
                    os.path.join(os.path.dirname(__file__), 'render_gamesynth.py')], check=True)
    guardar('rodado_agudo.wav', rodado(380), gain=5)
    guardar('rodado_grave.wav', rodado(180), gain=5)
    for tono in TONOS:
        for toma in range(1, TOMAS + 1):
            # Full strength: the app scales each click by its own strength.
            guardar(f'clic_{tono}_{toma}.wav', clic(1.0, tono), gain=3)
    guardar('caida.wav', caida(), gain=1.5)
    guardar('encendido.wav', encendido(), gain=3)
