# FF-184: validación de audio

## Entorno y niveles

- Emulador Android **Medium Phone**, Android **13**.
- Volumen multimedia del sistema: **8 de 15**.
- Volumen de la app: **6 de 10**, **10 de 10** y **0 de 10**.
- Motor real SoLoud con los WAV empaquetados; captura PCM del mezclador a 22 050 Hz/mono.
- La captura digital ocurre antes del volumen físico del dispositivo. Falta validar la percepción de
  volumen y el carácter del ambiente escuchándolo en un teléfono real.

## Resultados

| Escenario | Resultado |
|---|---|
| Inicio con ambos canales apagados | El motor permanece sin inicializar; no reproduce audio. |
| Ambiente, rodado, clics y caída al 60 % | Pico 0.23442; RMS 0.03227; audio presente. |
| 16 clics simultáneos, caída y rodado al 100 % | Pico 0.891251, equivalente a −1 dBFS; limitador activo. |
| Bajar el volumen maestro a cero durante la reproducción | Pico y RMS 0. |
| Pedir clic, rodado y caída con volumen cero | Pico y RMS 0. |
| Pausar y pedir efectos durante la pausa | Pico y RMS 0. |
| Reanudar con ambiente activado | RMS 0.02014; recupera el ambiente. |
| Apagar ambos canales y pedir efectos | Pico y RMS 0. |

Para medir silencio tras detener voces se dejó vaciar el búfer de salida durante 100 ms.
Los valores corresponden al mezclador, sin grabación acústica por micrófono.

Los 20 WAV son PCM de 16 bits, mono y 22 050 Hz, sin muestras saturadas y con picos individuales
inferiores a 0.851. El fondo dura 59.75 segundos y utiliza un fundido cruzado de 3 segundos.

## Comprobaciones del proyecto

- Formato y análisis estático correctos.
- **177 pruebas** aprobadas. Incluyen sonido apagado inicialmente, propagación de los niveles
  0/10 y 10/10, pausa/reanudación por ciclo de vida y persistencia de preferencias.
- APK de depuración compilado para la app normal (`lib/main.dart`).

## Revisión auditiva en teléfono

1. Instalar el APK y comprobar que inicialmente no suena nada.
2. Activar ambiente y efectos en Ajustes, dejar la app al 60 % y el sistema a un volumen habitual.
3. Escuchar el fondo durante al menos un minuto y girar la ruleta: las voces deben quedar lejanas,
   los efectos deben distinguirse y la unión del bucle no debe producir un salto perceptible.
4. Probar 0 %, 100 %, apagar cada canal y enviar la app al fondo durante un giro.
5. Reiniciar la app y comprobar que conserva los interruptores y el volumen elegido.
6. Registrar modelo y volumen del teléfono para ajustar la mezcla si hace falta.

Fuente y créditos del ambiente: [CREDITS.md](../../assets/sonidos/CREDITS.md).
