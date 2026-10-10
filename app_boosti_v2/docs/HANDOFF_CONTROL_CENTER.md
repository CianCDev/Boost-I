# HANDOFF — Control Center (`app_boosti_v2`)

> Documento de traspaso para el **planificador**. Describe qué se construyó, qué está
> pendiente, qué convenciones son intocables y cómo verificar los cambios.
>
> **Última actualización:** cierre de la Subfase 5.6 (prorrateo en "Cambiar plan").
> **Módulo:** `lib/features/admin_console/` — 35 archivos Dart.
> **Estado:** funcional de punta a punta, **sin commitear** (el proyecto no es repo git).

---

## 1. Contexto del proyecto

| Dato | Valor |
|---|---|
| App | `app_boosti_v2` — gestión empresarial + POS, multi-tenant, offline-first |
| Arquitectura | Clean Architecture por característica: `lib/features/<módulo>/{data,domain,presentation}` |
| Paths | `lib/features/pos/…`, `lib/features/admin_console/…` |
| Estado | Riverpod 2.6.1 (`StateNotifierProvider`, raw `final Ref _ref;`) |
| Backend | Supabase (`supabase_flutter` 2.17.2, `postgrest` 2.9.1) |
| SDK | Dart `^3.3.0` · Flutter 3.47.2 · compila Android API 36 |
| Entry points | `lib/main_admin.dart` (Control Center), `lib/main_client.dart` (POS) |
| Tema | `app.dart` usa `pos/…/themes/theme.dart`; `themeProvider` arranca en **`ThemeMode.light`** |

DocumentosExists related: `MEMORY.md` (arquitectura+pila), `AGENTS.md` (reglas),
`docs/business_rules.md` (paleta obligatoria), `docs/TODO.md` (deuda técnica).

---

## 2. Reglas del proyecto (NO negociables)

### Idioma
Comunicación, comentarios y documentación **siempre en español**.

### Paleta obligatoria (`docs/business_rules.md`)
| Semántica | Color |
|---|---|
| success | `0xFF10B981` |
| warning | `0xFFF59E0B` |
| error | `0xFFEF4444` |
| info / acento | `0xFF8B5CF6` |
| neutro | `colorScheme.onSurfaceVariant` |

### Componentes
- **Reutilizar** los componentes POS existentes; no duplicar:
  `GlassCard`, `GlassDialog`, `DialogHeader`, `CardActionButton`, `ActiveToggle`,
  `SegmentedToggle`, `FormSection`, `PersonaTextField`, `FormActions`, `StatusBadge`, `FiltroChip`.
- **Prohibido**: `Card` (usar `GlassCard`), `intl` (helpers propios de fecha),
  `Colors.grey`/`Colors.white` hardcodeados — con 3 excepciones ya autorizadas:
  chips de modos, `Switch.activeThumbColor`, y **dentro del banner de prorrateo**
  (superficie oscura, igual que `cobrar_dialog.dart`).
- **`GlassDialog` NO aplica padding interno** → todo su contenido va envuelto en
  `Padding(EdgeInsets.all(24))`.
- **No añadir dependencias.**
- **No tocar** `*.g.dart` (Isar) → usar `build_runner`.

### Seguridad
- **Nunca borrar** archivos, carpetas o tablas sin confirmación explícita.
- No modificar `build.gradle`, `gradle-wrapper.properties`, `settings.gradle`.

### Verificación
- `flutter analyze` → **0 issues** antes de cerrar cada tarea.
- Si refactorizas lógica de negocio → actualizar/crear pruebas.
- Commits: `feat(<módulo>): …`, `fix(<módulo>): …`, `refactor(…)`, `docs:`, `test:`, `chore:`.

---

## 3. ⚠️ Limitación crítica del entorno de agente

**`flutter analyze` / `dart analyze` NO son ejecutables** en el entorno del agente:
`dart.exe` devuelve **exit 255 con cero bytes de salida**. Hay procesos `dart.exe`
zombis acumulados. Diagnóstico previo: reiniciar el equipo o
`rmdir /s /q C:\Users\Yan\dev\flutter\bin\cache` + `flutter precache`.

**Consecuencia:** el **LSP del usuario es la única verificación de tipos real**.
Todo lo que el agente entregue queda *sin verificar por analizador* hasta que el
usuario ejecute `flutter analyze` y pase el output.

### Método de verificación sustituto (el agente debe usarlo siempre)
1. **Balance de delimitadores** por archivo: `{}`, `()`, `[]` → deben dar 0.
2. **Líneas > 80 chars** → deben dar 0 (convención del repo).
3. **Estructura de clases por brace matching** → ninguna clase sin cerrar,
   ningún solapamiento.
4. **Mapeo símbolo → tipo declarado**: partir el archivo por `class`/`enum` y
   verificar que cada referencia resuelva. *Las verificaciones por nombre
   ("existe X") NO detectan errores de tipos.*
5. **Verificar cada ruta de import resuelve a un archivo real.**
6. **Simular la lógica con datos reales de la BD** antes de entregar.

> **Lección aprendida (4 veces en este proyecto):** los bugs que se colaron
> siempre fueron de *scope* o de *tipo*, nunca de *sintaxis*.
> - `_lineaConversion` quedó a nivel de archivo → 7 errores de unresolved.
> - `planes.when(...)` sobre un `List<Plan>?` → `unchecked_use_of_nullable_value`.
> - `sub.label` (getter del enum, no de la clase).
> - imports a `common/appbar.dart` inexistente (el real es `common/../appbar.dart`).
> - El **Fix 3.3.1** de "Trial · Trial" se aplicó en el lugar equivocado
>   (`_prefijo` compara plan vs estado) cuando el duplicado real lo producía
>   `ClientCard._subtitulo()`, que antepone el plan por su cuenta.

---

## 4. Fases completadas

### Fase 1 — Dashboard ✅
6 modelos, 6 repositorios (25 métodos), 4 providers, 5 widgets,
`AdminDashboardScreen` + navegación en `ControlCenterScreen`.
- `saas_metrics` es **matview** con RLS desactivado; se refresca con
  `refresh_saas_metrics()` (SECURITY DEFINER, retorna void).
- Patrón de error: pantalla completa solo si nunca hubo carga exitosa;
  con datos → franja de error inline (no perder KPIs).

### Fase 3 — Clientes ✅
- `clients_provider.dart`: 6 filtros, `counts` reactivo, `ClientItem(tenant, suscripcion, plan)`.
- `clients_screen.dart` (318 líneas), `ClientCard` (196 líneas).
- `client_detail_screen.dart`: 4 tabs, navegación `NavigationRail`/`NavigationBar` + `IndexedStack`.

### Fase 4 — Planes ✅
- `plans_repository.dart` (291 líneas): 8 métodos (3 lectura + 5 escritura).
- `plans_provider.dart` + `PlanesActionsNotifier` con invalidación cruzada.
- `plan_card.dart` (232 líneas) + `plans_screen.dart` (848 líneas): CRUD completo,
  `_PlanFormDialog` con 4 `FormSection` y validación de slug.

### Fase 5 — Ficha de cliente ✅
| Subfase | Alcance | Estado |
|---|---|---|
| 5.1 | Notas reales (crear / fijar / eliminar) | ✅ |
| 5.2 | Pagos reales (registrar / marcar pagado) | ✅ |
| 5.3 | Conversión BCV (moneda → USD normalizada) | ✅ |
| 5.4 | Suscripción real (extender / cambiar plan / cancelar / reactivar) | ✅ |
| 5.5 | Fix de incoherencias visuales del tab Suscripción | ✅ |
| 5.6 | Prorrateo en "Cambiar plan" | ✅ |

### Diálogos implementados en `client_detail_screen.dart` (2857 líneas)
| Diálogo | Estado |
|---|---|
| `_NuevaNotaDialog` | ✅ funcional |
| `_NuevoPagoDialog` | ✅ funcional + conversión BCV en vivo |
| `_CambiarPlanDialog` | ✅ funcional + banner de prorrateo |
| `_CancelarSuscripcionDialog` | ✅ funcional |
| Confirmaciones de Extender trial / Reactivar / Marcar pagado | ✅ vía `_confirmarAccion()` |

---

## 5. Arquitectura de la ficha de cliente

```
client_detail_screen.dart
 ├─ _ClientDetailScreenState      (1.430 líneas — HERO, 4 tabs, utilidades)
 ├─ _NuevaNotaDialog / State
 ├─ _NuevoPagoDialog / State      (BCV: _formatoMiles, _factorAUsd, _lineaConversion)
 ├─ _CambiarPlanDialog / State     (prorrateo: _creditoPlanActual, _cargoNuevoPlan…)
 ├─ _CancelarSuscripcionDialog / State
 ├─ _CampoSelect<T>               (genérico, con `etiquetaDe` opcional)
 ├─ _BotonFecha
 └─ _ChipLegacy
```

### `client_detail_provider.dart` (429 líneas) — 10 métodos de escritura
| Método | Patrón |
|---|---|
| `agregarNota`, `toggleFijadaNota`, `eliminarNota` | repo directo + `_recargarNotas()` |
| `registrarPago`, `actualizarEstadoPago` | repo directo + `_recargarPagos()` |
| `extenderTrial`, `cambiarPlan`, `cancelar`, `reactivar` | **delegan** en `SubscriptionsActionsNotifier` + `_recargarSuscripcion()` |

**Patrón de escritura (uniforme):** validar guarda → `try/catch` con
`debugPrint` → operación → `_recargarX()` parcial → devolver `bool`.
Ningún método propaga excepciones.

### `utils/resolver_usuario_id.dart` (26 líneas) — cascada de 3 niveles
```dart
String? resolverUsuarioId(Ref ref) {
  // 1. Usuario de la app (POS, Isar cargado)
  // 2. Sesión de Supabase Auth (Control Center)
  // 3. null — las columnas nullable lo aceptan
}
```
> **Bug histórico grave que corrige:** se usaban los centinelas `'sistema'` y
> `'desconocido'`, que **no son UUID válidos** y hacían fallar los INSERT/UPDATE
> con `invalid input syntax for type uuid` en `notas_cliente.autor_id`,
> `pagos.registrado_por` y `suscripcion_historial.cambiado_por`.
> **Cualquier columna uuid nueva DEBE aceptar `null`.**

---

## 6. Esquema de BD verificado (Supabase)

Conexión (⚠️ **el password de abajo fue rotado; ver §11. Pedir uno nuevo al
admin del proyecto. Nunca escribir la cadena real acá**):

```
postgresql://postgres.<PROJECT_REF>:<PASSWORD>@aws-0-us-east-1.pooler.supabase.com:5432/postgres?sslmode=require
```

El `<PROJECT_REF>` está en `env.json` → `SUPABASE_URL`.
⚠️ El flag **`?sslmode=require` es obligatorio**; sin él falla silenciosamente.
⚠️ La CLI `supabase` no funciona (exit 255). `psql` sí.

### Tablas del Control Center
| Tabla | Notas |
|---|---|
| `planes` | `id` TEXT PK **sin default** (lo manda la app). 8 columnas. |
| `suscripciones` | `tenant_id` **UNIQUE** · `plan_id → planes.id` · CHECK en `estado` |
| `pagos` | ver abajo |
| `notas_cliente` | `autor_id uuid` **nullable** |
| `suscripcion_historial` | ver abajo |
| `saas_metrics` | matview, RLS off |

### `pagos` — columnas actuales
```
id uuid PK | tenant_id uuid NOT NULL | suscripcion_id uuid NULL
monto numeric(10,2) NOT NULL | moneda text NULL DEFAULT 'USD'
estado text NULL DEFAULT 'pendiente'   CHECK: pendiente|pagado|fallido|reembolsado
metodo text | referencia text
pagado_en timestamptz | periodo_inicio timestamptz | periodo_fin timestamptz
notas text | registrado_por uuid NULL | created_at timestamptz NULL
--- Subfase 5.3 ---
tasa_conversion numeric(20,10) NULL | monto_original numeric(12,2) NULL | moneda_original text NULL
```
- FK: `tenant_id → tenants(id) ON DELETE CASCADE`, `suscripcion_id → suscripciones(id)`
- RLS: `pagos_read` (SELECT: `tenant_id = get_my_tenant_id() OR is_superadmin()`), `pagos_write` (ALL: `is_superadmin()`)
- ⚠️ **`locales` NO tiene policy INSERT** (42501) → usar `update` en vez de `upsert`.

### `suscripcion_historial` — columnas
```
id uuid PK | suscripcion_id uuid NOT NULL → suscripciones(id) ON DELETE CASCADE
tipo_cambio text NOT NULL | plan_origen_id text NULL → planes(id)
plan_destino_id text NULL → planes(id)
estado_origen text NULL | estado_destino text NULL
cambiado_por uuid NULL | notas text NULL | created_at timestamptz NULL
```
RLS: `hist_admin` (ALL). **Todas las tablas admin requieren `is_superadmin()`.**

### Semántica de la conversión (decisión P4 del usuario)
`tasa_conversion` = **factor multiplicativo de `moneda_original` → USD**.
Invariante: `monto == monto_original * tasa_conversion`. `moneda` siempre queda `'USD'`.

| Original | Factor guardado |
|---|---|
| USD | `1.0` |
| Moneda local (VES/COP…) | `1 / bcv.tasa` |
| EUR | `bcv.tasaEuro / bcv.tasa` |

> ⚠️ **Por eso `numeric(12,4)` era insuficiente**: `1/860.1753 = 0.00116256` se
> redondeaba a `0.0012` → **+3,2% de error**. El usuario migró a `numeric(20,10)`.

### Datos vivos (a fecha del handoff)
| Plan | precio/mes | max_locales | orden | activo |
|---|---|---|---|---|
| trial | 0 | 999999 | 0 | sí |
| basico | 25 | 2 | 1 | sí |
| pro | 60 | 999999 | 2 | sí |
| corporativo | 220 | 999999 | 3 | sí |

⚠️ **`trial` y `pro` NO son eliminables** por FK (`suscripcion_historial` los referencia).

**Suscripciones:**
| estado | plan_id | trial_vence_en | periodo_fin | cancelado_en |
|---|---|---|---|---|
| activo | trial | 17 Oct | 31 Oct | — |
| activo | pro | 16 Oct | 31 Oct | — |
| cancelado | trial | 16 Oct | 16 Oct | 21 Sep |
| trial | trial | 16 Oct | 16 Oct | — |
| trial | trial | 16 Oct | 16 Oct | — |

> ⚠️ **`trial_vence_en` queda POBLADO en planes de pago.** Cualquier lógica que
> detecte trial **solo por fecha** mostrará "Trial vence en" en un plan Pro.
> El criterio correcto (ya aplicado en `_etiquetaPeriodo` y
> `_subtituloPorEstado`) es: `hayTrialVigente && (plan.id == 'trial' || estado == trial)`.

Modos: `restaurante`, `retail`, `servicios`. Tenants: centro (id_isar 1),
JAHTLABS (id_isar 2). Usuario admin `ian` = `604e9b98-354b-4fd6-b816-af97b47c1b0e`.

---

## 7. Decisiones de diseño que hay que respetar

### `copyWith` no puede limpiar un nullable
Usa `suscripcion ?? this.suscripcion` → **pasar `null` conserva el valor anterior**.
Documentado en `_recargarSuscripcion()`. Si alguna vez una acción borra la
suscripción, hace falta un método `aSinSuscripcion()` que reconstruya el estado.

### `StateNotifier` vs `FamilyNotifier`
`FamilyNotifier extends BuildlessNotifier` y **`StateNotifierProvider.family` exige
`StateNotifier`**. No son intercambiables. El proyecto usa
`extends StateNotifier<T>` + `final Ref _ref;` (raw, equivale a `Ref<dynamic>`).

### postgrest 2.9.1
- `.inFilter()` / `.isFilter()` — **no** existen `.in()` ni `.is()`.
- `select()` es posicional: `.select('*, tabla(*)')`.
- Para contar: `.select(…).eq(…).count(CountOption.exact)` → `PostgrestResponse.count` (`int` no-nullable).
- `.update().eq().select()` → `PostgrestResponse`; `response.isEmpty` = 0 filas.
- Los embeds anidados pueden llegar como `Map` o `List` (p. ej. `suscripciones`
  es UNIQUE) → normalizar con helper tolerante.
- NUMERIC puede llegar como `num` **o** `String` → helper `_doble()` en `Payment`.

### Rivers/API deprecadas en esta versión de Flutter
| Parámetro viejo | Usar |
|---|---|
| `Switch.activeColor` | `activeThumbColor` (deprecado tras 3.31) |
| `DropdownButtonFormField.value` | `initialValue` (deprecado tras 3.33) |

`analysis_options.yaml` **no** ignora `deprecated_member_use` ni `unused_element`.

### `FamilyNotifier` / `Plan.descripcion` en `Column`
Las propiedades de clase **no** se empujan por nulabilidad (no son variables
locales) → hace falta `!` explícito tras un guard.

### Formato de números
- **Control Center**: `_formatoMiles(n)` → coma decimal y separador de miles
  (`51.600,00`). Helper a nivel de archivo, reusado en 3 sitios.
  Deliberadamente **NO** usa `BcvController.formatearLocal()` (que no pone
  separador de miles).
- **POS**: usa `BcvController.formatear*` con punto decimal. **No unificar sin
  decisión global.**

---

## 8. Pendientes

### 8.1 Bloqueantes / deuda técnica
| # | Qué | Ubicación |
|---|---|---|
| 1 | **`client_detail_screen.dart` tiene 2857 líneas** → dividir por tab | deuda conocida, ver `docs/TODO.md` |
| 2 | `client_detail_provider` no auto-carga; la ficha llama `cargar()` en `initState` vía `addPostFrameCallback` | rompe un poco el patrón Riverpod |
| 3 | **Todo `admin_console` está sin commit** (el proyecto no es repo git) | decidir si inicializar git |

### 8.2 Funcionales
| # | Qué | Detalle |
|---|---|---|
| 4 | **`suscripcion_historial` no se lee** | El tab Suscripción muestra `EmptyState` "próximamente". La tabla ya tiene RLS `hist_admin` y los repos **ya escriben** en ella (`tipoCambio`: `plan_actualizado`, `trial_extendido`, `suscripcion_cancelada`, `suscripcion_reactivada`). Solo falta el `SELECT`. |
| 5 | **4 filtros de `clients_provider` son incompletos** | `trial`, `porVencer`, `vencidos`, `cancelados` requieren cruzar con suscripciones |
| 6 | **KPIs de Resumen con "—"** | `Locales`, `Usuarios`, `Última actividad` (TODO Subfase 3.3.3) |
| 7 | **2 `CardActionButton` del Dashboard con `onPressed: () {}`** | `admin_dashboard_screen.dart:343` y `:349` |
| 8 | **`registrarPago` del provider** aún no tiene consumer en UI | el diálogo `_NuevoPagoDialog` lo llama ✅ pero la ruta de pago rápido del Resumen pasa por `_dialogoNuevoPago` ✅ — **revisar si queda algún camino muerto** |

### 8.3 Correcciones de datos conocidas
| # | Qué |
|---|---|
| 9 | La suscripción `cancelado` tiene `auto_renovar = true` (filas anteriores a que `cancelar` lo forzara). Ya **parcheado en la UI**, pero el dato sigue sucio en BD |
| 10 | Pagos legacy con `moneda != 'USD'` y `tasa_conversion = null` → se muestran con chip `legacy`, **sin migrar** (decisión del usuario: son datos de prueba) |

---

## 9. Cómo retomar el trabajo

### Flujo estándar de cada tarea
1. **Diagnóstico primero** (el usuario lo exige explícitamente en cada prompt).
2. Leer el código real, nunca asumir de memoria. Verificar firmas de:
   - componentes/widgets que se van a reutilizar
   - métodos de repositorio
   - `copyWith` del estado
   - enum `Provider` (`FutureProvider` vs `StateNotifierProvider`)
3. Si el prompt trae una spec que **contradice el código real**, decirlo antes de
   editar. (Ocurrió ~8 veces: `bcvProvider` no expone `.usd`/`.eur`,
   `listarPorTenant` "no existía" por un fallo de regex mío,
   `copyWith` con `Object?`/`_undefined`, etc.)
4. Implementar **solo** lo pedido. No refactorizar de más.
5. Verificar con los 6 métodos de la §3.
6. Reportar diff + el resultado del análisis, aunque sea "no pude ejecutar".
7. **Detenerse y esperar OK.**

### Comandos útiles
```powershell
cd "C:\Users\Yan\app_gestion_m\app_boosti_v2"

# Verificar (espera exit 255 / 0 bytes)
flutter analyze

# Búsquedas
gci -Path .\lib -Recurse -Filter *.dart | sls "patron"
gci -Path .\lib\features\admin_console -Recurse -Filter *.dart |
  sls "TODO|proximamente|onPressed: \(\) \{\}" | Select Path, LineNumber, Line

# BD  (leer el password de env.json, nunca escribirlo literal en un doc)
$env:PGPASSWORD=(Get-Content env.json | ConvertFrom-Json).SUPABASE_DB_PASSWORD
psql "host=aws-0-us-east-1.pooler.supabase.com port=5432 user=postgres.<PROJECT_REF> dbname=postgres sslmode=require" -c "<SQL>"
```

### Mapa de archivos del módulo
```
lib/features/admin_console/
├── data/models/          6  plan · tenant · suscripcion · saas_metrics · client_note · payment
├── data/repositories/    6  tenants · plans · subscriptions · payments · notes · metrics
├── providers/            6  admin_access · admin_dashboard · plans · clients · subscriptions · client_detail
├── presentation/screens/ 6  control_center · admin_dashboard · clients · plans · client_detail · dev_tools
├── presentation/widgets/ 6  kpi_card · plan_card · client_card · empty_state · section_header · status_badge_tenant
├── services/             2  admin_service · metrics_service  ←AMBAS STUB, sin usar
└── utils/                1  resolver_usuario_id
```
> `admin_service.dart` y `metrics_service.dart` son **stubs con `TODO`** y no los
> usa nadie. Candidatos a borrado (con autorización).

---

## 10. Estado del análisis del último ciclo

El usuario aplicó los fixes de la Subfase 5.6 + 2 ajustes y **no ha reportado
el resultado de `flutter analyze`** posterior. Pendiente de confirmar:

- [ ] `_selectorPlan` con `isLoading`/`hasError` (sin `planesAsync.when`)
- [ ] `valor: idSeleccionado ?? otros.first.id` (sin `!`)
- [ ] `_subtituloPorEstado` refactorizado, `_prefijo`/`_normalizar` eliminados
- [ ] Filas de prorrateo con `mostrarCredito` / `mostrarCargo`
- [ ] `otros` + `idSeleccionado` compartidos entre dropdown y banner

### Riesgos residuales conocidos
| Riesgo | Dónde |
|---|---|
| `import 'package:supabase_flutter/supabase_flutter.dart';` en `client_detail_provider.dart` | nunca se había importado ese paquete ahí |
| `Suscripcion? suscripcion` en `_CambiarPlanDialog` (campo nuevo en el constructor) | 5.6 |
| `AsyncValue<List<Plan>>` como tipo de parámetro | `_selectorPlan` |
| `data: (lista)` **quedó sin uso** tras unificar `otros` en `build` | `_selectorPlan` — Dart no avisa de parámetros sin usar |
| `_diasRestantesCiclo` con `.clamp(0, 30)` devuelve `num`, forzado a `int` por contexto | 5.6 |

---

## 11. Credenciales expuestas: rotar YA

🚨 **Las tres credenciales de abajo quedaron escritas en texto plano durante el
desarrollo y hay que rotarlas, sin esperar a que el repositorio sea público.**

| Credencial | Dónde vive hoy | Estado |
|---|---|---|
| Password de la base Supabase | `env.json` (ignorado por git) | ⛔ **A rotar** |
| Personal Access Token de Supabase (`sbp_…`) | `env.json` (ignorado por git) | ⛔ **A rotar** |
| DSN de Sentry | `env.json` (ignorado por git) | ⚠️ Revisar |

Motivos para considerarlas comprometidas:

1. Se transcribieron en texto plano en este documento. GitHub push protection
   bloqueó el push por el `sbp_…` el 2026-10-10, así que **nunca llegó al
   remoto**, pero existed en el working tree y en el historial local.
2. Se/shared en una conversación de trabajo, que muy probablemente pasó por un
   proveedor de IA externo. Ese canal no está bajo control de este repo.
3. El PAT `sbp_…` es una credencial de cuenta con permisos amplios. No es solo
   un token de proyecto.

### Cómo rotarlas

**Supabase PAT** — Dashboard → Account Preferences → Personal Access Tokens.
Revocar el viejo y generar uno nuevo con el mínimo de scopes. Después actualizar
`env.json`.

**Password de la base** — Supabase no permite rotar el password del proyecto
desde el panel de forma directa; hay que hacerlo desde el panel del proyecto o
desde SQL, y actualizar `env.json`.

**Sentry** — el DSN de un proyecto cliente es público por diseño (viaja dentro
de la app), pero la clave de ingest se puede rotar en
Project Settings → Client Keys sin romper nada.

### Regla para adelante

Ningún secreto se escribe en un archivo del repo, **aunque el archivo esté en
`.gitignore`**: `.gitignore` evita que se suba, pero no evita que quede en un
backup, en un `.bak`, o en la pantalla de otra persona. La variable de entorno
es el único lugar donde debe vivir, y el valor se pega en la UI de
configuración en vez de en un documento.