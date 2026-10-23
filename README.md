# Fat Fish - App móvil

[![CI](https://github.com/Anuma-Games/fat-fish-mobile/actions/workflows/ci.yml/badge.svg)](https://github.com/Anuma-Games/fat-fish-mobile/actions/workflows/ci.yml)

App en Flutter del videojuego **Fat Fish** (proyecto integrador, grupo IDGS101N, UTCH). Permite al jugador consultar su
expediente ("Lo que el casino sabe de ti") y el ranking mundial. En el MVP es solo de lectura y se publica primero para
Android.

## Requisitos

- Flutter 3.47.7 (canal stable)
- Android SDK y Java 17 para compilar el APK

## Comandos

```bash
flutter pub get        # instalar dependencias
flutter run            # correr en un emulador o dispositivo
flutter analyze        # análisis estático
flutter test           # pruebas
flutter build apk      # generar el APK
```

## Configuración de la API

La URL y la llave de la API se leen al compilar con `--dart-define-from-file`, así que cambian sin tocar el código.

1. Copia `config/example.json` a `config/local.json` (ignorado por Git) y llena los valores:

   | Clave | Valor | Por defecto |
   |---|---|---|
   | `API_BASE_URL` | Dirección de la API, sin `/` final | `http://10.0.2.2:8080` (la API local vista desde el emulador de Android) |
   | `API_KEY` | Llave que se envía en `X-Api-Key`; se pide al responsable de la API | Vacía (la API local no la pide) |

2. Corre o compila con ese archivo:

   ```bash
   flutter run --dart-define-from-file=config/local.json
   ```

Sin el archivo, la app usa los valores por defecto. El HTTP sin cifrar solo se permite en las compilaciones de
depuración. La llave queda dentro del APK y se puede extraer, así que solo debe abrir endpoints de lectura pública.

## Estructura

El código se organiza por *feature* y, dentro de cada una, en las capas de *clean architecture*:

```text
lib/
├── main.dart                 # raíz de composición: crea los servicios y los entrega con RepositoryProvider
├── app/                      # FatFishApp, tema, rutas (go_router) y barra de navegación
├── core/                     # código compartido por las features
│   ├── config/               # AppConfig (valores de --dart-define)
│   ├── network/              # ApiClient y ApiException
│   ├── storage/              # AppDatabase (Drift): caché local
│   └── presentation/widgets/ # widgets comunes
└── features/
    ├── expediente/           # expediente e historial del jugador
    ├── jugador/              # mi jugador y búsqueda
    └── ranking/              # ranking mundial
        ├── data/             # DTOs, fuentes de datos (API y caché) e implementación del repositorio
        ├── domain/           # entidades, repositorio abstracto y casos de uso
        └── presentation/     # páginas, widgets y Cubits
```

- `domain` no importa nada de `data`, de Flutter ni de paquetes externos.
- Cada caso de uso es una clase con un solo método `call`, que recibe el repositorio abstracto.
- El estado de cada pantalla vive en un `Cubit` (`flutter_bloc`) que llama a los casos de uso.
- Las rutas están en `lib/app/router.dart`. Cada pestaña es una rama de `StatefulShellRoute`, así que conserva su propio
  historial de navegación.
- Las pruebas replican las rutas de `lib/` dentro de `test/`.

## Caché local

La app guarda las respuestas de la API en SQLite con [Drift](https://drift.simonbinder.eu/). Las pantallas leen de la
base local y la red solo la actualiza, así que sin conexión se muestra lo último guardado.

- Cada feature agrega sus tablas a `@DriftDatabase(tables: [...])` en `lib/core/storage/app_database.dart`.
- Si cambia el esquema, sube `schemaVersion` y agrega la migración.
- El código generado (`*.g.dart`) se sube al repositorio. Después de cambiar una tabla, regenéralo:

  ```bash
  dart run build_runner build
  ```

- En las pruebas se usa `AppDatabase(NativeDatabase.memory())`.

## Fuentes

Jersey 10 (títulos), Press Start 2P (etiquetas) y Geist (texto) están en `assets/fonts/` con su licencia SIL Open Font
License (`OFL-*.txt`).

## Integración continua

El workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) corre en cada push a `main` y `develop` y en cada
Pull Request hacia esas ramas:

1. **Analizar y probar:** formato (`dart format`), análisis estático (`flutter analyze`) y pruebas (`flutter test`).
2. **Compilar APK** (solo si el paso anterior pasa): genera el APK de depuración y lo sube como artefacto
   `fat-fish-mobile-apk`.

## Flujo de trabajo

- Ramas: `main` (producción), `develop` (integración) y `feature/FF-<ticket>-<descripcion>`.
- Todo cambio entra por Pull Request con una aprobación y el CI en verde.
- Commits y ramas llevan la clave del ticket de Jira (`FF-…`).
- `main` y `develop` están protegidas: los checks *Analizar y probar* y *Compilar APK* deben estar en verde.
- `CODEOWNERS` asigna revisores automáticamente y la plantilla de PR pide el ticket de Jira y cómo probar el cambio.
- Dependabot revisa cada semana las dependencias (paquetes de Dart y acciones de GitHub) y abre PRs hacia `develop`.

## Equipo

Anuma Games: Luis Ángel Gaxiola Gamboa, Emmanuel González Hernández, Jesús Antonio Jiménez Mendoza, Ángel Gael Jurado
Rodríguez y Andrik Rivera Esquer.
