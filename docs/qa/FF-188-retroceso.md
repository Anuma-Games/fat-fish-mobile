# FF-188: gestos e historial de navegación

## Inventario y alcance

| Recorrido | Navegación | Resultado esperado |
|---|---|---|
| Fichas inferiores de FF-108 | `StatefulShellRoute`, una rama por sección | Conserva el estado de cada pestaña |
| Deslizar sobre las fichas | Gesto existente en `FatFishNavBar` | Selecciona al soltar |
| Swipe en el contenido raíz | Izquierda/siguiente, derecha/anterior | Expediente ↔ Mesa ↔ Ranking, sin recorrido circular |
| Abrir Ajustes o búsqueda | Pantalla apilada en el navegador raíz | Se cierra antes de volver por secciones |
| Abrir Historial de partidas | Ruta hija de Expediente | Vuelve conservando jugador y scroll |
| Atrás en una sección raíz | Historial de visitas de la sesión | Vuelve a la sección visitada anteriormente |
| Paneles visuales | Widgets sin ruta/modal propio | No adquieren un cierre nuevo |

El desplazamiento vertical, la barra inferior y el toque de la ruleta mantienen sus
interacciones. No se cambia el guardado del jugador ni se añaden dependencias.

## Historial de secciones

- Registra cambios efectivos, tanto por ficha como por swipe; tocar la sección activa
  no añade otra visita. Se permiten visitas repetidas en momentos distintos.
- Conserva como máximo **5 entradas anteriores**, descartando la más antigua al añadir
  una sexta. No cuenta como entrada la sección que está abierta actualmente.
- Volver consume una entrada sin volver a registrarla: no genera bucles.
- Primero se cierra cualquier pantalla apilada de la rama activa; después se consume
  el historial de secciones. Una rama restaurada conserva sus pantallas y su scroll.
- Al agotar el historial, Android recupera su salida normal. El gesto de borde de iOS
  no cambia de sección si ya no hay una visita anterior.
- Es un historial de la sesión en memoria; se borra al reiniciar la app.

Ejemplos cubiertos por pruebas:

- Expediente → Ranking → Mesa → Ranking → Atrás: Mesa → Ranking → Expediente.
- Expediente → Mesa → Ranking → Expediente → Ranking → Mesa → Expediente → Ranking:
  solo se deshacen las últimas cinco visitas: Expediente → Mesa → Ranking → Expediente → Ranking.

## Gestos de iOS y Android

En pantallas apiladas, iOS usa la transición Cupertino estándar del SDK y permite
completar o cancelar el arrastre desde el borde. Android usa el gesto/botón del sistema.

En raíces de sección, el borde izquierdo (24 puntos) se reserva para volver por visitas;
un arrastre hacia la derecha confirmado consume una entrada. El resto del contenido
conserva el recorrido de fichas por orden. Un gesto corto, cancelado o que regresa al
origen no navega ni consume visitas. La vuelta entre raíces la gestiona la app con la
transición de pestañas existente, sin previsualización interactiva de la sección anterior.

## Correcciones de plataforma

1. El adaptador automático de go_router 18.1.4 busca el `MaterialApp` del paquete
   `material_ui`, mientras esta app usa el del SDK Flutter 3.47.9. La detección podía
   caer en `NoTransitionPage`, sin el detector interactivo de borde. Se crean páginas
   `MaterialPage` explícitas del SDK, conservando claves, nombres, argumentos y restauración.
2. Cerrar Ajustes sobre Historial podía desregistrar Atrás en Android aunque aún
   hubiera una página interna que cerrar. `NavigatorPopHandler` mantiene el estado del
   navegador interno y delega en la ruta activa.
3. Un `PopScope` registra el retroceso cuando solo quedan visitas a secciones. El
   manejador anterior consume las visitas, sin duplicar la acción.
4. El manifiesto habilita `android:enableOnBackInvokedCallback="true"`.

## Validación automática final

Formato y análisis estático correctos; **191 pruebas** del proyecto aprobadas.
Los nuevos casos se ejecutan en variantes Android e iOS y cubren:

- Swipe por orden, extremos sin recorrido circular y conservación de scroll/ruleta.
- Gestos cortos, cancelados y de ida/vuelta que no consumen entradas.
- Retroceso en orden temporal, visitas repetidas, toque activo y ausencia de bucles.
- Límite de cinco visitas y comportamiento al agotar el historial.
- Prioridad de Ajustes/Historial sobre las visitas de sección.
- Gesto iOS interactivo y cancelado en Ajustes, búsqueda e historial; búsqueda y jugador conservados.
- Registro nativo de Android después de cerrar Ajustes sobre Historial.

Se conservan las pruebas de navegación por fichas y desplazamiento de FF-108.
Los comandos finales son:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub -t lib/main.dart --dart-define-from-file=config/local.json
flutter build ios --debug --no-pub --dart-define-from-file=config/local.json
```

Compilaciones completadas: APK de depuración e iOS de depuración firmado.
Los builds son de la app normal, con configuración local; no requieren modificar las
preferencias o el jugador de un dispositivo para compilar. Los resultados de las
variantes de widgets verifican la lógica y los gestos Flutter; no son una prueba táctil
sobre un iPhone físico.

## Evidencia de dispositivo y revisión manual

En la validación previa del retroceso se usó un emulador Medium Phone, Android 13,
con navegación gestual del sistema, respuestas locales y base de datos en memoria:

| Acción del sistema | Resultado |
|---|---|
| Gesto del borde en Ajustes | Volvió a Historial |
| Botón Atrás en Historial tras cerrar Ajustes | Volvió a Expediente |
| Gesto del borde en búsqueda | Volvió a Expediente |
| Lectura del jugador al terminar | Jugador 70 conservado |

Se enviaron `adb shell input swipe` y `adb shell input keyevent 4`; el recorrido terminó
con `FF188 ALL_PASS`. Esa prueba de dispositivo corresponde al retroceso apilado previo;
la ampliación final de secciones está cubierta por los nuevos tests y builds completos.

El solicitante confirmó que realizó las pruebas manuales de la navegación y que todo
funciona, antes de solicitar esta actualización de pruebas y el PR. El equipo de prueba
habitual indicado por el solicitante es su iPhone físico; no se reportaron modelo ni
versión para esa validación y no se inventan esos datos.

Para repetir en teléfono: reiniciar la app de esta rama, probar ambos sentidos del
swipe, completar/cancelar el borde, alternar más de cinco veces y volver hasta agotar
visitas. Abrir Ajustes, búsqueda e historial y comprobar que se cierran primero,
conservando jugador, texto de búsqueda al cancelar y scroll al regresar.

## Referencias

- [Flutter: NavigatorPopHandler](https://api.flutter.dev/flutter/widgets/NavigatorPopHandler-class.html)
- [Flutter: retroceso predictivo de Android](https://docs.flutter.dev/platform-integration/android/predictive-back)
- [Flutter: transición Cupertino](https://api.flutter.dev/flutter/cupertino/CupertinoRouteTransitionMixin-mixin.html)
