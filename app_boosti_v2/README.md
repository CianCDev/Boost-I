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

### ⚠️ Application IDs TEMPORALES

Los `applicationId` actuales son **TEMPORALES** y deben reemplazarse antes de publicar:

| Flavor | applicationId temporal | Nombre visible |
|--------|------------------------|----------------|
| client | `com.tuempresa.tuapp.client` | TuApp |
| admin | `com.tuempresa.tuapp.admin` | TuApp Admin |

Para cambiarlos, edita `android/app/build.gradle` y reemplaza los valores en `productFlavors`.

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
