# FF-192: revisión de textos y cifras

Estado: implementación y revisión manual aprobadas por el solicitante; preparada para revisión mediante PR hacia develop.

## Decisión confirmada

El solicitante eligió **conservar el puntaje del ranking y aclarar su significado**.
La cuota de cada ronda se cumple con dinero ficticio; el puntaje sigue siendo un cálculo interno asociado
al bono de la casa. No son magnitudes intercambiables. No se cambia el orden del ranking ni se convierten
los valores de `puntaje` a dinero.

Cada fila de partida conserva los puntos arriba y muestra debajo el resultado monetario de los giros:
`dineroGanado - dineroInvertido`, con signo positivo o negativo y cero neutro. Las cifras quedan al extremo
derecho y los datos de la partida a la izquierda. Se omiten inversión y pérdida bruta adicionales.
La skill de diseño consultada es de octubre y todavía describe metas en puntos: para esta revisión se
usaron la aclaración del solicitante y el README/código actuales del juego.

## Evidencia y recorrido del dato

Repositorios revisados: móvil sobre `develop` (`f151d90`), juego `develop` (`077d6e8`) y API `develop`
(`d1153ca`). No se modificaron el juego ni la API.

| Paso | Fuente | Comportamiento comprobado |
|------|--------|--------------------------|
| Cuota | Juego: `README.md`, sección «Balance, jefes y casa de empeño» y `Assets/Scripts/Rules/MoneyGoal.cs` | El objetivo depende del dinero con que se terminó la ronda anterior. No depende del puntaje acumulado. |
| Puntaje | Juego: `Assets/Scripts/PointCalculator.cs`, `CalculatePoints` | Calcula puntos a partir de la jugada principal, combo y comodines. |
| Bono | Juego: `Assets/Scripts/BetResolver.cs`, resolución del bono | Convierte los puntos del giro en un bono monetario solo cuando las jugadas dejaron ganancia. El bono se redondea por giro. |
| Registro | Juego: `Assets/Scripts/Runs/RunStats.cs` y `RunSync.cs` | Acumula los puntos recibidos del resolver y los guarda/envía como `puntaje`; el dinero se guarda en campos separados. |
| API | `GameService.recalculate`, `PlayerStatisticsRepository` y `PwaService` | Selecciona el mayor puntaje de una partida ganada por jugador; orden descendente, desempate por fecha y luego ID. El historial devuelve puntaje y dinero por separado. |
| App | `MatchPageDto` y `RankingDto` | Copia `puntaje` a `score`, sin conversión. Las unidades que se ven son responsabilidad de la interfaz. |

El resolver registra puntos para el historial cuando hubo bono de la casa; el bono no se puede reconstruir
exactamente multiplicando el puntaje total por una tasa, debido al cálculo y redondeo por giro.

Los campos monetarios tampoco son equivalentes entre sí:

- `dineroInvertido`: suma de fichas colocadas en los giros.
- `dineroGanado`: dinero recibido de los giros, incluida la devolución de las fichas y los bonos/reembolsos.
  No es ganancia neta ni saldo final.
- `dineroPerdido`: fichas invertidas en jugadas perdedoras; no es el balance neto de la partida.
- `dineroGanado - dineroInvertido`: resultado neto de los giros, no saldo final; no representa todos los
  movimientos de tienda, préstamos, empeños o jefes.

Como comprobación adicional se leyeron 89 registros locales, sin modificarlos ni copiar identidades:
64 tienen `puntaje` distinto de `dineroGanado`. Ninguno está simultáneamente identificado con dueño y
marcado como enviado, por lo que **no se verificó una misma partida local contra producción**.

## Inventario de pantallas e implementación

| Pantalla o elemento | Resultado |
|--------------------|-----------|
| Bienvenida | «Tu expediente, sin iniciar sesión. Todo el dinero del juego es ficticio.» |
| Expediente, estadísticas | Conserva las magnitudes del resumen: partidas, pérdidas brutas, inversión, racha y tiempo. |
| Partidas recientes e historial | Puntaje en «pts» arriba y una sola cifra monetaria debajo: `dineroGanado - dineroInvertido`, por ejemplo `+$450`, `−$450` o `$0`. Sin importe invertido ni pérdida bruta adicional en la fila. La columna de cifras queda al extremo derecho. Conserva resultado, ronda, fecha y duración. |
| Colores y accesibilidad | Ganancia en gris suave, pérdida en distintivo rojo con texto crema y cero neutro. El signo y la descripción para el lector de pantalla distinguen los casos sin depender del color. Las cifras largas se ajustan al ancho disponible. |
| Historial | Conserva el subtítulo elegido manualmente: «De la más reciente a la más antigua». Las descripciones de accesibilidad identifican la cifra monetaria como resultado de las jugadas, sin presentarla como saldo final. |
| Ranking, encabezado | «Las mejores partidas». Explicación: «Cuenta el mayor puntaje en una partida ganada. En empate, gana quien lo consiguió primero.» |
| Ranking, ayuda | Botón «Cómo funciona el ranking» abre «¿Cómo subir posiciones?»: explica que hay que ganar para entrar, que solo cuenta la mejor victoria, que los puntos no se suman entre partidas, el orden y desempate, y dónde consultar el resultado monetario. Replica la nota de salida del juego: papel rayado crema ligeramente inclinado, encabezado «NOTA DE LA CASA / RANKING», separador punteado y botón oscuro con sombra. Usa Jersey 10 para título y botón, Jersey 15 para lectura, tinta oscura y contenido desplazable. Conserva los textos manuales aprobados por el solicitante. Jersey 15 se incorpora desde los recursos del juego junto con su licencia OFL. Se cierra con «Entendido». Disponible también fuera de la primera página. |
| Ranking, posición propia | «Tu mejor victoria»; sin victoria, «Gana una partida para entrar.». Mantiene los puntajes, posiciones, paginación y etiquetas de puntos del podio. |
| Mesa, ajustes y búsqueda | Sin cambios de economía detectados. |
| Estados sin conexión/error | Conserva los avisos y las fechas; el resultado de los giros se calcula también desde las partidas guardadas. |

No se agregan tablas de balance, nombres de jefes ni porcentajes que puedan desactualizarse.
No se modificó el criterio de orden del ranking ni se presentaron sus puntos como dinero.

## Compatibilidad y datos guardados

Con la decisión confirmada no se necesita modificar el contrato de la API, recalcular estadísticas,
renombrar campos JSON ni migrar la base local. La caché conserva respuestas JSON originales y los mismos
DTO las interpretan en línea y sin conexión. El puntaje histórico sigue siendo puntaje.

No puede suponerse que una partida antigua se jugó con el balance actual: cualquier explicación del bono
debe ser general y no prometer una equivalencia monetaria fija para los datos históricos.

## Validación

- Formato correcto y análisis estático sin incidencias.
- 180 pruebas Flutter aprobadas en la validación final, incluidas las expectativas actualizadas a los textos manuales.
- APK de depuración compilado correctamente con Jersey 15 incorporada y su licencia OFL.
- Nuevas pruebas de resultado monetario: ganancia, pérdida, equilibrio, actividad cero y cifras largas
  en una pantalla de 320 px con texto a 1.5×. Los datos de prueba distinguen puntaje, pérdidas brutas y
  resultado neto; una partida ganada puede mostrar pérdida neta de giros.
- El historial conserva paginación y muestra el mismo resultado con datos guardados sin conexión.
- La ayuda del ranking se abre/cierra en pantalla de 360 px sin volver a consultar datos ni alterar las posiciones. Se comprueban el papel, las tipografías del juego y el texto oscuro con el tema real de la app. Se renderizó e inspeccionó una vista de 360 × 700 con las fuentes reales.
- Las filas conservan el puntaje y las cifras alineadas al extremo derecho, con cálculo monetario independiente del resultado de victoria/derrota.

El solicitante aprobó la revisión manual de esta versión. Revisar la integración con las fuentes definitivas de FF-185
al incorporar sus cambios en develop. No se han incorporado ramas de otros tickets.
Completar FF-172 con una partida identificada entre juego/API/app; la lectura de registros locales no
sustituye esa validación. La revisión de contenido por Luis Ángel sigue pendiente; no se contactó a terceros.
La entrega se realiza mediante PR hacia develop. Los cambios de balance o contrato API no forman parte del alcance aprobado. Relacionados: FF-167, FF-172 y FF-189.
