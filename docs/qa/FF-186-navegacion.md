# FF-186: sonido de ficha al cambiar de sección

## Implementación

- Rama `feature/FF-186-sonido-navegacion`, desde `develop` (`f151d90`).
- Recurso `assets/sonidos/navegacion.wav`: efecto original `GameAudio.Chip()` mezclado
  por el `GameSynth.cs` del juego. Ver receta y procedencia en `assets/sonidos/NAVEGACION.md`.
- Un evento por selección confirmada de otra sección, tanto por toque como al soltar
  un gesto. No se dispara al iniciar la app ni al mover el dedo sobre las fichas.
- Tocar la sección activa conserva la pantalla abierta; el filtro de selección pendiente
  evita duplicar sonidos con toques repetidos antes del siguiente fotograma.
- Se limpia la previsualización al recibir cancelación de puntero: Flutter puede llamar
  `onHorizontalDragEnd` incluso al cancelar un gesto que ya reconoció.
- Incluye la redirección de Expediente a la bienvenida cuando no hay jugador elegido.
- Usa `TableSound`, los ajustes y el ciclo de vida existentes. La voz corta se detiene
  al pausar, apagar los efectos o poner volumen cero; el volumen cambia también si
  todavía está sonando.

## Pruebas

Formato y análisis estático correctos; 175 pruebas del proyecto aprobadas.
La navegación por toque/gesto, la selección activa, el toque rápido repetido, la
cancelación y el gesto que vuelve a su origen se comprueban en `app_shell_test.dart`.
El APK normal se compila con `flutter build apk --debug --no-pub -t lib/main.dart`.

## Motor real en Android

Emulador Medium Phone, Android 13; captura del mezclador nativo SoLoud en PCM float32,
44 100 Hz estéreo, con el ambiente apagado para aislar la ficha.

| Escenario | Pico | RMS |
|---|---:|---:|
| Volumen 60 % | 0.09582 | 0.00517 |
| Volumen 100 % | 0.15971 | 0.00885 |
| App pausada | 0 | 0 |
| Volumen cero | 0 | 0 |
| Efectos apagados | 0 | 0 |
| Reanudar al 60 % | 0.09582 | 0.00517 |

El inicio con sonidos apagados no inicializa el motor. Tras pausar, apagar efectos o
poner volumen cero se comprobó inmediatamente que no quedaban voces activas; se dejó
vaciar el búfer 100 ms antes de medir el silencio. El pico de 100 % es 1.667 veces el de
60 %, sin saturación. Son mediciones digitales, anteriores al volumen físico del teléfono.

WAV fuente: mono PCM16, 22 050 Hz, 1764 muestras (80 ms), pico 0.22586.
SHA256: `ee928f699485630feb8b396fc85a3519f39b7b8ffe08f2270c119947a7d0aefa`.
La muestra de escucha repite la ficha tres veces con separación; la app dispara una sola toma.

## Revisión en teléfono

1. Activar Sonidos de la mesa, elegir 60 % de volumen y alternar las tres secciones.
2. Repetir el toque sobre la sección activa y confirmar que no hay otro sonido.
3. Deslizar sin soltar, cancelar y volver al origen: no debe sonar; soltar sobre otra
   sección debe producir una sola ficha.
4. Repetir con efectos apagados, volumen cero y después de enviar la app al fondo.
5. Valorar el timbre y volumen desde el teléfono antes de aprobar el cambio.

Esta validación parte de `develop`: FF-184 permanece en el PR #25. Al integrarse ambos
cambios, resolver el punto de carga del nuevo WAV y conservar el volumen maestro y la
pausa global de FF-184; no sustituirlos por el control de volumen de la base anterior.
