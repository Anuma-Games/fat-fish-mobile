# Fondo de la mesa

`mesa.jpg` es un render del escenario de Fat Fish (Anuma Games), exportado desde
`fat-fish-game/Assets/Scenes/FatFish.unity`, revisión `077d6e8`, con Unity 6000.6.0f1.
Usa los modelos, materiales e iluminación incluidos en ese proyecto; no se importó
arte externo adicional para la app.

La exportación conserva el encuadre de la cámara principal del juego, incluido el
crupier, la mesa/ruleta 3D y los objetos del local, con su aspecto pixelado.
La ruleta se reconstruye con `RouletteWheelBuilder.BuildFor`, como al iniciar
la partida; después se ocultan los lienzos de interfaz. Se obtuvo con
`tool/unity/MobileTableBackgroundExport.cs`; instrucciones en `tool/unity/README.md`.
