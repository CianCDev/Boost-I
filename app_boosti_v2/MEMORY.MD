# MEMORY.md

## Visión General del Proyecto
- **Nombre de la App:** `app_boosti_v2`
- **Propósito:** Sistema de gestión empresarial y punto de venta (POS) multi-tenant con soporte offline-first.
- **Arquitectura:** Clean Architecture por características (`lib/features/<módulo>/`), dividida en capas `data`, `domain` y `presentation`.

---

## Pila Técnica y Versiones Base
- **Flutter SDK:** 3.47.2 (Channel stable)
- **Dart SDK:** 3.13.2
- **Lenguaje Kotlin:** 2.1.10 (KGP)
- **Android Gradle Plugin (AGP):** 8.11.1
- **Gradle Wrapper:** 8.14.0 (`gradle-8.14-bin.zip`)
- **Java / JDK:** Java 21 (OpenJDK 21.0.2 / Android Studio JBR)
- **Target / Compile SDK:** Android API 36 (`compileSdk 36`)
- **Base de Datos Local:** Isar Database (Offline Cache)
- **Backend / Realtime:** Supabase (Auth, Postgres, Realtime Sync)
- **Gestión de Estado:** Riverpod / Notifiers

---

## Decisiones de Arquitectura y Lógica de Negocio

### 1. Estrategia Offline-First y Sincronización
- **Soft Deletes:** Las eliminaciones en la app local (ej. marcas/asistencias en `MarcasNotifier`) no hacen un `DELETE` duro inmediato en la base de datos para evitar conflictos de sincronización con Supabase. Se marca el registro con un estado `deleted` para la sincronización posterior.
- **Isar Local Caching:**
  - Las entidades Isar (`PlanEntity`, `SuscripcionEntity`, etc.) deben incluir siempre un **constructor por defecto explícito** (`Entity()`) cuando utilicen `factory constructors` como `fromSupabase`.
  - Todo `getter` que retorne un tipo de dato no nativo soportado por Isar (como `Map<String, dynamic>`) **debe incluir la anotación `@ignore`** para evitar fallos en `isar_generator`.
  - Nombre de archivos de entidades en minúsculas y `snake_case` (ej. `suscripcion_entity.dart`).

### 2. UI/UX y Componentes Reutilizables
- En `EmployeeCard` se utilizan avatares ampliados y distribución compacta para evitar *overflows* en pantallas móviles.
- Las acciones de menú emergente (*PopupMenus*) en tarjetas dentro de un `GridView` o `ListView` deben envolverse en un `Builder` con `HitTestBehavior` para prevenir el bug de "ghost click" (donde presionar el menú de la tarjeta izquierda activaba la derecha).

---

## Configuración del Entorno de Compilación (Android)

- **`android/build.gradle` (Raíz):**
  - Aplica un listener seguro vía `project.plugins.withId('com.android.library')` para forzar `compileSdk = 36` y asignar `namespace` fallback en todas las librerías/plugins de terceros, evitando errores de ciclo de vida con `afterEvaluate`.
- **`android/gradle.properties`:**
  - `android.useAndroidX=true`
  - `android.newDsl=false` (requerido para compatibilidad con las extensiones de Flutter en AGP 8.x)
  - `android.skipBuildDependencyValidation=true`
  - `android.builtInKotlin=false`

---

## Historial de Soluciones e Incompatibilidades Resueltas

| Módulo / Archivo | Problema / Error | Solución Aplicada |
| :--- | :--- | :--- |
| `android/build.gradle` | Error `Cannot run Project.afterEvaluate(Closure) when the project is already evaluated` | Reemplazado `afterEvaluate` por `plugins.withId('com.android.library')`. |
| `PlanEntity` / `SuscripcionEntity` | Error de `isar_generator` (`Unsupported type` en `addonsMap` / `featuresMap`) | Agregada la anotación `@ignore` sobre los getters calculados y añadido constructor por defecto. |
| `SuscripcionEntity.dart` | Advertencia de linter `file_names` | Renombrado el archivo a `suscripcion_entity.dart`. |
| Entorno Gradle / AGP | Desalineación de versiones entre Flutter 3.47, Java 21, AGP y Gradle | Alineado AGP a `8.11.1`, KGP a `2.1.10` y Gradle a `8.14.0`. |
| `EmployeeCard` | Overflow y evento de clic fantasma en menú desplegable | Refactorizado layout con `Builder` y optimizado espacio vertical. |