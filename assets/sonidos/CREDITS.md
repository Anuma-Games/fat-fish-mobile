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

## Efectos de mesa

Rodado, clics, caída y encendido: síntesis original de Fat Fish basada en la receta de
`sonido-mesa.ts` de la PWA. No contienen grabaciones de terceros. La misma herramienta
genera los WAV y aplica la ganancia por familia.
