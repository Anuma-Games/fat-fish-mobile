# Fat Fish · App móvil

[![CI](https://github.com/Anuma-Games/fat-fish-mobile/actions/workflows/ci.yml/badge.svg)](https://github.com/Anuma-Games/fat-fish-mobile/actions/workflows/ci.yml)

App en Flutter del videojuego **Fat Fish** (proyecto integrador, grupo IDGS101N, UTCH). Permite al jugador consultar su expediente ("Lo que el casino sabe de ti") y el ranking mundial. En el MVP es solo de lectura y se publica primero para Android.

> Estado: proyecto base con integración continua. Las pantallas se agregan en los siguientes sprints.

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

## Integración continua

El workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) corre en cada push a `main` y `develop` y en cada Pull Request hacia esas ramas:

1. **Analizar y probar:** formato (`dart format`), análisis estático (`flutter analyze`) y pruebas (`flutter test`).
2. **Compilar APK** (solo si el paso anterior pasa): genera el APK de depuración y lo sube como artefacto `fat-fish-mobile-apk`.

## Flujo de trabajo

- Ramas: `main` (producción), `develop` (integración) y `feature/FF-<ticket>-<descripcion>`.
- Todo cambio entra por Pull Request con una aprobación y el CI en verde.
- Commits y ramas llevan la clave del ticket de Jira (`FF-…`).
- `main` y `develop` están protegidas: los checks *Analizar y probar* y *Compilar APK* deben estar en verde.
- `CODEOWNERS` asigna revisores automáticamente y la plantilla de PR pide el ticket de Jira y cómo probar el cambio.
- Dependabot revisa cada semana las dependencias (paquetes de Dart y acciones de GitHub) y abre PRs hacia `develop`.

## Equipo

Anuma Games: Luis Ángel Gaxiola Gamboa, Emmanuel González Hernández, Jesús Antonio Jiménez Mendoza, Ángel Gael Jurado Rodríguez y Andrik Rivera Esquer.
