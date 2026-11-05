<!-- BEGIN:nextjs-agent-rules -->

# This is NOT the Next.js you know

This version has breaking changes — APIs, conventions, and file structure may all differ from your training data. Read the relevant guide in `node_modules/next/dist/docs/` (resolved from this file's directory; in monorepos the `next` package may not be visible from the repo root) before writing any code. Heed deprecation notices.

This block is written and re-added by `next dev` — verify at `node_modules/next/dist/server/lib/generate-agent-files.js`. Removing it from a diff only re-creates the uncommitted change; committing it with your work keeps the tree clean.

<!-- END:nextjs-agent-rules -->

# AGENTS.md - BoostI Web Landing Page

## Reglas de UI (Regla de Oro)

**TODOS los widgets, modales, acordeones y transiciones de estado deben tener animaciones suaves (Framer Motion o Tailwind con duration-300 y ease-in-out). Nada de saltos bruscos. La UI debe sentirse fluida y consistente.**

## Paleta de Colores (BoostI)

- `bg-base: #0E1116` — Fondo principal
- `mint: #87FF9B` — Verde Menta
- `leaf: #44E973` — Verde Hoja
- `electric: #00B2FF` — Azul Eléctrico
- `indigo: #6366F1` — Índigo
- `lilac: #A78BFA` — Lila
- `muted: #586E5D` — Gris verdoso para bordes o textos secundarios

## Estructura de la Landing Page (orden en app/page.tsx)

1. Hero
2. Vision
3. AppModes
4. Advantages
5. Features (Módulos Interactivos)
6. HowItWorks
7. Integrations
8. Pricing
9. FAQ
10. FinalCTA
11. Footer

## Notas de Desarrollo

- Usa `framer-motion` para animaciones de entrada/salida (AnimatePresence, motion.div)
- Usa `next/link` para navegación interna entre páginas
- Nunca edites archivos autogenerados (*.g.dart, *.freezed.dart, etc.)
- Ejecuta `flutter analyze` antes de considerar completada una tarea
