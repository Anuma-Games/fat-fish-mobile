"""
Generates assets/fonts/FatFishPixel-Regular.ttf: Press Start 2P with the Spanish accented capitals
(Á É Í Ó Ú Ñ Ü) drawn at full height, the accent above, one pixel apart. The same fix as
scripts/fuente-acentos.py in the PWA.

Press Start 2P squeezes those letters into its 8 x 8 grid so the accent fits, so in the uppercase
pixel labels they look like lowercase letters ("SIN CONEXIóN"). The PWA loads a font with only those
seven letters through unicode-range; Flutter has no unicode-range, so here the whole font is copied
with the seven letters redrawn. The line metrics stay the same, so no label changes its height: the
raised accents draw above the line, as they do in the PWA.

Source: PressStart2P-Regular.ttf (SIL Open Font License 1.1). The derived font gets its own name,
because "Press Start 2P" is a Reserved Font Name.

Usage (needs fontTools; run it from the root of the repository):
    python -I tool/fuente_pixel.py assets/fonts/PressStart2P-Regular.ttf
"""

import os
import sys

from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

PIXEL = 125  # One pixel of the 8 x 8 grid in font units (1000 per em)
NOMBRE = 'Fat Fish Pixel'
# Accented capital -> (base letter, accent glyph, how many pixels the accent moves up)
LETRAS = {
    'Á': ('A', 'acute', 3),
    'É': ('E', 'acute', 3),
    'Í': ('I', 'acute', 3),
    'Ó': ('O', 'acute', 3),
    'Ú': ('U', 'acute', 3),
    'Ñ': ('N', 'tilde', 3),
    'Ü': ('U', 'dieresis', 2),
}


def main(origen: str, destino: str) -> None:
    fuente = TTFont(origen)
    glyf = fuente['glyf']
    glyphs = fuente.getGlyphSet()
    cmap = fuente.getBestCmap()

    for letra, (base, acento, subir) in LETRAS.items():
        pen = TTGlyphPen(glyphs)
        glyphs[base].draw(pen)
        glyphs[acento].draw(TransformPen(pen, (1, 0, 0, 1, 0, subir * PIXEL)))
        glifo = pen.glyph()
        glifo.recalcBounds(glyf)
        glyf[cmap[ord(letra)]] = glifo

    fuente['head'].yMax = max(fuente['head'].yMax, max(
        glyf[cmap[ord(letra)]].yMax for letra in LETRAS
    ))

    nombres = fuente['name']
    for registro in list(nombres.names):
        if registro.nameID in (1, 3, 4, 6, 16, 17):
            nombres.removeNames(nameID=registro.nameID)
    for id_, valor in (
        (1, NOMBRE),
        (2, 'Regular'),
        (3, f'{NOMBRE} Regular'),
        (4, f'{NOMBRE} Regular'),
        (6, NOMBRE.replace(' ', '') + '-Regular'),
    ):
        nombres.setName(valor, id_, 3, 1, 0x409)
    nombres.setName(
        'Derived from Press Start 2P (CodeMan38): Spanish accented capitals at full height.',
        10,
        3,
        1,
        0x409,
    )

    fuente.save(destino)
    print(f'{destino}: {os.path.getsize(destino)} bytes')


if __name__ == '__main__':
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    main(sys.argv[1], os.path.join(raiz, 'assets', 'fonts', 'FatFishPixel-Regular.ttf'))
