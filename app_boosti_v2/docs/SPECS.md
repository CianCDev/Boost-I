# Specs — Deuda técnica y trabajo pendiente

> Documento de traspaso. Creado 2026-10-18 al cerrar la entrega del
> Patch #4. Cada spec tiene criterios de aceptacion verificables, no
> recomendaciones.
>
> Orden sugerido: D-1 y D-2 antes que el modo servicios (S-1), porque
> S-1 los toca y es más barato hacerlo con el CI ya confiable.

---

## D-0 · Estado al cierre del 2026-10-18

**Publicado:** Patch #4 (Patch 1 sobre el release `1.1.1+7`).
**Tag:** `v1.1.3` → commit `170ab20`.
**CI:** `.github/workflows/shorebird.yml`, runner `ubuntu-latest`, 12 steps.

Lo que entró en el patch, y lo que todavía **no** se verificó en un
dispositivo real: hace falta abrir la app con `1.1.1+7` + internet y
confirmar en el log `📦 Downloading patch...` y que el menú muestre los
módulos.

---

## D-1 · Gradle en Windows está bloqueado para builds de release

**Estado:** abierto, con workaround (CI en Linux).
**Bloquea:** cualquier release o patch generado desde esta máquina.

### Contexto

Gradle falla en Windows con:

```
Could not move temporary workspace
  (...\caches\8.14\transforms\<hash>-<uuid>)
to immutable location
  (...\caches\8.14\transforms\<hash>)
```

Reproducido en **8.13 y 8.14**, con `caches` y `daemon` borrados al
100%, con daemons detenidos, con Avast desactivado.

### Descartado con evidencia

| Hipótesis | Resultado |
|---|---|
| Caché corrupta | `caches` + `daemon` vacíos, falla igual |
| Versión de Gradle | 8.13 lo rechaza Flutter (`min 8.14`); 8.14 falla |
| JDK | `Files.move(ATOMIC_MOVE)` OK en 21.0.2 y en el JBR 21.0.10 de Android Studio |
| Filesystem | `Directory.Move` de .NET OK, incluso dentro de `.gradle\caches` |
| Antivirus | Avast desactivado, sin cambio |
| Daemons / watcher | Detenidos y deshabilitados, sin cambio |

El issue upstream es `gradle/gradle#27844`, sin fix en la línea 8.x.

### Criterio de aceptación

Uno de estos dos:

- [ ] Un build release de Android **desde Windows** termina sin el error.
      Si se resuelve, la spec se cierra y CI puede volver a `windows-latest`.
- [ ] Se acepta formalmente que **todo build de Android sale de CI** y se
      documenta en `AGENTS.MD` §7.6 (ya está escrito, falta decidir si es
      permanente o provisional).

### Riesgo si no se hace nada

Ninguno inmediato: CI funciona. El riesgo es que alguien intente
`shorebird patch` local y pierda una hora de diagnóstico.

---

## D-2 · `buildDir` removido en Gradle 9

**Estado:** abierto, bloqueado por D-1.
**Archivo:** `app_boosti_v2/android/build.gradle:9` y `:12`

```groovy
rootProject.buildDir = '../build'                                          // línea 9
project.buildDir = "${rootProject.buildDir}/${project.name}"              // línea 12
```

Ambas están **removidas** en Gradle 9.x. Subir a 9.x sin migrarlas rompe
el build al evaluar el archivo, antes de compilar una línea.

Migración oficial:

```groovy
rootProject.layout.buildDirectory = file('../build')
layout.buildDirectory = file("${rootProject.layout.buildDirectory.get().asFile}/${project.name}")
```

### Criterio de aceptación

- [ ] Las dos líneas migradas.
- [ ] `flutter build appbundle --release --flavor=client` sigue produciendo
      el mismo artefacto (comparar tamaño y hash de firma).
- [ ] Solo si además se decide subir a Gradle 9.

### Nota

Hoy **no** se puede subir a Gradle 9 de todos modos: AGP 9.1.0 exige
Gradle 9.3.1, AGP 9 + Flutter 3.47.2 está roto en Windows (#192111), y
varios plugins aplican KGP. **Esta spec es deuda preventiva, no urgente.**

---

## D-3 · `evaluationDependsOn` es un anti-patrón

**Estado:** abierto, mismo archivo que D-2.
**Archivo:** `app_boosti_v2/android/build.gradle:16`

```groovy
subprojects {
    project.evaluationDependsOn(':app')
}
```

Fuerza el orden de evaluación de todos los subprojects y rompe con
plugins que aplican configuración de forma perezosa. Gradle 9 no lo
remueve, así que no es urgente.

### Criterio de aceptación

- [ ] El bloque se elimina.
- [ ] `flutter build appbundle` sigue verde.

---

## D-4 · Casing de archivos: el repo tiene 1 caso conocido, y Windows no los ve

**Estado:** el caso conocido está corregido. Falta una guarda automática.

El build de Android en Linux falló porque
`Multi_select_dialog.dart` estaba así en git y el import pedía
`multi_select_dialog.dart`. Windows no distingue mayúsculas, así que
`flutter analyze` local pasaba con 744/744 sin detectar nada.

Corregido en `180722a`. El barrido completo no encontró ningún otro
caso, y tampoco hay `.dart` sin trackear.

### El riesgo residual

Cualquier rename futuro con cambio de casing **vuelve a fallar en CI y no
en local**. El `flutter analyze` del step 6 del workflow lo detecta, pero
solo cuando se llega a CI.

### Criterio de aceptación

- [ ] Un hook de pre-commit o un step de CI que compare el índice de git
      contra los nombres en disco y falle ante cualquier mismatch.

Ya existe el script que lo hace: `Documents\casecheck.ps1`. Falta
integrarlo.

---

## D-5 · La auditoría de plugins que "pasa" puede mentir

**Estado:** abierto.

Durante el diagnóstico del CI se escribieron dos scripts de verificación
que **dieron falsos negativos**:

1. `Select-String` con un regex mal escapado → reportó `aplican KGP: 0`
   para 12 plugins, cuando el chequeo nunca corrió.
2. Comparación de paths sin quitar el prefijo del repo → reportó 498
   archivos Dart como "no trackeados".

Los dos se detectaron porque el número era absurdo. Pero un script de
verificación que falla en silencio es peor que no tenerlo.

### Criterio de aceptación

- [ ] Cada script de verificación del repo tiene un caso de prueba que
      falla si el script deja de mirar lo que dice mirar.
- [ ] Regla en `AGENTS.MD`: un conteo de verificación que da 0 se
      revisa antes de aceptarse como resultado.

---

## S-1 · Modo servicios

**Estado:** pendiente, siguiente en la cola.

No arranca hasta que D-1 y D-2 estén al menos decididos, porque el modo
servicios va a tocar `menu_config.dart`, `business_mode_provider.dart` y
probablemente `side_panel.dart` — los mismos archivos de los gates que
acabamos de arreglar.

### Contexto de lo que ya funciona

`BusinessMode` tiene tres valores: `mercado` (id `retail`), `restaurante`,
`servicios`. El id técnico se renombró a `retail` y la etiqueta de UI
sigue siendo "Mercado".

Los flags de modo ya existen:

```dart
mostrarAgenda        → esServicios
mostrarProfesionales → esServicios
mostrarInventario    → !esServicios
requiereMesa         → esRestaurante
mostrarMesas         → esRestaurante
mostrarComandas      → esRestaurante
mostrarKDS           → esRestaurante
usaCitas             → esServicios
```

O sea: la infraestructura de gate por modo ya está. Lo que falta es el
producto.

### Preguntas a responder antes de arrancar

1. ¿Qué pantallas se entregan en la primera versión? Agenda, profesionales
   y citas, ¿o también el cobro por servicio?
2. ¿Un local puede tener dos modos a la vez, o es uno por local?
   Hoy `LocalEntity.businessMode` es uno solo.
3. ¿El gate por plan se combina con el de modo, o servicios es gratis?
   `plans.features` no tiene claves de modo.

### Criterio de aceptación

- [ ] `feature_flags_plan_test.dart` y `menu_gating_retail_test.dart`
      extendidos con los casos de servicios, siguiendo el patrón que ya
      quedó fijado en `7bf97b4`: fixtures con el catálogo **real** de
      `public.planes`, no inventado.
- [ ] `analyze` limpio y suite completa en verde.

---

## Pendientes menores

| # | Qué | Por qué |
|---|---|---|
| M-1 | Verificar el Patch #4 en un dispositivo real | Es lo único sin confirmar de esta entrega |
| M-2 | `v1.1.2` apunta a `6807c32`, no al HEAD | Quedó desactualizado, sin efecto |
| M-3 | `app_boosti_vw` está en el repo pero no compila | Nunca se revisó; no está en el workflow |
| M-4 | Migraciones aplicadas a mano, sin tracking en `schema_migrations` | `20261015000001` a `…004` no están marcadas como aplicadas |
