# Descargas y conservación de artefactos

## Última versión descargable

[Descargar la última compilación de main](https://github.com/Anuma-Games/fat-fish-mobile/releases/latest).

Después de pasar todos los jobs de CI, un push a `main` publica `fat-fish-mobile.apk` en Releases.
En `main` se compila un APK release firmado con la llave permanente y la configuración de producción.
Los pull requests y `develop` siguen compilando un APK de depuración, sin secretos de producción.
No caduca por antigüedad: permanece aunque no haya cambios durante meses o falle el siguiente CI.
`develop` y los pull requests no reemplazan esta descarga.

Primero se suben los archivos a un borrador y se publica; solo después se eliminan las releases automáticas
anteriores y sus tags `build-main-<run_id>-<intento>`. Las releases manuales quedan intactas.
Un reintento de un commit anterior no sustituye el build de un commit más reciente.
El tag apunta al commit compilado; las notas identifican el commit y la ejecución.
El job de publicación necesita `contents: write` solo en `main`. No usa PAT ni modifica el código.
Si se activan releases inmutables o reglas que prohíban borrar estos tags, habrá que adaptar la limpieza;
no se desactivan esas protecciones automáticamente.

## Firma y configuración de producción

Antes de integrar el cambio en `main`, configura estos secretos de Actions en el repositorio:

| Secreto | Contenido |
|---------|-----------|
| `ANDROID_KEYSTORE_BASE64` | Almacén de firma permanente codificado en Base64 |
| `ANDROID_STORE_PASSWORD` | Contraseña del almacén |
| `ANDROID_KEY_ALIAS` | Alias de la llave |
| `ANDROID_KEY_PASSWORD` | Contraseña de la llave |
| `MOBILE_PRODUCTION_CONFIG_JSON` | JSON con `API_BASE_URL`, `API_KEY`, `SENTRY_DSN` y `SENTRY_ENVIRONMENT` |

La URL de la API debe usar HTTPS y `SENTRY_ENVIRONMENT` debe ser `production`.
Un `SENTRY_DSN` vacío desactiva Sentry. El botón escolar de prueba ya no existe y no requiere configuración.
La configuración del cliente queda incorporada al APK; su clave de API debe tener permisos de lectura pública.
El almacén privado y sus contraseñas no se incluyen en el APK ni se guardan en Git.

El workflow reconstruye los archivos privados en el directorio temporal del runner y los elimina incluso si falla
la compilación. Comprueba la firma del APK antes de subirlo y usa `github.run_number` como número de compilación.
Mantén ese número creciente si reemplazas este workflow en el futuro.

Conserva una copia segura del almacén y las contraseñas fuera del equipo de desarrollo. Las siguientes versiones
deben usar la misma llave para poder instalarse como actualización. Al pasar de una APK debug a esta release,
puede ser necesario desinstalar la versión debug, perdiendo sus datos locales.
Publicar una nueva APK no actualiza automáticamente los teléfonos: el usuario debe descargarla e instalarla.

## Copias temporales de Actions

- La limpieza corre al terminar todo CI, diariamente a las 07:37 UTC y de forma manual.
- Conserva un build del último CI exitoso que no provenga de un pull request, entre todas las ramas.
  Si todavía no hay uno exitoso, conserva el último build de una rama.
- Conserva los dos reportes más recientes de cada tipo, aunque las pruebas hayan fallado.
- Respeta las ejecuciones activas: un JAR no se borra mientras otro job pueda necesitarlo.
  Los builds de pull requests se eliminan después de terminar CI y sus consumidores.
- Revisa de nuevo el estado de cada ejecución justo antes del borrado, para respetar reintentos.
- No toca artefactos con nombres ajenos a la política, releases, cachés, Packages ni archivos del repositorio.
- Las copias temporales de Actions caducan a los 7 días (builds) o 3 días (reportes), incluso si la limpieza falla.
  Esto no afecta la descarga permanente de Releases.

El workflow necesita llegar a la rama predeterminada para activarse. Desde Actions → Limpiar artefactos,
una ejecución manual muestra el plan; hay que marcar «aplicar» para borrar. Sin `--apply`, el script tampoco borra.
Usa `GITHUB_TOKEN` del repositorio, sin PAT ni permisos en otros repositorios. En `workflow_run` solo ejecuta
el script de la rama predeterminada, nunca código de un PR.

La cuota de la organización se comparte entre repositorios. La política reduce la acumulación, pero no
revierte el consumo ya acumulado ni garantiza espacio para builds simultáneos de cualquier tamaño.
Las pruebas siguen siendo obligatorias; liberar almacenamiento no altera sus resultados.

La descarga de Releases empezará a existir tras integrar estos workflows y completar el primer CI exitoso de `main`.
Los uploads temporales siguen sujetos a la cuota de Actions: este cambio no elimina un bloqueo ya acumulado del ciclo actual.

El job «Verificar conservación de builds» ejecuta las pruebas de los scripts también en los pull requests.
