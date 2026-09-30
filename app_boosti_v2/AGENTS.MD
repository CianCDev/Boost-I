# AGENTS.md

## Core Safety & Execution Rules
- **Idioma constante**: Mantén siempre la comunicación, comentarios y documentación en español, respetando el idioma del proyecto.
- **Protección de archivos autogenerados**: NUNCA edites manualmente archivos de código generado (ej. `*.g.dart`, `*.freezed.dart`, `*.isar.g.dart`). Para actualizarlos, ejecuta el comando de `build_runner`.
- **Eliminación y cambios destructivos**: NUNCA elimines archivos, carpetas o tablas de base de datos sin solicitar confirmación explícita previa al usuario.
- **Sincronización de memoria y contexto**: Consulta y mantén actualizados los archivos `AGENTS.md` y `MEMORY.md` al inicio y final de tareas complejas para preservar la continuidad del proyecto.
- **Inmutable/Sensible**: No modifiques configuraciones globales del entorno de compilación de Android (`build.gradle`, `gradle-wrapper.properties`, `settings.gradle`) a menos que sea el objetivo explícito de la tarea.

## Dev environment tips
- Usa `flutter pub get` tras agregar dependencias en `pubspec.yaml`.
- Ejecuta `dart run build_runner build --delete-conflicting-outputs` para generar o actualizar entidades de Isar y modelos de datos.
- Para verificar problemas de compilación en Android sin ejecutar el emulador completo, usa `flutter build apk --debug --android-skip-build-dependency-validation`.
- Para análisis estático de código instantáneo en todo el proyecto, ejecuta `flutter analyze`.
- Antes de modificar código en `lib/features/`, confirma la capa correspondiente (**Data**, **Domain**, **Presentation**) para respetar Clean Architecture.

## Testing & Quality instructions
- Ejecuta `flutter test` para correr la suite completa de pruebas unitarias y de widgets.
- Para ejecutar una prueba individual en específico, usa `flutter test test/ruta_del_test.dart`.
- Corrige todo error reportado por `flutter analyze` o el linter antes de considerar completada una tarea.
- Si refactorizas lógica de negocio (notifiers, repositories o entidades), actualiza o crea las pruebas unitarias correspondientes.
- Nunca des por finalizada una solución sin haber verificado que compila limpiamente sin advertencias críticas (*SEVERE* o *fatal errors*).

## PR & Commit instructions
- Formato de mensajes de commit (Conventional Commits):
  - `feat(<módulo>): <descripción breve>`
  - `fix(<módulo>): <descripción del error resuelto>`
  - `refactor(<módulo>): <cambio de estructura sin alterar comportamiento>`
  - `docs:` / `style:` / `test:` / `chore:`
- Ejecuta siempre `flutter analyze` y `flutter test` localmente antes de realizar un commit o pull request.
- Asegúrate de actualizar `MEMORY.md` si la tarea introdujo cambios arquitectónicos, nuevos módulos o ajustes clave en la pila de compilación.