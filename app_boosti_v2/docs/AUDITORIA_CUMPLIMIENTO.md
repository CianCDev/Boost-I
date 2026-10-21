# Auditoría de cumplimiento — Boosti POS

**Fecha:** 2026-10-18
**Alcance:** componentes de terceros, tipografías, tratamiento de datos y posture de seguridad
**Producto:** Boosti POS 1.1.1+7
**Titular:** Yan David Camacaro Delgado — JAHTLABS (Jehová Tech Labs)

> ⚠️ **Esto no es asesoría jurídica.** Es una auditoría técnica verificable
> sobre el código y los assets del repositorio. Las obligaciones legales
> (LOPDP, Código de Comercio, normas de la SENIAT) requieren validación
> con un abogado en Venezuela antes de firmar nada.

> **Estado de los T&C (2026-10-20).** Hasta que el abogado revise y confirme
> los textos, lo que se presenta al cliente es un **acuerdo entre las partes**,
> no un contrato validado legalmente. Los siete marcadores `[REVISAR: ...]`
> de `legal_texts.dart` siguen abiertos y se resuelven con el abogado, no en
> el código. La aceptación ya queda registrada (local + Supabase), así que
> cuando llegue la versión definitiva hay evidencia de quién aceptó y cuándo.

---

## 1. Resumen ejecutivo

| Área | Estado | Detalle |
|---|---|---|
| Licencias de dependencias | 🟢 Limpio | 250 paquetes, **0 copyleft** |
| Tipografías en la app | 🟢 Limpio | 0 fuentes embebidas, usa Roboto (Apache 2.0) |
| Licencias de terceros (aviso) | 🟢 **Corregido** | `THIRD_PARTY_NOTICES.txt` no existía |
| Tipografías en material comercial | 🟢 **Corregido** | Los 3 PDF migrados a Roboto (Apache 2.0) |
| Términos y privacidad | 🟢 **Corregido** | Pantalla de aceptación en el alta + textos |
| Datos personales en Sentry | 🟢 **Corregido** | `PiiScrubber` limpia antes de enviar |
| Assets gráficos | 🔴 **Riesgo** | 4 animaciones Lottie sin licencia demostrable |
| Propiedad intelectual | 🔴 **Riesgo** | Marca sin registrar |

**Ninguno de los hallazgos bloquea la venta.** Los dos que quedan abiertos
dependen de dinero o de una decisión, no de código.

---

## 2. Dependencias de software

### 2.1 Resultado

Se analizaron los **250 paquetes** del `pubspec.lock` leyendo el archivo
`LICENSE` real de cada uno en el pub-cache local. No se confió en lo que
declara el pubspec de cada paquete.

| Licencia | Paquetes | Uso comercial |
|---|---:|---|
| BSD 2-Clause | 158 | Sí, sin condiciones |
| MIT | 65 | Sí, con aviso de copyright |
| Apache 2.0 | 17 | Sí, con aviso de copyright y de patente |
| MPL 2.0 | 4 | Solo si se modifica el archivo |
| SDK Flutter / path local | 6 | Ver 2.3 |

**Copyleft GPL / AGPL: 0 paquetes.** Ninguna dependencia obliga a publicar
el código fuente del producto. El código comercial se puede mantener cerrado.

### 2.2 Los 4 paquetes MPL-2.0 no aplican

`bluez`, `dbus`, `gtk`, `nm` son dependencias transitivas del **escritorio
Linux**. No se compilan dentro del APK de Android ni del `.exe` de Windows.
La cláusula copyleft de MPL opera a nivel de archivo modificado y no alcanza
al binario publicado.

**Aun así:** si someday se compila para Linux, hay que revisar. No antes.

### 2.3 Dependencias que merecen atención

| Paquete | Licencia | Nota |
|---|---|---|
| `isar_flutter_libs` | Apache 2.0 | Es un **path local** (`plugins/`), no de pub.dev. Hay que documentar por qué existe el fork y qué se modificó frente al Isar oficial. |
| `shorebird_code_push` | MIT | El cliente es MIT, pero Shorebird **no tiene self-hosting** (§5.2). |
| `sentry_flutter` | MIT | El SDK es MIT; el **servidor** Sentry usa Functional Source License. Ver §5.1. |
| `esc_pos_utils_lts` | BSD-2 | Depende de `PaperSize.mm80 = 558 dots`, no 576. Documentado ya en `AGENTS.md`. |

### 2.4 Origen de los paquetes

Las 250 dependencias vienen de `pub.dev`. **Ninguna** desde una URL de git
ni de un repositorio externo. No hay superficie de suministro ajena al
registro público.

---

## 3. Tipografías

### 3.1 En la aplicación — limpio

```
Barrido de .ttf / .otf / .woff / .woff2 en app_boosti_v2/
  → 0 resultados
```

La app **no embebe ninguna fuente**. Flutter usa Roboto (Apache 2.0),
incluida por el SDK. No hay riesgo.

### 3.2 En el material comercial — requiere atención

Los tres PDF entregados (`Boosti_POS_Resumen_Comercial.pdf`,
`PROPUESTA_COMERCIAL_Boosti_POS.pdf`, `BOOSTI_POS_Manual_de_usuarios.pdf`)
llevan **Segoe UI embebida** como subconjunto:

```
AAAAA+SegoeUI        (regular)
AAAAA+SegoeUI-Bold
AAAAA+SegoeUI-Semibold
AAAAA+SegoeUI-Italic
```

**Qué dice Microsoft** ([Font Redistribution FAQ](https://learn.microsoft.com/en-us/typography/fonts/font-faq)):

> *"In general, there are no special restrictions around the distribution of
> documents that contain embedded Windows' fonts."*

Es decir: **distribuir esos PDF comercialmente es legítimo**, siempre que
la aplicación que los genera respete el *embedding* de OpenType — que Chrome
headless hace (subconjunto con flags correctos).

**El problema es otro:** *"Some font foundries may give away 'free' versions
of fonts with limited licenses and make their money selling extended rights."*
Microsoft hace exactamente eso. Se está construyendo una posición comercial
—vender propuestas a terceros— sobre una fuente que hay que pagar para
embeber fuera de sus productos.

### 3.3 ✅ Migrado a una fuente libre (2026-10-18)

Los tres PDF comerciales se regeneraron con **Roboto, Apache License 2.0**,
copiada del propio SDK de Flutter (`bin/cache/artifacts/material_fonts`).

Verificado con PyMuPDF sobre el PDF generado:

```
Boosti_POS_Resumen_Comercial.pdf    7 pag   Roboto-Regular, Roboto-Bold
PROPUESTA_COMERCIAL_Boosti_POS.pdf  6 pag   Roboto-Regular, Roboto-Bold
BOOSTI_POS_Manual_Roboto.pdf       46 pag   Roboto-Regular, Roboto-Bold, Roboto-Italic
```

Cero Segoe UI. Cero dependencia de Microsoft.

**Detalle de implementación:** `@import url(...)` con rutas `file://` no lo
carga Chrome headless — cae al fallback del stack y el PDF sale con Arial.
La fuente tiene que ir embebida como `data:` URI dentro del `@font-face`.
Los tres generadores quedaron así (`_boosti/embeber_fuentes.py`).

**Un peso faltaba:** el manual usa `font-weight:800` en varios titulos.
Sin una declaración para 800, el navegador no lo encuentra en Roboto y cae
a la siguiente del stack. Se agrego Roboto Black declarado a 800.

---

## 4. Assets gráficos

### 4.1 🔴 Las 4 animaciones Lottie no tienen licencia demostrable

```
assets/animations/Clock Alarm Animation.json   7 KB
assets/animations/clock.json                   7 KB
assets/animations/error.json                    5 KB
assets/animations/succes.json                   4 KB
```

Las cuatro **carecen del bloque `meta`**, que es donde Lottie guarda autor
y licencia. Y el nombre `Clock Alarm Animation.json` es el nombre por
defecto que asigna LottieFiles al descargar: indica que se bajaron de ahí y
se renombraron, **perdiendo la metadata en el camino**.

**Por qué importa.** LottieFiles tiene tres regímenes:

| Régimen | Condición |
|---|---|
| Lottie Simple License | Gratis, **exige atribución visible** |
| Attribution-free | Gratis, sin atribución, **restringido**: no se puede usar en productos que se vendan como plantilla ni en servicios |
| Licencia de pago | Sin condiciones |

Sin el bloque `meta` no hay forma de demostrar cuál de los tres contrató.
En un producto que se vende, **la ausencia de prueba equivale a no tener
licencia**.

**Uso en el código:**
- `product_form_dialog.dart:912` → `assets/animations/success.json` ⚠️ el archivo
  se llama `succes.json`. Hay un mismatch de nombre que hoy resuelve el
  fallback.
- `product_form_dialog.dart:972` → `error.json`
- `turno_closing_dialog.dart:38` → `Clock Alarm Animation.json`

### 4.2 Acción recomendada

Tres opciones, de menor a mayor esfuerzo:

1. **Reemplazar por animación propia** (3 archivos, 15 s cada una).
   Elimina el problema y además evitan el desajuste del `.otf` en patches.
2. **Re-descargar desde LottieFiles** eligiendo explícitamente *free for
   commercial use* y **conservar el bloque `meta`**. Añadir un
   `assets/animations/CREDITS.md` con autor y URL.
3. **Dejar como está** y aceptar el riesgo. No recomendado: son 4 archivos
   de 5 KB.

### 4.3 Logo e iconos — propiedad propia

`logo.svg`, `logo.png`, `logoboosti300px.*`, `assets/icon/*` son diseño
propio de JAHTLABS. Sin conflicto de terceros. Ver §6 sobre el registro.

---

## 5. Tratamiento de datos y terceros

### 5.1 Sentry — telemetría de errores

**Configuración actual** (`lib/core/bootstrap.dart:98-139`):

| Aspecto | Estado |
|---|---|
| DSN | ✅ Desde `env.json`, nunca en el repo |
| Capturas de pantalla | ✅ `attachScreenshot: false` |
| Errores de red | ✅ Filtrados por tipo y por mensaje |
| **Datos personales del mensaje** | ✅ **`PiiScrubber` (2026-10-18)** |

### ✅ El scrub de PII (2026-10-18)

`lib/core/security/pii_scrubber.dart`, conectado en `beforeSend`.

**Qué limpia:** RIF y cédula con prefijo, teléfono venezolano, correo,
JWT, credencial de Supabase (`sb_publishable_`/`sb_secret_`), clave anónima
antigua, IP, cadenas de 7+ dígitos y claves de diccionario que huelan a
credencial (`password`, `token`, `secret`, `apikey`, `dsn`, `cookie`…).

**Qué limpia por diseño NO:**

- **UUID de tenant.** Es aleatorio, no identifica a nadie, y sin él ningún
  bug de aislamiento entre locales sería diagnosticable.
- Los mensajes en español sin datos.

**Dos bugs que los tests destaparon** (y que habrían ido a producción):

1. `String.replaceAll` de Dart **no expande `$1`**. El patrón de JSON con
   clave sensible salía literal como `{$1[REDACTADO]$2, "user": "juan"}`.
   Solución: `replaceAllMapped`.
2. `\b\d{7,}\b` **se comía el final de los UUID**: el guion no es carácter
   de palabra, así que el `\b` derecho cae entre el guion y el dígito.
   `9c7380a4-1111-2222-3333-444455556666` quedaba en `...-[NUMERO]`.
   Solución: `(?<![\w-])\d{7,}(?![\w-])`.

Un tercero lo+Fallearon+ por unlucky: el prefijo telefónico estaba escrito
`\+?58?\s?`, donde el `5` es **literal**, no opcional. El grupo entero
fallaba en cuanto el número no empezaba por `+58`: `0412-1234567` se
escapaba sin limpiar. El test pasaba por el patrón genérico de dígitos, no
por el de teléfono. Solución: `(?:\+?58[\s.-]?)?`.

**Riesgo residual:** un dato libre en prosa ("el cliente Juan Pérez pidió
…") no se detecta. Los patrones cubren formatos estructurados. Para eso
está el control de acceso al proyecto de Sentry, que debe ser de JAHTLABS.

### 5.2 Shorebird

| Dato | Estado |
|---|---|
| PII enviada | **Ninguna.** Solo `app_id`, `release_version`, `patch_number`, `arch`, `platform` y un UUID anónimo por instalación |
| Correlación con usuarios | **Ninguna.** Shorebird declara explícitamente que no puede |
| Self-hosting | ❌ **No existe.** Says "no current plans" |
| DPA firmado | ✅ Disponible para clientes corporativos |
| Play Store / App Store | ✅ Compliant documentado |

**El identificador anónimo** es un UUID v4 que Shorebird genera, guarda en
el almacenamiento de la app y usa solo para contar instalaciones activas.
No se deriva del dispositivo, no lee el advertising ID, no se correlaciona.
**No es dato personal bajo la LOPDP** — pero conviene documentarlo en la
política de privacidad para que el cliente pueda responder si le preguntan.

**Riesgo real:** si Shorebird sube de precio, cambia términos o desaparece,
los clientes no reciben patches. La app sigue funcionando (Shorebird lo
garantiza), pero las correcciones de seguridad se detienen.

### 5.3 Supabase

Es el backend. RLS activo, `service_role` nunca en el cliente, credenciales
por `env.json`. La superficie de datos está en la base y el aislamiento por
tenant ya está auditado (`AGENTS.md` §7.4, §7.4.1).

**Pendiente de esta auditoría:** el **registro ante la autoridad de datos**
de la LOPDP, y la **política de privacidad publicada**.

---

## 6. Propiedad intelectual

### 6.1 🔴 La marca no está registrada

"Boosti" y "Boosti POS" se usan comercialmente desde hace meses sin
registro. En Venezuela el registro se hace ante la **OCI** (Oficina de
Propiedad Intelectual). Mientras no esté registrada:

- Cualquiera puede registrar la marca primero y bloquearte.
- No podés impedir que alguien lance "Boosti POS" en otra plataforma.
- Perdés la protección por **uso** frente a marcas posteriores.

**Costo:** una fracción de un salario mínimo. **Costo de no hacerlo:**
potencialmente la marca entera.

### 6.2 Código fuente

El repo es **privado** en GitHub (confirmado: `origin` es
`CianCDev/Boost-I`). Nadie más lo tiene. Correcto para producto comercial.

**Falta:** registrar las fechas de autoría del código si más adelante
alguien plantea Timeline, porque los `LICENSE` de terceros **no te dan
derechos sobre tu propio código** — solo te dan permiso para usarlo.

---

## 7. Lo que falta para estar limpio

### 7.0 ✅ Hecho el 2026-10-18

| # | Qué | Dónde |
|---|---|---|
| 1 | `THIRD_PARTY_NOTICES.txt` generado desde el LICENSE real de los 250 paquetes | raíz del repo |
| 2 | Los 3 PDF migrados a Roboto (Apache 2.0) | `_boosti/` |
| 3 | `PiiScrubber` conectado en `beforeSend` de Sentry | `lib/core/security/pii_scrubber.dart` |
| 4 | Textos de T&C y privacidad, versionados | `lib/features/legal/data/legal_texts.dart` |
| 5 | Pantalla de aceptación **antes** del PIN, bloqueante | `lib/features/legal/presentation/terminos_aceptacion_screen.dart` |
| 6 | Registro de aceptación con versión y fecha | `lib/features/legal/data/legal_acceptance_store.dart` |
| 7 | Tabla de evidencia en servidor, con RPC | `supabase/migrations/20261018000001_legal_acceptance.sql` |

**El flujo quedó así:**

```
Registro ──► Terminos y Privacidad ──► PIN ──► POS
                   │
                   └── no acepta ──► vuelve al Registro
```

El gesto de atrás de Android está interceptado con `PopScope`: no hay
salida de la pantalla de aceptación sin volver al registro.

**Dos decisiones de diseño que conviene conocer:**

- El registro se guarda en `SharedPreferences` porque el alta puede ocurrir
  **sin conexión**, y el flujo no puede depender de la nube para avanzar.
- Eso **no prueba** que el texto mostrado sea el publicado ese día: la marca
  de tiempo la controla el cliente. La tabla de Supabase con RPC
  `SECURITY DEFINER` es la que sí tiene valor probatorio, porque pone
  `usuario_id` desde el JWT y `aceptado_en` con `now()` del servidor. Un
  usuario no puede firmar la aceptación de otro.

### 7.1 Lo que falta

| # | Qué | Por qué |
|---|---|---|
| 1 | **Licencias de las 4 animaciones** | §4.1. Bloqueante para cliente corporativo |
| 2 | **Registro de la marca** ante la OCI | §6.1. Costo diferido por decisión del dueño |
| 3 | **Validación jurídica de los textos** | Los marcadores `[REVISAR: ...]` son puntos abiertos |
| 4 | **Aplicar la migración** `20261018000001` | Es del owner (§4.5: RLS es manual) |
| 5 | **Publicar los documentos** en la web de JAHTLABS | Hoy solo viven dentro de la app |
| 6 | **Un resto de `Arial-Bold`** en el manual | Un peso sin declaración exacta cae al fallback del stack |

### 7.2 Importante

| # | Qué |
|---|---|
| 7 | SBOM automático en CI (`cyclonedx`) |
| 8 | Registro de propiedad intelectual del código (fecha de autoría) |
| 9 | Política de retención y borrado de datos del cliente |
| 10 | Shorebird: pedir el DPA firmado cuando se pueda pagar el plan de equipo |

### 7.3 Marcadores `[REVISAR]` dentro de los textos legales

Estos los tiene que resolver el abogado, **no** el código:

| Sección | Qué hay que definir |
|---|---|
| T&C 4 | Precio de cada plan indexado + política de ajustes con aviso previo |
| T&C 7 | Validación del límite de responsabilidad contra normativa y práctica del sector |
| T&C 8 | Nivel de servicio concreto: horas de respuesta, horario, días hábiles |
| T&C 12 | Jurisdicción confirmada y si se prefiere arbitraje |
| Privacidad 5 | Nombre y ubicación del proveedor de nube |
| Privacidad 7 | Plazo de conservación en años + procedimiento de eliminación o anonimización |

---

## 8. Lo que ya está bien

Conviene dejarlo escrito, porque en una auditoría futura es la mitad del
trabajo:

- **0 licencias copyleft.** Se puede vender sin abrir el código.
- **0 fuentes embebidas** en la app.
- **Todas las dependencias de pub.dev.** Sin git externo.
- **RLS activo y auditado.** El incidente cross-tenant de octubre 2026 se
  detectó y cerró con prueba reproducible.
- **Entidades de venta inmutables** con contra-registro de anulación.
- **Credenciales fuera del repo** desde `env.json`.
- **Secretos en GitHub Secrets**, nunca en el código.
- **Auditoría interna** de toda acción sensible con usuario y hora.

---

## 9. Cómo se verificó

Todo lo de este documento es reproducible:

```bash
# 1. Licencias reales de las 250 dependencias
python tools/gen_third_party_notices.py      # → THIRD_PARTY_NOTICES.txt

# 2. Tipografías en el repo
find app_boosti_v2 -iname '*.ttf' -o -iname '*.otf' -o -iname '*.woff*'
#  → 0 resultados

# 3. Fuentes embebidas en un PDF
python -c "import pymupdf,sys; d=pymupdf.open(sys.argv[1]); \
print({f[3] for p in range(d.page_count) for f in d.get_page_fonts(p,full=True)})" ARCHIVO.pdf

# 4. Licencia de las animaciones Lottie
python -c "import json;d=json.load(open('assets/animations/succes.json'));print(d.get('meta'))"
#  → None

# 5. Credenciales en el árbol de staged
git diff --cached -U0 | grep '^+' | grep -Ei 'password|secret|token|dsn'
```