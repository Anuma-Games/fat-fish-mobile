"""Copy the game's recorded roulette bank unchanged. No synthesis or normalization.

Usage: python3 -I tool/import_roulette.py [--source /path/to/Audio/Roulette]
"""

import argparse
from pathlib import Path
import shutil


def main():
    root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=(
        root.parent / 'fat-fish-game/Assets/Resources/Audio/Roulette'))
    source = parser.parse_args().source
    names = ['roll.wav', 'launch.wav', 'settle.wav'] + [
        f'hit_{i:02}.wav' for i in range(1, 15)]
    for name in names:
        if not (source / name).is_file():
            parser.error(f'Missing recording: {source / name}')
    target = root / 'assets/sonidos/roulette'
    target.mkdir(parents=True, exist_ok=True)
    for name in names:
        shutil.copyfile(source / name, target / name)
    print(f'Imported {len(names)} original recordings to {target}')


if __name__ == '__main__':
    main()
