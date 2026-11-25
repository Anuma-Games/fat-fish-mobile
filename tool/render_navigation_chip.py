"""Render the game's actual GameSynth callback to the navigation chip WAV.

Requires .NET SDK 8+ and the sibling fat-fish-game checkout. No Unity editor or
third-party Python packages are needed. Run from the mobile repository root:
    python3 -I tool/render_navigation_chip.py
"""

import argparse
import array
import hashlib
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
        shutil.copyfile(root / 'tool/audio/RenderNavigationChip.cs', work / 'Program.cs')
        (work / 'Render.csproj').write_text(
            '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'
            '<OutputType>Exe</OutputType>'
            f'<TargetFramework>net{major}.0</TargetFramework>'
            '<NuGetAudit>false</NuGetAudit>'
            '</PropertyGroup></Project>')
        env = dict(os.environ, DOTNET_CLI_TELEMETRY_OPTOUT='1', DOTNET_NOLOGO='1')
        subprocess.run([dotnet, 'build', str(work / 'Render.csproj'), '-c', 'Release',
                        '--ignore-failed-sources', '-v', 'quiet'], env=env, check=True)
        pcm = work / 'chip.f32'
        subprocess.run([dotnet, str(work / f'bin/Release/net{major}.0/Render.dll'),
                        str(pcm)], env=env, check=True)
        samples = array.array('f', pcm.read_bytes())
        if sys.byteorder != 'little':
            samples.byteswap()

    # Preserve the game's level and envelope; no looping or normalization.
    peak = max(abs(sample) for sample in samples)
    if peak >= 1: raise ValueError('Chip export clips')
    pcm16 = array.array('h', (round(sample * 32767) for sample in samples))
    if sys.byteorder != 'little': pcm16.byteswap()
    target = root / 'assets/sonidos/navegacion.wav'
    with wave.open(str(target), 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(22050)
        output.writeframes(pcm16.tobytes())
    print(f'{target}: {len(samples) / 22050:.3f} s; peak={peak:.4f}; '
          f'source SHA256={hashlib.sha256(source.read_bytes()).hexdigest()}')


if __name__ == '__main__':
    main()
