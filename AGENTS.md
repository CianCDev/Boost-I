# Reglas del proyecto Boosti POS

## Web: Next.js y Netlify

- La web se publica como exportación estática. `app_gestion_web/next.config.ts` debe conservar `output: 'export'` y `images.unoptimized: true`.
- `netlify.toml` debe usar `base = "app_gestion_web"`, `command = "npm run build"` y `publish = "out"`.
- Las páginas con estado, eventos o formularios interactivos deben ser Client Components (`'use client';` antes de los imports).
- Para recuperar una versión histórica, revisar primero `git status` y los archivos afectados; restaurar solo el path necesario con `git checkout <commit> -- <path>`. Nunca restaurar Flutter cuando el alcance sea solo web.
- Validar exportación desde `app_gestion_web` con `npm run build` y confirmar que se genera `out/`.

## App Flutter

- Los cambios de cantidad deben actualizar el total de forma reactiva. Teclado y balanza deben converger en el mismo cálculo y agregar al carrito la cantidad actual.
- Compartir `ScaleService` mediante Riverpod. Conectar al abrir el flujo y liberar recursos según el ciclo de vida definido por el provider; no crear conexiones paralelas.
- Ejecutar pruebas dirigidas y `flutter analyze` después de cambios Dart. Los avisos preexistentes deben reportarse, no corregirse fuera del alcance.

## Despliegue

- Los releases y patches Shorebird de Android y Windows se ejecutan mediante GitHub Actions; no lanzar builds OTA localmente en Windows.
- Android y Windows usan workflows separados. Verificar la versión de release objetivo y el flavor antes de dispararlos.
- `--allow-asset-diffs` permite publicar cambios de código aunque haya diferencias de assets; los assets modificados no se incluyen en el patch. Confirmar si requieren un release base nuevo.
- No hacer force-push ni omitir hooks.
