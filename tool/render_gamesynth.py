"""Render the game's actual GameSynth callback to the mobile background WAV.

Requires .NET SDK 8+ and the sibling fat-fish-game checkout. No Unity editor or
third-party Python packages are needed. Run from the mobile repository root:
    python3 -I tool/render_gamesynth.py
"""

import argparse
import array
import hashlib
import math
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import wave


def main():
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=(
        root.parent / 'fat-fish-game/Assets/Scripts/Audio/GameSynth.cs'))
    args = parser.parse_args()
    source = args.source.resolve()
    if not source.is_file():
        parser.error(f'GameSynth.cs not found: {source}; pass --source with its path.')
    dotnet = shutil.which('dotnet')
    if not dotnet:
        parser.error('Install .NET SDK 8+ to render GameSynth.')
    sdks = subprocess.check_output([dotnet, '--list-sdks'], text=True)
    major = max((int(line.split('.')[0]) for line in sdks.splitlines()), default=0)
    if major < 8:
        parser.error('Install .NET SDK 8+ to render GameSynth.')

    with tempfile.TemporaryDirectory(prefix='fat-fish-gamesynth-') as folder:
        work = Path(folder)
        # Compile the source unchanged; the host supplies only Unity API stubs.
        shutil.copyfile(source, work / 'GameSynth.cs')
        shutil.copyfile(root / 'tool/audio/RenderGameSynth.cs', work / 'Program.cs')
        (work / 'Render.csproj').write_text(
            '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'
            '<OutputType>Exe</OutputType>'
            f'<TargetFramework>net{major}.0</TargetFramework>'
            '<NuGetAudit>false</NuGetAudit>'
            '</PropertyGroup></Project>')
        env = dict(os.environ, DOTNET_CLI_TELEMETRY_OPTOUT='1', DOTNET_NOLOGO='1')
        subprocess.run([dotnet, 'build', str(work / 'Render.csproj'), '-c', 'Release',
                        '--ignore-failed-sources', '-v', 'quiet'], env=env, check=True)
        pcm = work / 'music.f32'
        subprocess.run([dotnet, str(work / f'bin/Release/net{major}.0/Render.dll'),
                        str(pcm)], env=env, check=True)
        samples = array.array('f', pcm.read_bytes())
        if sys.byteorder != 'little':
            samples.byteswap()

    # The final tail is naturally close to the opening after phrase warm-up.
    # Spread any remaining boundary offset over 5 ms without shortening the bars.
    boundary = samples[-1] - samples[0]
    ramp = round(0.005 * 22050)
    for i in range(ramp):
        samples[i] += boundary * (0.5 + 0.5 * math.cos(math.pi * i / (ramp - 1)))
    peak = max(abs(sample) for sample in samples)
    rms = math.sqrt(sum(sample * sample for sample in samples) / len(samples))
    gain = min(0.10 / rms, 0.60 / peak)
    pcm16 = array.array('h', (round(sample * gain * 32767) for sample in samples))
    if sys.byteorder != 'little':
        pcm16.byteswap()
    target = root / 'assets/sonidos/ambiente.wav'
    with wave.open(str(target), 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(22050)
        output.writeframes(pcm16.tobytes())
    print(f'{target}: {len(samples) / 22050:.3f} s; peak={peak * gain:.4f}; '
          f'RMS={rms * gain:.4f}; source SHA256={hashlib.sha256(source.read_bytes()).hexdigest()}')


if __name__ == '__main__':
    main()
