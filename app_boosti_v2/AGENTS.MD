# AGENTS.md — Reglas para agentes IA trabajando en Boosti POS

> Este documento define las reglas de engagement, convenciones de código y
> workflows esperados al modificar el repositorio. Cualquier agente IA
> (Copilot, Cursor, Claude Code, etc.) debe leerlo antes de hacer cambios.

## 1. Filosofía del proyecto

Boosti POS es un sistema POS offline-first multi-tenant. Los clientes
(tenants) son dueños absolutos de sus datos operativos. **La privacidad y
la inmutabilidad de datos son requisitos no negociables**.

- **Offline-first**: la app funciona sin internet. El sync con Supabase
  es eventual.
- **Multi-tenant**: cada local (tenant) tiene datos aislados por RLS.
- **Multi-modo**: cada local opera en `mercado`, `restaurante` o `servicios`.
- **Auditable**: toda acción sensible queda registrada.

## 2. Reglas de engagement para agentes IA

### 2.1. Antes de editar

1. **Lee siempre antes de editar.** Si vas a modificar un archivo, primero
   léelo para confirmar su estado real.
2. **Si un `Edit` falla una vez, NO reintentes con el mismo `oldString`.**
   Lee el archivo y reporta el estado actual.
3. **Máximo 2 intentos de Edit por línea.** Al segundo fallo, para y reporta.
4. **Usa `oldString` mínimos.** Prefiere 1-2 líneas sobre bloques grandes.

### 2.2. Al reportar

1. **Nunca digas "listo" sin haber corrido `flutter analyze`.**
2. Si `flutter analyze` tiene errores, para y reporta.
3. Los warnings (`unused_import`, `unused_field`) son aceptables pero
   debes listarlos.
4. Si un cambio puede romper algo, dilo ANTES de aplicarlo.

### 2.3. Qué NO hacer sin autorización explícita

- ❌ **Borrar archivos** (solo renombrar a `.bak` o comentar).
- ❌ **Refactorizar código no relacionado** con la tarea.
- ❌ **Cambiar la estructura de entidades Isar** existentes.
- ❌ **Modificar RLS de Supabase** (eso es manual del owner).
- ❌ **Añadir dependencias** sin consultar.
- ❌ **Rename de métodos públicos** de servicios clave.
- ❌ **Touch `main.dart`** sin autorización.
- ❌ **Modificar `SyncService`** sin contexto completo.

## 3. Reglas de datos — INMUTABILIDAD

### 3.1. Entidades inmutables

Estas entidades **no pueden ser editadas ni eliminadas** (ni por admin
del tenant ni por super admin):

| Entidad | Isar | Supabase |
|---------|------|----------|
| Ventas | Solo INSERT | Solo INSERT + SELECT |
| Detalle de ventas | Solo INSERT | Solo INSERT + SELECT |
| Movimientos de inventario | Solo INSERT | Solo INSERT + SELECT |
| Pagos de venta | Solo INSERT | Solo INSERT + SELECT |
| Logs de auditoría | Solo INSERT | Solo INSERT + SELECT |

**Anulación**: se hace por **contra-registro** (`VentaAnuladaEntity`,
`GastoAnuladoEntity`), nunca editando el original.

### 3.2. Entidades con ventana de edición

| Entidad | Ventana | Comportamiento |
|---------|---------|----------------|
| Gastos | 24h | Editable durante 24h, después inmutable |
| Turnos | Hasta cierre | Editable hasta `fechaCierre`, después inmutable |

### 3.3. Verificación antes de escribir métodos de edición

Antes de añadir un método `actualizarX` o `eliminarX` en `IsarService`:

1. Verifica si la entidad es inmutable (tabla 3.1).
2. Si es inmutable, **no añadas el método**. Usa contra-registros.
3. Si es editable, verifica la ventana.

## 4. Estructura del proyecto

```
lib/
├── core/
│   ├── config/          → supabase_config, env vars
│   ├── network/         → hardware gateway
│   └── security/        → telegram_crypto
├── features/pos/
│   ├── data/Local/entities/     → Isar entities + .g.dart
│   ├── data/remote/             → repositorios Supabase
│   ├── domain/                  → modelos, permisos, feature flags
│   └── presentation/
│       ├── providers/           → Riverpod
│       ├── screens/             → UI
│       ├── services/            → lógica de negocio
│       ├── widgets/             → componentes
│       └── utils/               → helpers
└── main.dart
```

## 5. Convenciones de código

### 5.1. Entidades Isar

```dart
import 'package:isar/isar.dart';

part 'mi_entidad.g.dart';   // ⚠️ part con el nombre completo del archivo

@collection
class MiEntidad {
  Id id = Isar.autoIncrement;
  // ...
  @ignore
  Map<String, dynamic> get miHelper => ...;  // helpers van con @ignore
}
```

**Regla**: el `part` siempre debe coincidir con el nombre del archivo +
`.g.dart`.

### 5.2. Providers Riverpod

- **`Provider`**: dependencias puras (servicios, repositorios).
- **`FutureProvider`**: fetch asíncrono cacheado.
- **`StreamProvider`**: escucha reactiva de Isar o Supabase.
- **`StateNotifierProvider`**: estado mutable complejo.
- **`StateProvider`**: estado simple (contadores, filtros).

**Nunca** uses `invalidate` sobre `StateNotifier` — pierde estado interno.
Llama a un método `.refrescar()` del notifier.

### 5.3. Servicios

- Un servicio = una responsabilidad. `SyncService` sincroniza.
  `VentaAnulacionService` anula. No mezcles.
- Los servicios públicos deben tener métodos pequeños y enfocados.
- Los métodos privados van con prefijo `_`.

### 5.4. Sync con Supabase

- **Anti-eco**: toda tabla que se suba debe tener un flag `_escribiendoX`
  que bloquee los eventos realtime mientras escribimos.
- **Last-Write-Wins**: usa `updated_at` para resolver conflictos.
- **Nunca envíes `updated_at` desde el cliente** en tablas con trigger
  server-side (usuarios, locales).
- **Debounce** de 5s en realtime para agrupar ráfagas.

### 5.5. UI

- `ResponsiveHelper.isMobile/isTablet/isDesktop` para layouts.
- Componentes reutilizables en `widgets/common/`.
- Diálogos con `GlassDialog` + `DialogHeader` + `FormActions`.
- Cards con `GlassCard` o `PosMenuCard`.
- Hover con `MouseRegion` + `AnimatedContainer` (200ms, easeOutCubic).

## 6. Modo de negocio (business mode)

### 6.1. Modos soportados

- `mercado` — default, retail.
- `restaurante` — mesas, comandas.
- `servicios` — citas, profesionales.

### 6.2. Reglas

- Vive en `LocalEntity.businessMode` + `locales.business_mode`.
- **Solo admin** puede cambiarlo.
- `featureFlagsProvider` deriva el modo + el plan y expone getters.
- **Nunca** hagas `if (mode == 'restaurante')` directo en UI.
  Usa `flags.mostrarMesas`, `flags.requiereMesa`, etc.

## 7. Super admin / Dev Mode

### 7.1. Principios

- **NO acceso a datos operativos del tenant** (ventas, gastos, productos).
- **Solo metadata contractual** (nombre, RIF, plan, estado).
- **Read-only** sobre datos del tenant.
- **Auditoría obligatoria** de cada acción.
- **Sin impersonación**.

### 7.2. Cómo verificar is_super_admin

- En Supabase: `SELECT is_super_admin();`
- En Dart: `ref.read(superAdminProvider)` (a futuro).
- El JWT debe tener el claim correspondiente.

### 7.3. Nunca añadas policies RLS permisivas

Si un super admin necesita algo, se hace vía **RPC con validación
explícita**, no vía policy abierta.

## 7.3 Nunca ocultar el producto por un flag que no existe

`FeatureFlags._plan()` es:

```dart
bool _plan(String f, {bool defaultVisible = false}) =>
    planActivo && (featuresHabilitadas.contains(f) || defaultVisible);
```

`planActivo` es un `&&` corto. Si el tenant no tiene suscripción activa
—o si no se pudo leer— **no se ve NADA**, ni siquiera las features con
`defaultVisible: true`. El menú entero desaparece con una línea de error
en el log y nada en pantalla.

Tres reglas:

1. **La clave en Dart tiene que existir en `planes.features`.** La tabla
   tenía 4 claves (`offline`, `reports`, `multi_local`,
   `priority_support`) y el menú consultaba ~20. Las getters "huérfanas"
   chaqueaban con `defaultVisible: true` y un `TODO(R.0)`, pero **nunca
   se activaban**. Cada getter nuevo necesita su clave en la BD o queda
   muerto. Reparto vigente: `20261015000002_plan_features.sql`.
2. **Un tenant sin fila en `suscripciones` no ve nada.** Fail-closed a
   propósito (cobrar sin plan debe negar acceso), pero dar de alta un
   tenant sin suscripción **oculta el producto entero**. La tabla la
   puebla la Edge Function `create-tenant`; los tenants anteriores a su
   deploy no tienen fila.
3. **Antes de agregar un gate de plan, verificá si el módulo hoy está
   abierto a todos.** `'proveedores' => !flags.esServicios` consultaba
   solo el modo: el plan básico veía Proveedores sin haberlo contratado.

## 7.4 La policy de `locales` es una fila por tenant

En este modelo **`locales.id` ES el `tenant_id`**: cada local es un
tenant. El baseline define `USING ((id = public.current_tenant_id()))`.

⚠️ **Se modificó a mano en el dashboard** (2026-10-15) agregando un brazo
`EXISTS` sobre `usuarios_locales` que hacía que un usuario viera todo
local del que tuviera fila. No estaba versionado: repo y BD divergieron
en silencio y con el JWT de un tenant se descargaron los locales de 5.

**El multi-local no necesita ese brazo:** cambiar de local usa la RPC
`set_active_tenant()` + `refreshSession()`, y el selector se alimenta de
`mis_locales()` (`SECURITY DEFINER`). Ninguna hace `SELECT` directo.

**Toda policy tocada en el dashboard va en una migración el mismo día.**
Para auditar drift:

```sql
SELECT tablename, policyname, cmd, qual FROM pg_policies
 WHERE schemaname = 'public' ORDER BY tablename;
```

El `EXISTS` con `usuarios_locales` solo aparecía en `locales`; el resto
de las tablas usa `tenant_id = current_tenant_id()`.

### 7.4.1 Las policies permisivas se ORean

`locales` tenía DOS policies de SELECT:

```sql
locales_tenant_select     roles = {authenticated}  (id = current_tenant_id())
super_admin_read_locales  roles = {public}        is_super_admin()
```

Postgres combina las policies permisivas con **OR**, no con AND. Con el
JWT de un tenant, `current_tenant_id()` devolvía bien `9c7380a4` pero
la segunda policy ganaba: **5 locales de 5 tenants**.

Probado el 2026-10-15 con `SET role authenticated` + `request.jwt.claims`.

⚠️ El POS y el `admin_console` comparten `Supabase.instance.client`, o
sea **la misma sesión y el mismo JWT**. El owner del SaaS tiene
`is_superadmin = true`, así que dentro del POS veía todos los locales.

`super_admin_read_locales` se dropeó en `20261015000004`: no tenía
consumidor (`admin_console` usa `tenants`, no `locales`) y `service_role`
ya bypasea RLS. Cuando se implemente la Subfase 3.3.3 del Control
Center, el camino es una **RPC `SECURITY DEFINER` con validación
explícita**, no reactivar la policy.

## 7.5 Un gate que parece existir y no existe

Tres bugs del 2026-10-15, los tres con la misma forma: **una condición
que parecía gatear y no gateaba nada**. Salieron todos en cadena, uno
destapando al siguiente.

### 7.5.1 `activa` comparaba contra un valor que el CHECK prohíbe

```dart
if (estado == 'activa') { ... }   // femenino, NO existe en la base
```

`suscripciones_estado_check` solo admite `('trial','activo','vencido',
'cancelado','expirado')`. **`'activa'` es imposible en la base.** El
getter caía siempre en `return false`, o sea `planActivo = false` para
todos los tenants desde el día uno.

`FeatureFlags._plan()` arranca con `planActivo &&`, así que sin plan
activo no se ve NADA. El síntoma era un POS vacío con la suscripción
pagada y el log diciendo `pro (activo)`.

**Regla:** el valor de un enum en Dart tiene que existir en la base.
Verificá los dos lados:

```sql
SELECT pg_get_constraintdef(oid) FROM pg_constraint
 WHERE conrelid = 'public.suscripciones'::regclass;
```

### 7.5.2 `defaultVisible: true` hace el gate inoperante

```dart
bool _plan(String f, {bool defaultVisible = false}) =>
    planActivo && (featuresHabilitadas.contains(f) || defaultVisible);
```

Con `defaultVisible: true` la expresión queda `planActivo && (...)`:
da igual si el plan contrató la feature o no. **9 getters** usaban ese
default (dashboard, historial de ventas, historial de gastos,
proveedores, pedidos a proveedores, departamentos, lotes, monitor,
ventas al mayor), así que el gate por plan era decorativo.

Se justificó con "las claves no existen en `planes.features`". Cuando
existan, el default tiene que ser `false`. **Regla:** `defaultVisible`
solo para features sin clave posible; una feature con clave en la BD
siempre gatea.

### 7.5.3 La caché vieja gana para siempre

```dart
Future<List<PlanEntity>> obtenerPlanes() async {
  final locales = await obtenerPlanesLocal();
  if (locales.isEmpty) return descargarPlanesDesdeSupabase();
  descargarPlanesDesdeSupabase(); // fire-and-forget
  return locales;                  // ← el dato fresco nunca se relee
}
```

Supabase tenía **12** features en `true` y Dart veía **3**. El refresh
en background actualizaba Isar, pero `planesProvider` ya había resuelto
y `planPorIdProvider` daba esa lista por buena toda la sesión.

**Regla:** un fire-and-forget que actualiza caché tiene que re-disparar el
provider, o el consumidor se queda con el valor viejo hasta el próximo
arranque. Alternativa: delegar en la descarga y que ella caiga a caché
en el `catch` (4 filas: una ida al servidor no cambia el arranque).

### 7.5.4 La rama que no logueaba es la que fallaba

Los tres bugs anteriores eran invisibles porque `featureFlagsProvider`
tenía una rama sin `debugPrint`:

```dart
final planActivo = cachePlanActivo ?? false;   // null && null = false, mudo
```

El log `🔎 [featureFlags] DENEGADO · …` destapó los tres de una. **Si
un gate decide si el usuario ve el producto, la rama que lo denies
tiene que decir por qué.**

## 7.6 — CI/CD y build de Android release

- **Los builds de release y patch se hacen EXCLUSIVAMENTE vía GitHub
  Actions**, en `.github/workflows/shorebird.yml` con runner
  `ubuntu-latest`. Se disparan a mano desde la pestaña **Actions** de
  GitHub, nunca desde la CLI.
- **Nunca buildear release localmente en Windows.** Gradle 8.14 falla en
  Windows con `Could not move temporary workspace`
  (gradle/gradle#27844). Flutter 3.47 exige Gradle >= 8.14 y el fix está
  en 9.1.0, que rompe AGP 8.11.1 y los plugins con KGP. El runner de
  Linux evade el bug por completo.
- **Secretos requeridos** (Settings > Secrets and variables > Actions):
  `SHOREBIRD_TOKEN`, `ENV_JSON`, `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`,
  `KEY_ALIAS`, `KEY_PASSWORD`.
- **El workflow valida antes de compilar:** `jq empty` sobre `env.json` y
  el magic number `0xFEEDFEED` del keystore. Un secreto con CRLF o
  truncado falla en 1 segundo en lugar de romper la firma 10 minutos
  después.
- ⚠️ **Esto no sirve para el patch de la app DESKTOP Windows.** Ese va
  por CMake/MSBuild — el bug no le aplica — pero tampoco se genera
  desde Linux. Para eso, runner Windows.
- Para cargar un secret desde un archivo local, el comando depende de la
  shell: en **PowerShell** es `Get-Content -Raw`, en **bash** es `cat`.
  Usar el equivocado falla en silencio y deja el secret vacío.

## 8. Comandos úteis

```bash
# Análisis estático
flutter analyze

# Regenerar código Isar
dart run build_runner build --delete-conflicting-outputs

# Limpiar
flutter clean

# Release Android (Shorebird)
shorebird release android

# Release Windows (Shorebird + Inno)
shorebird release windows
dart run inno_bundle --no-app --release
# Parche OTA
shorebird patch android --release-version=X.Y.Z+B
```

### ⚠️ Shorebird en Windows — la ExecutionPolicy rompe todo

`shorebird.bat` no quotea args (`%1..%9`) y destruye
`--dart-define-from-file`. Encima, la ExecutionPolicy bloquea invocar
`shorebird.ps1` directo: el comando **falla en silencio** (exit 0, output
vacío) y parece que no pasó nada. La única forma que funciona:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File `
  "$env:USERPROFILE\.shorebird\bin\shorebird.ps1" patch android `
  --flavor client --target lib/main_client.dart `
  --dart-define-from-file=env.json --allow-asset-diffs
```

`--allow-asset-diffs` **siempre**: el tree-shaking de íconos produce un
`MaterialIcons-Regular.otf` distinto en cada build y Shorebird lo reporta
como asset diff. Sin la flag se cuelga pidiendo confirmación por stdin y
aborta con *"Input was required … non-interactive context"*.

### ⚠️ Un patch NO cambia recursos Android

Un patch empaqueta **código Dart + assets**. `android:label`, los íconos de
`mipmap-*` y `colors.xml` quedan congelados en el APK base. Cambiar el ícono
del launcher o el nombre visible de la app **exige `shorebird release`**.

Los patches además son **por release**: uno publicado sobre `894041` no se
aplica a un release posterior. Para pasar a un release nuevo hay que
instalar el APK encima, y volver a correr `get-apks` (devuelve el APK del
release pedido, no el "latest").

```powershell
# APK de un release concreto (trae el motor con OTA, pero firmado en DEBUG)
shorebird releases get-apks --flavor client `
  --release-version 1.1.1+7 --out build\apks
```

⚠️ **`get-apks` firma con la llave de debug** (`CN=Android Debug`). Ese APK
no se puede instalar encima de la app real y cualquiera podría reemplazarlo.
Para distribuirlo hay que re-firmarlo con `boostikeystore.jks`:

```powershell
zipalign -f -p 4 build\apks\universal.apk build\apks\aligned.apk
apksigner sign --ks android\boostikeystore.jks --ks-key-alias boostiapp `
  --out build\apks\boosti-ota.apk build\apks\aligned.apk
apksigner verify --print-certs build\apks\boosti-ota.apk
# La huella tiene que ser 8a189763... (la misma del AAB)
```

⚠️ **`flutter build apk` NO sirve para distribuir con OTA.** Usa el motor
estándar de Flutter (`libflutter.so` de 11,20 MB, sin updater), así que
nunca recibe parches. El de Shorebird mide 13,37 MB y sí lo trae. La forma
de comprobarlo:

```powershell
# Tiene que decir True
Select-String -Path libflutter.so -Pattern 'shorebird' -SimpleMatch -Quiet
```

El paso "Obtener APK instalable con OTA" del workflow ya hace todo esto.

## 9. Errores comunes y cómo evitarlos

| Error | Causa | Solución |
|-------|-------|----------|
| `referenced_before_declaration` | Uso antes de declarar | Mover declaración arriba |
| `undefined_getter` en Isar | Falta `part` o schema no registrado | Verificar `part` + `Isar.open` |
| `Edit` falla con oldString | Whitespace invisible | Leer archivo y reportar |
| `SyncService` en bucle | Anti-eco mal puesto | Verificar `_escribiendoX` |
| `Realtime` no dispara | Tabla no suscrita | Añadir `_suscribirATabla` |
| RLS bloquea 42501 | Sin JWT o policy mal | Verificar `current_tenant_id()` |
| `asset not found` al buildear | Se borró un archivo declarado en `pubspec.yaml: assets:` | Sacar la línea del `pubspec` **o** restaurar el archivo |
| `inno_bundle` falla sin error claro | `installer_icon` apunta a un `.ico` inexistente | Regenerar con `tools\gen_ico.ps1` |
| El ícono no cambia en el launcher | En Android 8+ se usa `app_icon_foreground`, no `app_icon.png` | Regenerar con `tools\gen_launcher_foreground.ps1` |
| Ícono cortado en el launcher | El foreground excede la zona segura (61% del lienzo) | `tools\gen_launcher_foreground.ps1` lo escala al 62% |
| `RangeError` al pintar iniciales | `''.split(regex)` devuelve `['']`, no `[]`; el `isEmpty` nunca se cumple | Validar `trimmed.isEmpty` **antes** del split |
| `shorebird` no hace nada, exit 0 | ExecutionPolicy bloquea `shorebird.ps1` | `powershell.exe -NoProfile -ExecutionPolicy Bypass -File shorebird.ps1` |
| Patch aborta pidiendo input | Tree-shaking de íconos siempre marca asset diff | Agregar `--allow-asset-diffs` |

## 10. Git y versionado

- **Nunca** subas `env.json`, `.env`, `sentry.properties`, o
  `key.properties`.
- Los `.g.dart` **sí** se suban (son necesarios para compilar).
- Bump de versión en `pubspec.yaml` **antes** de cada release.
- Un commit por feature/refactor. Mensajes en español.
- **El nombre de la app NO es el `name:` del `pubspec`.** Ese es el paquete
  Dart (`app_boosti_v2`); cambiarlo rompe todos los imports. El nombre
  visible vive en `android:label`, `inno_bundle.name` y los textos Dart.
- Si se cambia el ícono, regenerar **los tres** artefactos:
  `flutter_launcher_icons` (los `mipmap-*`), `tools\gen_launcher_foreground.ps1`
  y `tools\gen_ico.ps1`.

### 10.1 Prohibido exponer datos sensibles en git

- 🚫 **Ningún secreto va al código fuente ni a un `.md`.** Ni URL de conexión, ni
  clave de API, ni token, ni PAT, ni password, ni DSN. **Tampoco a un archivo que
  esté en `.gitignore`**: eso evita que se suba, pero no que termine en un backup,
  en un `.bak`, o en la pantalla de otra persona.
- ✅ Todo valor sensible vive en `env.json` y se inyecta con
  `--dart-define-from-file=env.json` hacia `String.fromEnvironment`.
- ⚠️ **No hay cargador runtime.** `env.json` se compila dentro del binario: si se
  compila sin el flag, todas las variables quedan vacías y la app arranca
  degradada en silencio.
- 🔍 **Antes de cada commit**, revisar `git diff --cached` en busca de strings que
  parezcan credenciales. Si aparece una: **parar y reportar**, no commitear.
  - Filtrar **solo líneas agregadas** (`git diff --cached -U0` y quedarse con las que
    arrancan en `+`). Un escaneo ingenuo marca la línea que se está *eliminando* y da
    un falso positivo cada vez que se saca un secreto del código, que es justo cuando
    más hace falta confirmar que se fue.
- El escaneo propio tiene que ir **más allá** de lo que detecte la herramienta:
  GitHub push protection solo marca PATs, no cadenas de conexión con password.

## Regla — Verificación de usos antes de afirmar "nadie lo usa"

Un grep que devuelve 0 resultados **no** prueba que algo esté muerto. Puede
ser que se esté buscando el nombre equivocado, que se busque solo como
lectura y no como escritura, o que el uso esté detrás de una capa que no
se miró.

Antes de concluir que un campo, método o widget no se usa:

1. **Grep por el nombre EXACTO del campo.** Buscar una sola variante que
   suene parecida da 0 falsos positivos y destruye la conclusión.
   *Caso real (2026-10-10):* se buscó `avatarUrl` cuando el campo se llamaba
   `fotoUrl`. Se reportó la feature de fotos de empleados como muerta
   mientras estaba viva en 3 pantallas (`empleado_card`,
   `employees_detail_screen`, `empleado_form_dialog`) y sincronizándose
   (`sync_service.dart:534`, `:980`, `:1141`). Un grep de alcance lo
   detectó **antes de aplicar el cambio**.
2. **Grep por la entidad contenedora** (`UsuarioEntity`) y leer qué campos
   extrae su `fromSupabase` / `toSupabaseJson`. Los nombres reales están
   ahí, no en los que uno adivina.
3. **Grep por sinónimos del feature** (avatar, foto, photo, img, pic,
   imagen) antes de concluir nada.
4. **Grep por el sitio de ESCRITURA** además del de lectura:
   `.storage.from(`, `.upload(`, `.insert(`, `.upsert(`, `= campo`.
   Un feature puede no tener lectores y sí estar escribiendo datos.
5. **Contar los call sites, no los matches.** Un método con 2 referencias
   puede ser 1 definición + 0 callers (código muerto) o 2 callers. Un grep
   que reporta "2 hits" no distingue los casos.
6. **Si la conclusión implica borrar o congelar algo, releer los hits uno
   por uno antes de tocar.** El costo de un grep mal orientado es
   minúsimo; el de romper una feature en 3 pantallas es un incidente.

## Regla — Verificación de usos (versión reforzada)

Un grep con 0 resultados **no prueba** que algo no exista ni que no se use.
Es una señal de que el patrón estaba mal, no una confirmación.

### Antes de concluir que algo "no existe" o "no se usa"

1. **Grep con el nombre EXACTO.** No variantes que suenen igual.
   *Ejemplo real:* el campo es `fotoUrl`, no `avatarUrl`.

2. **Grep del SÍMBOLO, no de la línea.** Las llamadas se parten:

   ```dart
   Supabase.instance.client.storage
       .from('marcas')      // el .from esta en OTRA linea
   ```

   Un grep de `storage.from('...')` sobre lineas individuales devuelve 0 y
   uno concluye "no hay storage". Hay que **`\s*` entre tokens**, o leer
   el archivo crudo y buscar con regex multilinea.

3. **Cuando dos greps dan 0 en la misma area, hay un tercer grep que no
   se hizo.** Parar y cambiar de estrategia: buscar el paquete que lo usa
   (`image_picker`, `storage`), o el elemento contenedor.

4. **Si 0 resultados, probar antes de concluir:**
   - El nombre sin prefijo (`url` en vez de `imageUrl`).
   - Solo el sufijo (`Url`, `Path`).
   - La entidad contenedora, y que campos extrae su `fromSupabase` o
     `toSupabaseJson`.
   - El **sitio de escritura**, no solo el de lectura. El bug suele
     estar donde se sube algo, no donde se lee.

5. **Contar call sites, no matches.** "2 hits" puede ser 1 definicion + 0
   callers, o 2 callers. No es distinguible.

6. **Si la conclusion implica borrar, congelar o migrar, releer los hits
   uno por uno antes de tocar.**

### Errores reales que motivaron esta regla

| Fecha | Patron buscado | Realidad | Costo |
|---|---|---|---|
| 2026-10-10 | `avatarUrl` | el campo es `fotoUrl`; feature viva en 3 pantallas + sync | Casi se congela una feature que funcionaba |
| 2026-10-10 | `storage.from(...)` por linea | la llamada esta partida en 2 lineas; faltaba el bucket `marcas` | El bug de la URL firmada paso un turno entero sin detectarse |

## Regla — `supabase migration repair` NO ejecuta SQL

`supabase migration repair --status applied <version>` **solo** actualiza
`supabase_migrations.schema_migrations`. **No corre el SQL del archivo.**

### Orden correcto

1. Correr el SQL: SQL Editor de Supabase, o `supabase db push` si la
   migración es nueva en el archivo.
2. **Verificar que el objeto existe** con una query.
3. Recién ahí `supabase migration repair --status applied <version>`, para
   alinear el tracking.

Invertir el orden deja el historial mintiendo: dice "aplicada" mientras el
objeto no existe. Peor todavía: la migración queda marcada y **nadie la va
a volver a correr** en otro entorno.

### Incidente real (2026-10-10)

Se marcó `20261010000002` (RLS + policy de `movimientos_lotes`) como
aplicada **sin haber corrido el SQL**. El remoto quedó con la tabla sin RLS
y con el sync ya conectado contra ella: `select()` sin filtrar por tenant,
o sea movimientos de todos los tenants en el mismo dispositivo. Se detectó
porque la tabla se había creado a mano y el repair parecía la solución
rápida.

## Regla — Guardar el path de Storage, nunca la signed URL

`createSignedUrl(path, segundos)` devuelve una URL **caducable**. Si esa
URL se guarda en una entity, se persiste en Isar y se sube a Supabase,
el objeto queda huérfano: sigue en el bucket pero la única referencia
guardada está expirada y no hay forma de recuperarlo.

- **Guardar el path** (`marca_123.png`), que es permanente.
- **Firmar en el momento de renderizar**, con cache en memoria y margen
  antes de la expiración.
- `getPublicUrl` sobre un bucket público sí es estable: ahí no hay problema.

## Regla — Buckets de Storage necesitan 4 policies

Crear el bucket en el dashboard NO alcanza. Sin policies en
`storage.objects`, el upload falla silenciosamente (RLS por defecto
deniega).

El path tiene que empezar con el tenant_id:
  bucket/{tenant_id}/archivo.png

Policies mínimas: SELECT, INSERT, UPDATE, DELETE, con check
`(storage.foldername(name))[1] = current_tenant_id()::text`.

Verificar: `SELECT policyname FROM pg_policies WHERE
schemaname = 'storage' AND tablename = 'objects';` — tienen que
aparecer 4 por bucket.

⚠️ `PaperSize.mm80` de `esc_pos_utils_lts` son **558 dots** de ancho
(`PaperSize.width`), no 576. Los logos se redimensionan a 512 px, que
deja ~23 dots de margen por lado.

## Regla — Simetría de campos en el sync

Cada campo nuevo en una entidad sincronizada tiene que estar en **3 sitios**:

1. **Push** — el `toSupabaseJson()` de la entity, o el JSON inline de subida.
2. **Pull** — el `fromSupabase()`, o el read inline de bajada.
3. **El merge/comparador** — si el pull solo escribe cuando detecta diferencia,
   o si preserva el valor local con `?? local.campo`.

Faltar en el punto 3 es el peor caso: la nube tiene el dato, el local no lo
ve, y **no hay error** porque el sync "funciona". Solo ignora el campo.

### Verificación

```powershell
grep -n "<nombreCampo>\|<nombre_columna>" lib/features/pos/presentation/services/sync_service.dart
```

Contá los hits y comprobá que están los 3 sitios. En `locales` son 4, porque
el pull tiene **dos ramas** (merge y create) y ambas necesitan el campo:

| # | Sitio | Línea (locales) |
|---|---|---|
| 1 | Push: `'logo_path': local.logoPath` | `sync_service.dart:3006` |
| 2 | Pull: `final logoPathNube = data['logo_path']` | `sync_service.dart:3095` |
| 3 | Rama merge: `..logoPath = logoPathNube ?? local.logoPath` | `sync_service.dart:3111` |
| 4 | Rama create: `..logoPath = logoPathNube` | `sync_service.dart:3145` |

⚠️ El `?? local.campo` no es decorativo: preserva el valor local cuando la
nube manda `null`. Sin él, un logo subido en un dispositivo se borra en el
siguiente sync si el otro dispositivo todavía no lo tiene.

## 11. Contacto

Yan Camacaro — camacaroyan@gmail.com — JAHTLABS

---

## 13. Actualizaciones desde 2026-09-30

> Este delta documenta los cambios arquitectónicos posteriores a la
> generación inicial del inventario. Para regenerar el inventario
> completo, correr el script correspondiente.

### 13.1. Nuevas entidades Isar

#### `plan_entity.dart`
- **Tipos**: `PlanEntity`
- **Campos**: planId, nombre, descripcion, precioMensual, precioAnual,
  modosHabilitados (`List<String>`), featuresJson, orden, updatedAt
- **Helpers**: `featuresMap`, `tieneFeature(String)`, `fromSupabase()`
- **Caché local** de la tabla `planes` de Supabase.

#### `suscripcion_entity.dart`
- **Tipos**: `SuscripcionEntity`
- **Campos**: tenantId, planId, estado, trialHasta, periodoInicio,
  periodoFin, addonsActivosJson, verificadoEn, updatedAt
- **Helpers**: `activa` (getter bool), `addonsMap`, `fromSupabase()`
- **Caché local** de la tabla `suscripciones` de Supabase.

#### `venta_anulada_entity.dart`
- **Tipos**: `VentaAnuladaEntity`
- **Campos**: ventaIdOriginal, tenantId, motivo, usuarioId, usuarioNombre,
  usuarioRol, fechaAnulacion, montoOriginal, sincronizado,
  fechaSincronizacion
- **Propósito**: registrar anulaciones de ventas sin tocar la venta original.

#### `gasto_anulado_entity.dart`
- **Tipos**: `GastoAnuladoEntity`
- **Campos**: gastoIdOriginal, tenantId, motivo, usuarioId, usuarioNombre,
  fechaAnulacion, montoOriginal, sincronizado, fechaSincronizacion
- **Propósito**: registrar anulaciones de gastos.

#### Cambios en `local_entity.dart`
- **Nuevos campos**: `businessMode` (String, default 'mercado'),
  `modoConfiguradoEn` (DateTime?), `planIdCache`, `planVerificadoEn`.

### 13.2. Nuevos providers

- **`business_mode_provider.dart`**: `BusinessModeNotifier`, enum
  `BusinessMode`, clase `FeatureFlags`, `businessModeProvider`,
  `featureFlagsProvider`.
- **`suscripcion_provider.dart`**: `SuscripcionesRepository`,
  `planesProvider`, `planPorIdProvider`, `suscripcionProvider`,
  `suscripcionRefreshProvider`.

### 13.3. Nuevos servicios

- **`venta_anulacion_service.dart`**: `VentaAnulacionService`,
  `ventaAnulacionServiceProvider`. Orquesta anulación + contra-movimientos
  de stock.

### 13.4. Nuevas pantallas

- **`seleccionar_modo_negocio_screen.dart`**: onboarding de modo de negocio.
- **`configuracion_modo_negocio_screen.dart`**: cambio de modo desde Settings.

### 13.5. Nuevos widgets

- **`widgets/business_mode/modo_negocio_card.dart`**: card reutilizable
  del modo de negocio, usado en onboarding + settings.

### 13.6. Cambios en `SyncService`

- **Nuevo flag anti-eco**: `_escribiendoLocales`.
- **Nuevo callback**: `onLocalCambiado`.
- **Nueva suscripción Realtime**: tabla `locales`.
- **Nuevo handler**: `_onLocalesCambiaronDesdeNube`.
- **Sync de `business_mode`**: se sube y se lee desde Supabase.
- **Helper**: `_parseBusinessMode(dynamic)`.

### 13.7. Cambios en `sync_provider.dart`

- `onDataChanged` se mantiene igual.
- Nuevo `onLocalCambiado` que recarga `businessModeProvider`.

### 13.8. Cambios en `main_pos_screen.dart`

- `_quickItemsForRole(role, flags)` filtra por modo + plan.
- `_QuickAccessGrid` recibe `FeatureFlags`.

### 13.9. Cambios en `side_panel.dart`

- `_buildButtonList` filtra categorías por `FeatureFlags`.
- Categoría Local solo aparece si `flags.multiLocal`.
- Productos y Pedidos se ocultan en modo servicios.

### 13.10. Cambios en `menu_config.dart`

- `MenuBuilder.puedeVerOpcion(role, id, flags)` combina permisos de rol +
  feature flags.
- `_flagPermite(id, flags)` filtra por plan/modo.

### 13.11. Cambios en `user_settings_screen.dart`

- Nueva sección "Negocio" con card de modo actual.
- Botón "Cambiar modo" (solo admin).
- Diseño mejorado con blobs animados, hover cards, staggered entries.

### 13.12. Base de datos Supabase — nuevas tablas

| Tabla | Propósito |
|-------|-----------|
| `super_admins` | Super admins (dev mode) |
| `tenant_notas` | Notas internas por tenant |
| `pagos_recibidos` | Registro interno de pagos (sin factura) |
| `super_admin_audit_log` | Log de acciones del super admin |

### 13.13. Policies RLS nuevas

- **Super admin**: `super_admin_read_locales`, `super_admin_all_suscripciones`,
  `super_admin_write_planes`, `super_admin_read_log`,
  `super_admin_read_self`, `super_admin_all_pagos`,
  `super_admin_all_notas`.
- **Inmutabilidad**: se dropearon `tenant_isolation` (ALL) en ventas,
  detalle_ventas, movimientos_inventarios, pagos_ventas, gastos y
  audit_log. En su lugar hay pares SELECT + INSERT (gastos también UPDATE).
- **audit_log**: policies explícitas de bloqueo (`audit_no_delete`,
  `audit_no_update` con `qual: false`).

### 13.14. Funciones y helpers SQL

- `is_super_admin()` — valida que el JWT pertenezca a un super admin activo.
- `log_super_admin_action(accion, tenant, payload)` — RPC para loggear.
- Vista `tenant_metadata` — metadata contractual sin datos operativos.
- `modos_disponibles(tenant_id)` — devuelve array de modos habilitados.

### 13.15. Reglas de inmutabilidad — resumen

| Entidad | SELECT | INSERT | UPDATE | DELETE |
|---------|:------:|:------:|:------:|:------:|
| ventas | ✅ | ✅ | ❌ | ❌ |
| detalle_ventas | ✅ | ✅ | ❌ | ❌ |
| movimientos_inventarios | ✅ | ✅ | ❌ | ❌ |
| pagos_ventas | ✅ | ✅ | ❌ | ❌ |
| audit_log | ✅ | ✅ | ❌ | ❌ |
| gastos | ✅ | ✅ | ✅ (24h) | ❌ |

### 13.16. Datos inmutables en Isar

`IsarService` **no expone** métodos `eliminarVenta`, `actualizarVenta`,
`eliminarDetalleVenta`, `eliminarMovimiento`, `eliminarGasto`. Si necesitas
anular, usa los servicios de anulación (`VentaAnulacionService`).

### 13.17. Roadmap de implementación

| Fase | Estado |
|------|--------|
| Fase 1 — Modos de negocio | ✅ Completada |
| Fase 2 — Dev Mode Fase A (auth + tenants) | ⏳ Pendiente |
| Fase 3 — Legal & Onboarding (T&C, Privacy) | ⏳ Pendiente |
| Fase 4 — Dev Mode Fase B (detalle + plan) | ⏳ Pendiente |
| Fase 5 — Landing + Pagos + Soft launch | ⏳ Pendiente |
