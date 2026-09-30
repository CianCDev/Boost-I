# Política de Privacidad, Inmutabilidad de Datos y Dev Mode
## BoostI POS — JAHTLABS

> Última actualización: [Fecha]
> Owner: Yan Camacaro — camacaroyan@gmail.com
> Versión: 1.0

---

## PARTE I — POLÍTICA DE PRIVACIDAD

### 1. Principio fundamental

**Los datos operativos del negocio son propiedad exclusiva del cliente.**

JAHTLABS no accede, lee, procesa ni comparte datos de ventas, gastos,
productos, clientes finales, empleados, inventario o cualquier otro dato
operativo del tenant. El acceso técnico se limita a metadata contractual
necesaria para la prestación del servicio.

### 2. Datos que JAHTLABS SÍ conoce

| Categoría | Ejemplos | Motivo |
|-----------|----------|--------|
| **Identificación del negocio** | Nombre, RIF, dirección fiscal | Contrato comercial |
| **Contacto del admin** | Email y teléfono del administrador que registró la cuenta | Soporte y comunicación |
| **Suscripción** | Plan, estado, fechas de vigencia | Gestión del servicio |
| **Metadata técnica** | Fecha de alta, última sincronización, versión de app | Diagnóstico |
| **Pagos recibidos** | Monto, método, período cubierto | Contabilidad interna |

### 3. Datos que JAHTLABS NO conoce

- Ventas individuales del negocio.
- Productos, precios y stock.
- Datos de clientes finales (nombres, cédulas, teléfonos).
- Gastos, compras, costos.
- Nóminas y datos de empleados.
- Movimientos de inventario y lotes.
- Reportes financieros internos.

Estos datos viven en:
1. **Localmente** (Isar en el dispositivo del cliente).
2. **En Supabase** bajo RLS estricta que aísla al tenant.

JAHTLABS **nunca** ejecuta queries sobre estas tablas en nombre propio.

### 4. Inmutabilidad de datos operativos

Una vez creados, los siguientes registros son **inmutables**:

| Entidad | Editable | Eliminable | Anulable |
|---------|:--------:|:----------:|:--------:|
| Ventas | ❌ | ❌ | ✅ (contra-registro) |
| Detalle de ventas | ❌ | ❌ | ✅ (con la venta) |
| Pagos de venta | ❌ | ❌ | ✅ (contra-registro) |
| Movimientos de inventario | ❌ | ❌ | ✅ (contra-movimiento) |
| Logs de auditoría | ❌ | ❌ | ❌ |
| Turnos cerrados | ❌ | ❌ | ❌ |
| Gastos | ⏱️ < 24h | ❌ | ✅ (contra-registro) |

**Regla de anulación**: no se edita ni elimina el original. Se crea un
nuevo registro que marca el original como anulado, indicando:
- Quién anuló.
- Cuándo.
- Motivo.
- Referencia al registro original.

Esta regla aplica **a todos los usuarios del tenant**, incluido el
administrador. Y aplica también a JAHTLABS: aunque técnicamente
pudiéramos modificar, no lo hacemos por diseño.

### 5. Derechos del cliente

| Derecho | Implementación |
|---------|----------------|
| **Acceso** | El cliente ve todos sus datos en la app. |
| **Portabilidad** | Botón "Exportar mis datos" → ZIP con JSON + CSV de toda su información. |
| **Rectificación** | Edición de datos operativos según reglas (ventas inmutables, gastos <24h). |
| **Eliminación** | Botón "Eliminar mi cuenta" → soft delete → 30 días → hard delete automático. |
| **Oposición** | El cliente puede desactivar cualquier feature opcional (Telegram, etc.). |

### 6. Cifrado y seguridad

- **En tránsito**: TLS 1.3 con Supabase.
- **En reposo**: cifrado AES-256 en Supabase Storage.
- **Autenticación**: JWT con refresh automático.
- **PIN de empleados**: hasheado con bcrypt + salt único.
- **Backups**: cifrados y almacenados en bucket privado por tenant.

### 7. Compliance

- **LOPDP (Venezuela)**: cumplimos con la Ley Orgánica de Protección de
  Datos Personales.
- **GDPR-style**: aplicamos los mismos principios aunque no sea obligatorio.
- **DPA (Data Processing Agreement)**: disponible para clientes Pro y
  Corporativo bajo solicitud.

### 8. Modificaciones de esta política

Cualquier cambio sustancial se comunica con 30 días de anticipación.
Los clientes deben aceptar la nueva versión al próximo login.

---

## PARTE II — DEV MODE (Consola de Super Admin)

### 1. Propósito

Herramienta interna de JAHTLABS para gestionar clientes (tenants),
suscripciones, planes y comunicación — **sin acceso a datos operativos**.

### 2. Principios

1. **Mínimo privilegio**: solo lo estrictamente necesario.
2. **Read-only sobre tenants**: nunca escribe sobre datos del cliente.
3. **Auditabilidad total**: cada acción queda registrada.
4. **Sin impersonación**: decisión explícita (Opción A). El super admin
   nunca "entra como" el cliente.
5. **Sin acceso a datos operativos**: RLS lo impide a nivel de base de
   datos, no solo de UI.

### 3. Acceso

#### 3.1. Requisitos

- Email registrado en `public.super_admins` con `activo = true`.
- Contraseña de Supabase Auth.
- PIN de 6 dígitos configurado.
- Frase secreta vigente.

#### 3.2. Flujo de login

```
1. App arranca → EmailLoginScreen
2. Usuario ingresa email
3. App verifica: ¿está en super_admins?
   - NO → login normal (PIN del tenant)
   - SÍ → DevLoginScreen (pantalla oculta, no navegable desde menús)
4. DevLoginScreen pide: password + PIN + frase secreta
5. Si los 3 son válidos:
   - Supabase Auth signIn
   - JWT incluye claim is_super_admin = true
   - Redirige a DevShellScreen
6. Si falla:
   - Rate limit: 5 intentos/hora
   - Bloqueo temporal de 1h
   - Notificación por email a super admins activos
```

#### 3.3. Sesión

- Duración máxima: 4 horas.
- Logout obligatorio al cambiar de red.
- Se registra IP + device_id.

#### 3.4. Frase secreta

- **Única por super admin** (no compartida).
- **Rotación obligatoria cada 90 días**.
- Guardada **hasheada en servidor** (bcrypt vía RPC).
- Backup en gestor de secretos (Bitwarden/1Password) — nunca en código.

### 4. Capacidades

| Área | Acción | Impacto |
|------|--------|---------|
| **Tenants** | Ver lista con metadata | Ninguno |
| | Buscar por nombre / RIF / email | Ninguno |
| | Ver detalle (metadata + contacto admin) | Ninguno |
| **Suscripción** | Cambiar plan | Notificación al tenant |
| | Extender trial | Notificación |
| | Suspender / Reactivar | Al próximo login |
| | Marcar "en mora" | Banner rojo en el login |
| | Ver historial de cambios | Ninguno |
| **Planes** | CRUD del catálogo | Afecta nuevos tenants |
| | Preview como lo ve el cliente | Ninguno |
| **Pagos** | Registrar pagos recibidos (interno) | Ninguno |
| | Exportar CSV de pagos | Ninguno |
| **Comunicación** | Enviar banner in-app | Visible en la app |
| | Programar activación/expiración | Ninguno |
| **Notas** | Añadir notas internas | Solo visibles para super admin |
| **Diagnóstico** | Ver errores técnicos (PII redactada) | Ninguno |
| **Auditoría** | Ver log de acciones propias | Ninguno |

### 5. Bloqueado explícitamente

| Área | Bloqueo técnico |
|------|-----------------|
| Ventas del tenant | RLS: sin policy para super admin |
| Detalle de ventas | RLS |
| Productos y precios | RLS |
| Clientes finales | RLS |
| Empleados y nóminas | RLS |
| Inventario y movimientos | RLS |
| Gastos | RLS |
| Reportes financieros | No expuestos |
| Impersonación | No implementado |
| Exportación de datos del tenant | No implementado |

### 6. Data Immutability (aplica a todos)

Regla implementada en:
- **Isar local**: `IsarService` no expone `update`/`delete` para entidades
  críticas. Solo `put` de nuevos registros.
- **Supabase RLS**: solo policies de `INSERT` y `SELECT`. Sin `UPDATE` ni
  `DELETE`.
- **UI**: los botones de edición/eliminación no existen para estas
  entidades.

### 7. Seguridad

| Capa | Medida |
|------|--------|
| Cliente | Código ofuscado, sin strings reveladores |
| Auth | 3 factores (email + PIN + frase) |
| JWT | Claim `is_super_admin` |
| RLS | Policies explícitas por tabla |
| RPC | Acciones críticas vía función SQL |
| Auditoría | Todo queda registrado |
| Rotación | Frase secreta cada 90 días |
| Rate limit | 5 intentos/hora/IP |
| MFA | PIN + frase, obligatorios |
| Sesión | Máx 4h, 2 dispositivos simultáneos |
| Notificación | Email a super admins ante login sospechoso |

### 8. Auditoría externa

- **Pentest cada 6 meses** por empresa externa.
- **Revisión interna trimestral** de accesos y super_admins activos.
- **Log inmutable** de todas las acciones (no editable ni desde la app
  ni desde RPC).

### 9. Roadmap

| Fase | Entregable |
|------|-----------|
| **A** | Auth + Lista de tenants |
| **B** | Detalle + Cambio de plan/suscripción |
| **C** | Gestión de planes + Pagos |
| **D** | Banners + Auditoría |
| **E** | Dashboard agregado |

---

## PARTE III — CHECKLIST LEGAL PRE-LAUNCH

### Documentos

- [ ] Términos y Condiciones de Uso.
- [ ] Política de Privacidad (este documento, sección pública).
- [ ] Aviso de Cookies (si la web los usa).
- [ ] Contrato SaaS (Pro/Corporativo).
- [ ] Política de Reembolsos.
- [ ] Aviso de Propiedad Intelectual.
- [ ] DPA (Data Processing Agreement) para Pro/Corporativo.

### Producto

- [ ] Onboarding legal con checkbox de aceptación.
- [ ] Settings → "Legal" con los 3 documentos.
- [ ] Aviso "T&C actualizados" al login si cambian.
- [ ] Botón "Exportar mis datos".
- [ ] Botón "Eliminar mi cuenta" con ventana de 30 días.

### Técnico

- [ ] Backup automático verificado.
- [ ] Monitoring continuo (Sentry).
- [ ] Alertas ante errores críticos.
- [ ] Log de intentos de login fallidos.
- [ ] Cron de rotación de frase secreta.
- [ ] Cron de cleanup (tenants eliminados >30 días).

### Marketing

- [ ] Landing page con precios.
- [ ] Sistema de pagos (Binance/Pago Móvil/Zinli/Zelle).
- [ ] Documentación de usuario.
- [ ] Video tutorial (opcional).
- [ ] Casos de éxito (con consentimiento).

---

## Anexo — Contacto

Yan Camacaro
CEO & Propietario Intelectual
camacaroyan@gmail.com
JAHTLABS