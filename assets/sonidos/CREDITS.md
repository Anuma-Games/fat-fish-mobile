# Créditos de audio

## Música instrumental

Música original de Fat Fish, generada por `GameSynth.cs` de Anuma Games.
Fuente: `fat-fish-game/Assets/Scripts/Audio/GameSynth.cs`.

Exportación: `tool/render_gamesynth.py` ejecuta el callback original con un adaptador C#
(`tool/audio/RenderGameSynth.cs`), sin abrir Unity ni modificar el repositorio del juego.

Configuración: tensión 0, sin jefe ni efectos de ruleta, 86 BPM, swing 0.64,
progresión Am7–Dm7–Bbmaj7–E7(b9), bajo caminante, acordes, escobillas y vibráfono.
Semilla 184 para que los acentos musicales sean reproducibles. Cuatro vueltas de cuatro
compases (44.651 s), con una pasada de los mismos 16 compases para estabilizar las colas
y el volumen antes de la captura.

El WAV es mono, PCM de 16 bits a 22 050 Hz. Se ajusta su nivel con un pico máximo de 0.60
y se suaviza la unión del bucle durante 5 ms, conservando la duración de los compases.
No contiene voces, grabaciones de pub ni música de terceros.

## Ruleta

Grabaciones copiadas sin modificaciones desde
`fat-fish-game/Assets/Resources/Audio/Roulette`, con `tool/import_roulette.py`:

- `roll.wav`, `launch.wav`, `hit_01.wav` a `hit_14.wav`: recortes usados por el juego de
  **roulette_casino_evian.aif**, f_ilippo, Casino de Evian.
  Fuente: https://freesound.org/people/f_ilippo/sounds/59194/
- `settle.wav`: **Casino_RouletteSound_ball-damping**, poenia.
  Fuente: https://freesound.org/people/poenia/sounds/709623/

Ambas fuentes se publican bajo **CC0 1.0**, según sus páginas de Freesound.
Licencia: https://creativecommons.org/publicdomain/zero/1.0/

La app conserva las ganancias de golpes de `RouletteSound.cs` (golpes 0.6;
lanzamiento 0.7×golpes; asentamiento 0.6×golpes) y la variación de tono en impactos.
El rodado usa una ganancia máxima de 0.35, velocidad natural fija y un desvanecimiento
al bajar del borde hacia las casillas. No sintetiza los sonidos de la ruleta.

## Encendido de la lámpara

Síntesis original de Fat Fish basada en `sonido-mesa.ts` de la PWA. Se regenera con
`tool/sonidos_mesa.py`; no contiene grabaciones de terceros.
