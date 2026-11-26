# Ficha de navegación

`navegacion.wav` es el efecto original de ficha de Fat Fish (Anuma Games).
La receta procede de `GameAudio.Chip()`:

- Ruido con pasa altos a 2500 Hz, 35 ms, volumen 0.5.
- Triángulo con barrido 2200→1700 Hz, 30 ms, volumen 0.25.
- Tono central 1.0, sin la variación aleatoria de altura entre fichas del juego.

`tool/render_navigation_chip.py` compila el `GameSynth.cs` original del checkout
hermano y ejecuta su callback de mezcla con `tool/audio/RenderNavigationChip.cs`.
No abre Unity ni modifica sus archivos; usa un adaptador mínimo para las APIs de Unity.
Exporta solo los efectos, con el volumen del sintetizador estabilizado y su recorte
suave original. No contiene música, voces ni grabaciones de terceros.

Salida: mono, PCM16 a 22050 Hz, 80 ms (incluye el silencio final); no normaliza ni
recorta la envolvente. Ganancia de reproducción 1.0 antes del volumen de la app.

Fuente de mezcla: `fat-fish-game/Assets/Scripts/Audio/GameSynth.cs`.
SHA256: `052abbaaabd11342d98cd501af8d8ef76936eda1604324865f7f09dbbef1b34b`.
Receta: `fat-fish-game/Assets/Scripts/Audio/GameAudio.cs`, método `Chip`.

Regenerar con `python3 -I tool/render_navigation_chip.py` (.NET SDK 8+).
Si cambia la receta de `GameAudio.Chip()`, actualizar las dos notas del adaptador
antes de regenerar y revisar el sonido en teléfono.
