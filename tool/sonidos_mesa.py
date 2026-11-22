"""
Builds the sounds in assets/sonidos/: a recorded backroom ambience and roulette effects based
on sonido-mesa.ts in the PWA. Flutter renders the effects once to WAV with the same oscillators,
noise and filters instead of using the Web Audio API.

- ambiente.wav: muffled pub recording with sparse wooden creaks; seamless backroom loop.
- rodado_agudo.wav, rodado_grave.wav: low wooden rumble of the wheel under the ball, low-passed
  at 380 and 180 Hz; the app crossfades them with the speed, as the PWA moves its filter.
- clic_<tono>_<n>.wav: the ball against a fret, a burst of noise around each tone the PWA uses
  (3600 Hz on the track down to 2700 Hz among the pockets, 1700 Hz for each bounce), in three
  takes each, as the PWA starts the noise at a random point every time.
- caida.wav: the ball settling in its pocket, a dull knock on wood and a last click.
- encendido.wav: the lamp switching on, a relay click and a short buzz.

The ambience source is tool/audio/quiet_bar.mp3 (alexftw123, CC0; see assets/sonidos/CREDITS.md).
It needs ffmpeg, or macOS afconvert, to decode the source. Processing uses the standard library.
Usage, from the root of the repository:
    python -I tool/sonidos_mesa.py
"""

import math
import array
import os
import random
import shutil
import struct
import subprocess
import tempfile
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


def ambiente():
    source = os.path.join(os.path.dirname(__file__), 'audio', 'quiet_bar.mp3')
    with tempfile.TemporaryDirectory() as folder:
        decoded = os.path.join(folder, 'quiet_bar.wav')
        if shutil.which('ffmpeg'):
            command = ['ffmpeg', '-v', 'error', '-nostdin', '-y', '-i', source,
                       '-ar', str(RATE), '-ac', '1', '-c:a', 'pcm_s16le', decoded]
        elif shutil.which('afconvert'):
            command = ['afconvert', '-f', 'WAVE', '-d', f'LEI16@{RATE}', '-c', '1', source, decoded]
        else:
            raise RuntimeError('Install ffmpeg to regenerate the recorded ambience.')
        subprocess.run(command, check=True)
        with wave.open(decoded, 'rb') as recording:
            pcm = array.array('h', recording.readframes(recording.getnframes()))
    signal = [sample / 32768 for sample in pcm]
    # Behind a closed door: remove machinery/bass and soften clear consonants.
    muffled = filtrar(signal, 'lowpass', 1450)
    bass = filtrar(muffled, 'lowpass', 140)
    signal = [voice - low for voice, low in zip(muffled, bass)]
    # Keep occasional glass hits from determining the level of the whole room.
    envelope = 0.0
    compressed = []
    attack, release = math.exp(-1 / (0.005 * RATE)), math.exp(-1 / (0.12 * RATE))
    for sample in signal:
        coefficient = attack if abs(sample) > envelope else release
        envelope = coefficient * envelope + (1 - coefficient) * abs(sample)
        gain = (0.02 / envelope) ** (2 / 3) if envelope > 0.02 else 1
        compressed.append(sample * gain)
    rms = math.sqrt(sum(x * x for x in compressed) / len(compressed))
    gain = min(0.12 / rms, 0.60 / max(abs(x) for x in compressed))
    signal = [sample * gain for sample in compressed]
    # Small, irregular wood-friction details, well below the voices/glasses.
    rng = random.Random(184)
    for start, tone in [(7.3, 260), (19.7, 190), (36.4, 230), (49.1, 170)]:
        count = int(0.38 * RATE)
        grain = filtrar([rng.uniform(-1, 1) for _ in range(count)], 'bandpass', tone, 2)
        for i, sample in enumerate(grain):
            envelope = math.sin(math.pi * i / count) ** 2
            signal[int(start * RATE) + i] += sample * envelope * 0.035
    # Overlap the last three seconds with the opening; no silent gap at wrap.
    fade = 3 * RATE
    loop = signal[fade:]
    for i in range(fade):
        angle = i / (fade - 1) * math.pi / 2
        loop[len(loop) - fade + i] = signal[len(signal) - fade + i] * math.cos(angle) + signal[i] * math.sin(angle)
    return loop


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
    guardar('ambiente.wav', ambiente(), gain=1 / MASTER)
    guardar('rodado_agudo.wav', rodado(380), gain=5)
    guardar('rodado_grave.wav', rodado(180), gain=5)
    for tono in TONOS:
        for toma in range(1, TOMAS + 1):
            # Full strength: the app scales each click by its own strength.
            guardar(f'clic_{tono}_{toma}.wav', clic(1.0, tono), gain=3)
    guardar('caida.wav', caida(), gain=1.5)
    guardar('encendido.wav', encendido(), gain=3)
