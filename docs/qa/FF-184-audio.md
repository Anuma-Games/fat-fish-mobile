# FF-184: validación de audio

## Entorno y niveles

- Emulador Android **Medium Phone**, Android **13**.
- Volumen multimedia del sistema: **8 de 15**.
- Volumen de la app: **6 de 10**, **10 de 10** y **0 de 10**.
- Motor real SoLoud con los WAV empaquetados; captura PCM del mezclador a su frecuencia y canales nativos (44 100 Hz/estéreo).
- La captura digital ocurre antes del volumen físico del dispositivo. Falta validar la percepción de
  volumen y el carácter del ambiente escuchándolo en un teléfono real.

## Resultados

| Escenario | Resultado |
|---|---|
| Inicio con ambos canales apagados | El motor permanece sin inicializar; no reproduce audio. |
| Ambiente, rodado, clics y caída al 60 % | Pico 0.22931; RMS 0.02795; audio presente. |
| 16 clics simultáneos, caída y rodado al 100 % | Pico 0.891251, equivalente a −1 dBFS; limitador activo. |
| Bajar el volumen maestro a cero durante la reproducción | Pico y RMS 0. |
| Pedir clic, rodado y caída con volumen cero | Pico y RMS 0. |
| Pausar y pedir efectos durante la pausa | Pico y RMS 0. |
| Reanudar con ambiente activado | RMS 0.02076; recupera el ambiente. |
| Apagar ambos canales y pedir efectos | Pico y RMS 0. |

Para medir silencio tras detener voces se dejó vaciar el búfer de salida durante 100 ms.
Los valores corresponden al mezclador, sin grabación acústica por micrófono.

Los 19 WAV son PCM de 16 bits, mono: música/encendido a 22 050 Hz y el banco de ruleta a 48 000 Hz.
No contienen muestras saturadas; los picos del banco grabado no superan 0.901. El fondo dura 44.651 segundos, conserva cuatro vueltas de la progresión de GameSynth y suaviza la
unión durante 5 ms. La primera y la última muestra PCM tienen el mismo valor (649), sin salto en la unión.

## Exportación de GameSynth

- Se ejecutó el callback C# original `GameSynth.OnAudioFilterRead`, tensión 0, sin jefe ni efectos de mesa.
- Fuente: `fat-fish-game/Assets/Scripts/Audio/GameSynth.cs`, último cambio en `5d9647e`.
- SHA256 de la fuente: `052abbaaabd11342d98cd501af8d8ef76936eda1604324865f7f09dbbef1b34b`.
- .NET SDK 10.0.102; compilación del adaptador sin advertencias ni errores.
- 984 558 muestras a 22 050 Hz; 86 BPM; semilla 184; amplitud máxima 0.59998 y RMS 0.08978.
- SHA256 del WAV: `ec61c33b966315a6e3e914a4fec7a9ac8fcfa5cc8f4e9edaa5e913bf2a3b9bf8`.
- Repetir `python3 -I tool/render_gamesynth.py` produjo el mismo SHA256 del fondo musical.
- No hay voces ni grabaciones de terceros. La fuente y el MP3 de pub dejaron de formar parte del repo.

## Banco de ruleta

- 17 archivos de `fat-fish-game/Assets/Resources/Audio/Roulette`, copiados sin modificar sus bytes.
- Lanzamiento: `launch.wav`; un solo rodado `roll.wav`, que varía entre 0.7× y 1.3×.
- Impactos: 14 tomas con variación leve de tono y sin repetir la última toma.
- Los contactos discretos empiezan cuando la bola baja hacia las casillas (mitad del giro).
- Los rebotes usan un tono más grave. Al entrar en la casilla definitiva, según el ángulo dibujado
  (incluido el salto sobre el separador), se detienen los impactos y el rodado y se pide una única
  vibración media. No se espera al final del controlador de animación ni se reproduce `settle.wav`.
- Con movimiento reducido el resultado y la vibración son inmediatos, sin sonidos de ruleta.
- Se eliminaron los 18 WAV sintéticos de rodado/clics/caída de la app.

Captura previa al ajuste de vibración y retirada del clic final: 6.548 s a 44 100 Hz, estéreo; pico 0.38504 y RMS 0.02103 con efectos al 80 %, sin música para escuchar la ruleta aislada.

## Comprobaciones del proyecto

- Formato y análisis estático correctos.
- **179 pruebas** aprobadas. Incluyen sonido apagado inicialmente, propagación de los niveles
  0/10 y 10/10, pausa/reanudación por ciclo de vida y persistencia de preferencias.
  Dos pruebas recorren el giro fotograma a fotograma (con y sin proveedor de sonido): verifican
  vibración al entrar en la casilla final, sin duplicación al terminar ni nuevos impactos tras caer.
- APK de depuración compilado para la app normal (`lib/main.dart`).

## Revisión auditiva en teléfono

1. Instalar el APK y comprobar que inicialmente no suena nada.
2. Activar ambiente y efectos en Ajustes, dejar la app al 60 % y el sistema a un volumen habitual.
3. Escuchar el fondo durante al menos un minuto y girar la ruleta: debe sonar la música instrumental
   del juego, los efectos deben distinguirse y la unión del bucle no debe producir un salto perceptible.
4. Probar 0 %, 100 %, apagar cada canal y enviar la app al fondo durante un giro.
5. Reiniciar la app y comprobar que conserva los interruptores y el volumen elegido.
6. Registrar modelo y volumen del teléfono para ajustar la mezcla si hace falta.

Fuente y créditos del ambiente: [CREDITS.md](../../assets/sonidos/CREDITS.md).
