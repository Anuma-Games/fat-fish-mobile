# Fondo actualizado de la mesa

`MobileTableBackgroundExport.cs` exporta `assets/images/mesa.jpg` desde
`fat-fish-game/Assets/Scenes/FatFish.unity`, con Unity 6000.6.0f1 y el render del juego.
No utiliza la captura con HUD ni genera arte nuevo. La salida es JPG de 1600×900,
calidad 92; la app conserva el recorte anterior y aplica un oscurecimiento más ligero
en la zona del crupier y el escenario (30 % y 16 % en las paradas intermedias).
Los extremos conservan la transición al fondo de la app.
La altura del fondo se ajusta con la escala de la escena, para evitar que la mesa
de apuestas de la imagen quede detrás del estado y los contadores en pantallas bajas.

El exportador abre la escena guardada y ejecuta `RouletteWheelBuilder.BuildFor`,
el mismo constructor que instala `TableSceneInstaller` al entrar en la partida.
También coloca la bola en el aro con `ResetBall`. Comprueba que se hayan creado
`RouletteBowl` y `RotorDetail` antes de capturar: la escena guardada por sí sola
todavía contiene la pista antigua de bloques. Después oculta únicamente los lienzos de interfaz.
Conserva al crupier, la mesa, la ruleta 3D y el mobiliario del local.
Crea una cámara temporal con la posición, orientación y campo visual de Main Camera,
y ejecuta cuatro pasadas para cargar los materiales antes de leer la imagen.
No guarda la escena ni cambia el pipeline, las cámaras originales o sus ajustes en disco.

Para regenerar, con el editor cerrado y desde la raíz de la app móvil:

```bash
mkdir -p ../fat-fish-game/Assets/TemporaryMobileExport/Editor
cp tool/unity/MobileTableBackgroundExport.cs ../fat-fish-game/Assets/TemporaryMobileExport/Editor/
/Applications/Unity/Hub/Editor/6000.6.0f1/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit -projectPath "$PWD/../fat-fish-game" \
  -executeMethod MobileTableBackgroundExport.Capture \
  -backgroundOutput "$PWD/assets/images/mesa.jpg" \
  -logFile /tmp/fat-fish-mobile-background.log
```

Después de comprobar `MOBILE_BACKGROUND_RUNTIME_ROULETTE_READY` y
`MOBILE_BACKGROUND_EXPORTED` en el log, retirar la copia temporal
del script y sus `.meta` desde el proyecto Unity. Si Unity reserializa fuentes u otros
assets automáticamente, conservar los cambios que ya existían antes de la exportación.
Revisar que no reaparezcan paneles de ronda, dinero, botones o diálogos del juego.

Validación visual: revisar la pantalla de la app en 390×844 y 360×640, con el cuadro del
crupier visible, la ruleta, los resultados y la barra inferior. El crupier debe quedar visible sobre la ruleta interactiva y el fondo debe fundirse
con la zona inferior, conservando el contraste de los textos.
