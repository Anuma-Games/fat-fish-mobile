# FF-188: retroceso en Android e iOS

## Inventario previo

| Recorrido | Implementación existente | Comportamiento esperado |
|---|---|---|
| Cambiar sección inferior | `StatefulShellRoute` y barra de FF-108 | Cada pestaña conserva su estado; no es una pila de pantallas |
| Deslizar sobre fichas | `FatFishNavBar` | Previsualiza al mover y cambia al soltar |
| Desplazamiento vertical | Listas y `BarsVisibility` | Conserva scroll al volver y no se convierte en retroceso |
| Abrir Ajustes | `context.push`, navegador raíz | Volver a la pantalla que lo abrió |
| Buscar/cambiar jugador | `context.push`, navegador raíz | Volver conservando el jugador elegido; cancelar no elige otro |
| Historial | Ruta hija de Expediente, dentro de su propio `ShellRoute` | Volver a Expediente conservando jugador y scroll |
| Paneles visuales | Widgets dentro de las pantallas, sin diálogos/hojas modales | No añadir gestos de cierre a paneles que no son rutas |

## Fallos reproducidos y correcciones

1. En la combinación actual de Flutter 3.47.9 y go_router 18.1.4, el adaptador de
   páginas de go_router busca `MaterialApp` del paquete separado `material_ui`, pero
   esta app usa `MaterialApp` del SDK. La detección automática cae en `NoTransitionPage`:
   la ruta puede volver, pero no tiene el detector interactivo del borde izquierdo.
   `router.dart` crea explícitamente las páginas `MaterialPage` del mismo SDK que la
   app, conservando claves, nombres, argumentos e identificadores de restauración.
2. Al cerrar Ajustes sobre Historial, el navegador raíz podía comunicar a Android
   que ya no gestionaba Atrás aunque el navegador interno tuviera una página pendiente.
   Una prueba reproduce que la última llamada a `SystemNavigator.setFrameworkHandlesBack`
   queda en `false`. `NavigatorPopHandler` alrededor del contenedor de pestañas mantiene
   el estado del navegador interno en la ruta raíz y delega el pop a la ruta activa.
3. Se habilita `android:enableOnBackInvokedCallback="true"` en el manifiesto para
   participar en el retroceso nativo/predictivo en las versiones compatibles.

No se agregan detectores horizontales sobre las pantallas, confirmaciones de salida ni
pops manuales al cancelar el arrastre de iOS. Las pestañas raíz no tienen retroceso
lateral a otra pestaña; Android puede salir a inicio cuando ya no hay una ruta que cerrar.

## Comprobaciones automatizadas

Las pruebas de `test/app/app_shell_test.dart` cubren:

- iOS: iniciar realmente el gesto de borde, soltar para completarlo y soltar por debajo
  del umbral para cancelarlo, en Ajustes, búsqueda e historial.
- Cancelar conserva la búsqueda escrita; completar conserva el jugador guardado.
- Las pestañas raíz de iOS no se cierran con un arrastre horizontal.
- Android: Ajustes → Historial → Expediente, y búsqueda → Expediente, un paso por Atrás.
- Scroll del expediente conservado después de cerrar el historial.
- Atrás desde Ranking raíz no altera el historial de Expediente que sigue montado.
- El registro nativo de Atrás permanece activo después de cerrar Ajustes sobre Historial.
- Se mantienen las pruebas existentes de navegación por fichas y desplazamiento de FF-108.

La variante de iOS usa las transiciones Cupertino estándar del SDK; no equivale a una
prueba táctil en iPhone físico. La persistencia se verifica leyendo la base de datos del caso.

## Prueba nativa y compilaciones

La validación Android usa un emulador Medium Phone (Android 13), navegación del sistema
por gestos y un arranque de diagnóstico con respuestas locales y base de datos en memoria.
Se envía el arrastre desde el borde con `adb shell input swipe` y el botón con
`adb shell input keyevent 4`, comprobando en cada paso la ruta y el jugador persistido.
Los datos de diagnóstico no sustituyen el perfil de un dispositivo personal.

Resultados del recorrido nativo con el cambio aplicado:

| Acción del sistema | Ruta resultante | Resultado |
|---|---|---|
| Gesto desde el borde en Ajustes | Historial | PASS |
| Botón Atrás en Historial, después de cerrar Ajustes | Expediente | PASS |
| Gesto desde el borde en búsqueda | Expediente | PASS |
| Lectura del jugador tras los tres retrocesos | Jugador 70 conservado | PASS |

El recorrido imprimió `FF188 ALL_PASS`. La prueba usa el sistema Android real del
emulador; no invoca `Navigator.pop` para simular esos tres retrocesos.
Formato y análisis correctos; **181 pruebas** del proyecto aprobadas. La validación
se ejecuta sobre la rama independiente basada en `develop`, sin incorporar los PR
anteriores que siguen en revisión.

Compilación iOS de depuración generada y firmada en `build/ios/iphoneos/Runner.app`,
con la configuración local habitual. APK Android normal generado desde `lib/main.dart`,
instalado correctamente en el emulador al terminar y sin el arranque de diagnóstico.
La compilación de iOS no instala ni verifica gestos táctiles en un iPhone; esa
comprobación continúa pendiente de la revisión manual descrita debajo.

## Revisión manual en el iPhone físico

1. Iniciar la app de esta rama con la configuración habitual:
   `flutter run --dart-define-from-file=config/local.json` y elegir el iPhone conectado.
   Hacer un reinicio completo de la app si había otra rama ejecutándose.
2. Elegir un jugador. Abrir Ajustes y arrastrar desde el borde izquierdo hacia la derecha:
   primero un trayecto corto y lento para cancelar, después uno largo para volver.
3. Abrir Cambiar jugador, escribir una consulta y repetir. Cancelar debe conservar el
   texto; completar debe volver sin cambiar el jugador guardado.
4. Abrir Historial desde Expediente y repetir ambos gestos. Comprobar jugador y scroll.
5. Cambiar entre las tres fichas, desplazar las listas verticalmente y confirmar que
   estos gestos siguen funcionando. Desde una pestaña raíz no debe simularse una pantalla anterior.
6. Reiniciar la app y comprobar que el jugador continúa guardado.

**Pendiente de registrar:** modelo del iPhone, versión de iOS y resultado de la prueba
manual del solicitante. No se declara validado en iPhone físico antes de esa revisión.

## Referencias

- [Flutter: NavigatorPopHandler](https://api.flutter.dev/flutter/widgets/NavigatorPopHandler-class.html)
- [Flutter: retroceso predictivo de Android](https://docs.flutter.dev/platform-integration/android/predictive-back)
- [Flutter: transición Cupertino](https://api.flutter.dev/flutter/cupertino/CupertinoRouteTransitionMixin-mixin.html)

## Ampliación: swipe horizontal entre secciones

Desde el contenido de una pestaña raíz: izquierda avanza Expediente → Mesa → Ranking;
derecha recorre el orden inverso. Cambia una sección por gesto al soltar, sin recorrido
circular. Reutiliza la selección existente para conservar el estado de cada pestaña.
Un arrastre corto, cancelado o que vuelve al origen no navega. Las pantallas apiladas
(Ajustes, búsqueda e historial) conservan su retroceso de plataforma. La barra inferior
mantiene su gesto independiente y el desplazamiento vertical sigue a cargo de las listas.

Esta ampliación se formatea y revisa por diff, sin ejecutar pruebas ni builds, según
lo acordado con el solicitante. Las 181 pruebas y compilaciones anteriores corresponden
al ajuste de retroceso previo; la comprobación del swipe queda para la prueba manual.
Comprobar los dos sentidos, los extremos, el scroll vertical, el toque de la ruleta y
la cancelación antes de aprobar.
