# app_boosti_v2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Flavors

Este proyecto tiene 2 flavors:

| Flavor | Descripción | Entry point |
|--------|-------------|-------------|
| `client` | App para dueños/empleados de locales (POS) | `lib/main_client.dart` |
| `admin` | App para super admins (Control Center) | `lib/main_admin.dart` |

### Cómo correr cada flavor

```bash
# Client (POS)
flutter run --flavor client -t lib/main_client.dart --dart-define-from-file=env.json

# Admin (Control Center)
flutter run --flavor admin -t lib/main_admin.dart --dart-define-from-file=env.json
```

### Application IDs

| Flavor | applicationId | Nombre visible |
|--------|---------------|----------------|
| client | `com.jahtlabs.boostipos.client` | Boosti POS |
| admin | `com.jahtlabs.boostipos.admin` | Boosti POS Admin |

Están definidos en `android/app/build.gradle`, dentro de `productFlavors`.

⚠️ **Cambiar un `applicationId` ya publicado crea una app nueva sin herencia.**
El launcher, las claves de firma y las compras quedan atados al `applicationId`
original. No cambiar después de publicar sin planificar la migración.

## Compilar la app

> **No hay CI configurado.** El build se hace a mano en cada máquina.
>
> Si en el futuro se agrega un pipeline, recordá:
>
> - `env.json` **no viaja en git**. Hay que generarlo desde los secrets del
>   CI (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`).
> - El comando debe incluir `--dart-define-from-file=env.json`.
> - Los flavors requieren `--target lib/main_client.dart` o
>   `--target lib/main_admin.dart`.
> - Un APK de release se firma con `key.properties`, que tampoco está en git.

**Flutter no encuentra el entrypoint por defecto.** `lib/main.dart` ya no
existe (pasó a ser `app.dart` al separar cliente de admin), así que Gradle
busca un archivo que no está y falla con:

```
Target file "lib/main.dart" not found.
```

Hay que pasar `--target` explícitamente. **No se puede fijar en
`build.gradle`**: un bloque `flutter { target = ... }` dentro de
`productFlavors` parece la solución, pero Flutter 3.47.2 lo ignora (verificado:
con el bloque puesto, el build seguía fallando igual).

### Cliente (retail)

```bash
flutter build apk --flavor client --target lib/main_client.dart \
  --dart-define-from-file=env.json
```

### Admin (consola SaaS)

```bash
flutter build apk --flavor admin --target lib/main_admin.dart \
  --dart-define-from-file=env.json
```

### Debug rápido

```bash
flutter run --flavor client --target lib/main_client.dart \
  --dart-define-from-file=env.json
```

### Reglas

- **SIEMPRE** incluir `--dart-define-from-file=env.json`.
  - Sin el flag, `SUPABASE_URL` queda vacía y **Supabase revienta al arrancar**.
  - `SUPABASE_ANON_KEY` vacía rompe el login.
  - `SENTRY_DSN` vacía apaga Sentry **en silencio**: no hay error, solo no se
    reportan excepciones.
- `env.json` **NO está en git**. Cada máquina y cada CI lo tiene que tener a
  mano. Contiene `SUPABASE_URL`, `SUPABASE_ANON_KEY` y `SENTRY_DSN`.
- `env.json` se compila **dentro del binario**: no se lee en ejecución. Cambiar
  un valor requiere recompilar.
- Windows: los `.bat` de PATH se cuelgan. Usar el snapshot de `flutter_tools`
  directamente, con el patrón de dos llamadas (lanzar desacoplado con
  `Start-Process`, leer el log en la llamada siguiente).

### Configuración iOS pendiente

Para configurar los flavors en iOS:

1. Abre el proyecto en Xcode (`ios/Runner.xcworkspace`).
2. Crea 2 Build Configurations: `Debug-Client`, `Release-Client`, `Debug-Admin`, `Release-Admin`.
3. Crea 2 Schemes: `client` y `admin`.
4. En cada Scheme, asigna la Build Configuration correspondiente.
5. En `Info.plist`, añade la variable `APP_MODE` con el valor `client` o `admin` según la configuration.
6. En el código, lee `Bundle.main.object(forInfoDictionaryKey: "APP_MODE")` para determinar el modo.

### Estructura del Control Center

```
lib/features/admin_console/
├── presentation/
│   ├── screens/
│   │   ├── control_center_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── clients_screen.dart
│   │   ├── client_detail_screen.dart
│   │   ├── plans_screen.dart
│   │   └── dev_tools_screen.dart
│   └── widgets/
│       ├── kpi_card.dart
│       ├── status_badge.dart
│       ├── client_card.dart
│       └── empty_state.dart
├── providers/
│   ├── admin_dashboard_provider.dart
│   ├── clients_provider.dart
│   ├── subscriptions_provider.dart
│   └── admin_access_provider.dart
├── services/
│   ├── admin_service.dart
│   └── metrics_service.dart
└── data/
    └── models/
        ├── plan.dart
        ├── subscription.dart
        ├── tenant.dart
        ├── client_note.dart
        ├── payment.dart
        └── saas_metrics.dart
```
