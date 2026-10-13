// supabase/functions/create-tenant/index.ts
//
// Edge Function PÚBLICA para crear un tenant (empresa) nuevo.
//
// NO requiere JWT porque es para signup. Un cliente nuevo no tiene cuenta
// todavía. La función usa service_role internamente para crear todo.
//
// Flujo:
// 1. Valida los datos de entrada.
// 2. Crea la fila en `locales` (el tenant).
// 3. Crea el usuario admin en `auth.users` con tenant_id en metadata.
//    El trigger `handle_new_user` inserta automáticamente en `public.usuarios`.
// 4. Asigna id_isar al usuario (necesario para que el sync no lo borre).
// 5. Inserta en `usuarios_locales` (lo que el hook lee para el JWT).
// 6. Registra el tenant en `tenants` + `suscripciones` (registro SaaS).
// 7. Devuelve tenant_id y user_id.
//
// ⚠️ El PIN NUNCA se pone acá. Antes esta función hardcodeaba `pin: "1234"`
//    en el metadata y en el insert manual, y como `usuarios.pin` es texto
//    plano, `IsarService.validarLogin` (que NO valida fuerza) comparaba
//    directo: todo tenant nuevo del SaaS quedaba con un PIN adivinable
//    que nadie había configurado. El admin fija su PIN en el onboarding
//    (`SetupPinScreen`) apenas entra a la app.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const ERROR_GENERICO =
  "No se pudo crear la cuenta. Verifica tus datos o inicia sesión si ya tienes una cuenta.";

// Días de trial que se cuentan desde la creación del tenant.
const TRIAL_DIAS = 14;

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse(405, { success: false, error: "Método no permitido" });
  }

  try {
    const body = await req.json();
    const { empresa, admin_nombre, email, password, telefono, rif } = body;

    // ============================================================
    // 1. VALIDACIONES
    // ============================================================
    if (!empresa || typeof empresa !== "string" || empresa.trim().length < 2) {
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }
    if (
      !admin_nombre ||
      typeof admin_nombre !== "string" ||
      admin_nombre.trim().length < 2
    ) {
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }
    if (!email || typeof email !== "string" || !isValidEmail(email)) {
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }
    if (!password || typeof password !== "string" || password.length < 8) {
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }

    const emailLimpio = email.trim().toLowerCase();
    const empresaLimpia = empresa.trim();
    const adminNombreLimpio = admin_nombre.trim();

    // ============================================================
    // 2. CLIENTE ADMIN (service_role)
    // ============================================================
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // ============================================================
    // 3. CREAR TENANT EN `locales`
    // ============================================================
    const { data: tenantData, error: tenantError } = await supabase
      .from("locales")
      .insert({
        nombre: empresaLimpia,
        telefono: telefono?.trim() || null,
        rif: rif?.trim() || null,
        activo: true,
        sync_status: "synced",
        sincronizado: true,
      })
      .select("id")
      .single();

    if (tenantError || !tenantData) {
      console.error("[create-tenant] Error creando tenant:", tenantError);
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }

    const tenantId: string = tenantData.id;

    // ============================================================
    // 4. CREAR USUARIO EN `auth.users`
    //    El trigger handle_new_user insertará en public.usuarios
    //
    //    ⚠️ SIN `pin` en el metadata a propósito. Antes iba `pin: "1234"`
    //    hardcodeado: `usuarios.pin` es texto plano, `validatePin()` no
    //    corre en el login, y todo tenant nuevo quedaba con un PIN
    //    adivinable que el dueño nunca configuró. El admin elige su PIN
    //    en `SetupPinScreen` al terminar el onboarding.
    // ============================================================
    const { data: newUser, error: createUserError } =
      await supabase.auth.admin.createUser({
        email: emailLimpio,
        password: password,
        email_confirm: true,
        user_metadata: {
          nombre: adminNombreLimpio,
          rol: "admin",
          tenant_id: tenantId, // ← el trigger lo necesita
        },
      });

    if (createUserError || !newUser?.user) {
      // Rollback: borrar tenant
      await supabase.from("locales").delete().eq("id", tenantId);
      console.error(
        "[create-tenant] Error creando usuario auth:",
        createUserError
      );
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }

    const userId: string = newUser.user.id;

    // ============================================================
    // 5. ASIGNAR id_isar AL USUARIO
    //    El sync service borra usuarios sin id_isar (los considera
    //    huérfanos). Necesitamos asignarlo.
    // ============================================================

    // 5a. Calcular el siguiente id_isar disponible (MAX + 1)
    const { data: maxIdData } = await supabase
      .from("usuarios")
      .select("id_isar")
      .order("id_isar", { ascending: false, nullsFirst: false })
      .limit(1)
      .maybeSingle();

    const nuevoIdIsar = ((maxIdData?.id_isar as number) ?? 0) + 1;

    // 5b. Verificar si el trigger insertó la fila
    const { data: usuarioRow } = await supabase
      .from("usuarios")
      .select("id")
      .eq("id", userId)
      .maybeSingle();

    if (!usuarioRow) {
      // Caso A: el trigger NO insertó → insertar manualmente
      console.warn(
        "[create-tenant] Trigger no insertó en usuarios. Insertando manualmente..."
      );
      const { error: manualInsertError } = await supabase
        .from("usuarios")
        .insert({
          id: userId,
          id_isar: nuevoIdIsar,
          nombre: adminNombreLimpio,
          email: emailLimpio,
          rol: "admin",
          tenant_id: tenantId,
          estado: "activo",
          // Sin pin: ver nota en el paso 4.
        });

      if (manualInsertError) {
        // Rollback completo
        await supabase.auth.admin.deleteUser(userId);
        await supabase.from("locales").delete().eq("id", tenantId);
        console.error(
          "[create-tenant] Error insertando manual en usuarios:",
          manualInsertError
        );
        return jsonResponse(400, { success: false, error: ERROR_GENERICO });
      }
    } else {
      // Caso B: el trigger SÍ insertó → actualizar id_isar y estado
      const { error: updateUserError } = await supabase
        .from("usuarios")
        .update({
          id_isar: nuevoIdIsar,
          estado: "activo",
        })
        .eq("id", userId);

      if (updateUserError) {
        console.warn(
          "[create-tenant] Error actualizando id_isar/estado:",
          updateUserError
        );
        // No bloqueante: el usuario podrá activarse al hacer login PIN,
        // pero SÍ es bloqueante para el sync (borraría al usuario).
        // Por eso hacemos rollback completo si esto falla.
        await supabase.auth.admin.deleteUser(userId);
        await supabase.from("locales").delete().eq("id", tenantId);
        return jsonResponse(400, { success: false, error: ERROR_GENERICO });
      }
    }

    // ============================================================
    // 6. INSERTAR EN `usuarios_locales` (lo que el HOOK lee para el JWT)
    // ============================================================
    const { error: insertUserLocalError } = await supabase
      .from("usuarios_locales")
      .insert({
        usuario_id: userId,
        tenant_id: tenantId,
        rol: "admin",
        es_default: true,
        activo: true,
      });

    if (insertUserLocalError) {
      // Rollback completo
      await supabase.from("usuarios").delete().eq("id", userId);
      await supabase.auth.admin.deleteUser(userId);
      await supabase.from("locales").delete().eq("id", tenantId);
      console.error(
        "[create-tenant] Error insertando en usuarios_locales:",
        insertUserLocalError
      );
      return jsonResponse(400, { success: false, error: ERROR_GENERICO });
    }

    // ============================================================
    // 6.5 REGISTRO SaaS — `tenants` + `suscripciones`
    //
    // Por qué: el Control Center (`TenantsRepository.listarConSuscripcion`)
    // lee de `tenants` con embed `suscripciones(*, planes(*))`. El signup
    // solo escribía `locales` + `usuarios` + `usuarios_locales`, así que
    // cada empresa nueva era invisible para el admin hasta que alguien la
    // insertaba a mano desde el dashboard.
    //
    // ⚠️ `tenants.id` == `locales.id`. Es el mismo UUID: el Control Center
    //    correlaciona tenant ↔ local y el JWT ya usa ese id como `tenant_id`.
    //
    // ⚠️ NO aborta el signup. El local y el usuario ya están creados y
    //    válidos; si el registro SaaS falla, el peor caso es una empresa
    //    que hay que dar de alta a mano. Perder el alta del cliente sería
    //    mucho peor.
    // ============================================================
    await registrarEnRegistry(supabase, {
      tenantId,
      empresa: empresaLimpia,
      email: emailLimpio,
      telefono: telefono?.trim() || null,
      rif: rif?.trim() || null,
      ownerId: userId,
    });

    // ============================================================
    // 7. ÉXITO
    // ============================================================
    return jsonResponse(200, {
      success: true,
      tenant_id: tenantId,
      user_id: userId,
      mensaje: "Cuenta creada correctamente",
    });
  } catch (error) {
    console.error("[create-tenant] Error inesperado:", error);
    return jsonResponse(500, { success: false, error: ERROR_GENERICO });
  }
});

// ============================================================
// HELPERS
// ============================================================

interface DatosRegistro {
  tenantId: string;
  empresa: string;
  email: string;
  telefono: string | null;
  rif: string | null;
  ownerId: string;
}

/**
 * Da de alta el tenant en el registro SaaS (`tenants`) y le crea la
 * suscripción de trial (`suscripciones`).
 *
 * Nunca throw: el alta del local y del usuario ya ocurrió y es lo que
 * el cliente percibe como "funcionó". Un fallo acá se loguea y la
 * empresa queda para carga manual.
 */
async function registrarEnRegistry(
  supabase: ReturnType<typeof createClient>,
  d: DatosRegistro,
): Promise<void> {
  // ── `tenants` ──
  // Columnas según `Tenant.toMap()` (admin_console/data/models/tenant.dart).
  const { error: tenantsError } = await supabase.from("tenants").insert({
    id: d.tenantId,
    nombre: d.empresa,
    rif: d.rif,
    email_contacto: d.email,
    telefono: d.telefono,
    owner_id: d.ownerId,
    activo: true,
  });

  if (tenantsError) {
    // 23505 = duplicate key: el tenant ya estaba en el registry. Es
    // idempotencia, no un error.
    if (tenantsError.code === "23505") {
      console.warn(
        "[create-tenant] tenants ya tenía el id " +
          d.tenantId +
          " (idempotente)",
      );
    } else {
      console.error(
        "[create-tenant] Error insertando en tenants:",
        tenantsError.message,
      );
    }
    // No se corta: `suscripciones` tiene FK a `tenants`, así que sin la
    // fila en `tenants` el insert de abajo también fallaría.
    return;
  }

  // ── `suscripciones` ──
  //
  // `plan_id` es obligatorio en la práctica: el modelo Dart lo lee con
  // `map['plan_id'] as String` (no nullable), así que una suscripción sin
  // plan rompe la lista del Control Center. Por eso se lee de una env var
  // en vez de inventar un id: si el owner no la seteó, se saltea el trial
  // en vez de crear una suscripción huérfana.
  const trialPlanId = Deno.env.get("TRIAL_PLAN_ID")?.trim();

  if (!trialPlanId) {
    console.warn(
      "[create-tenant] TRIAL_PLAN_ID no definida: el tenant " +
        d.tenantId +
        " queda sin suscripción. Asignale un plan desde el Control Center.",
    );
    return;
  }

  const venceEn = new Date(
    Date.now() + TRIAL_DIAS * 24 * 60 * 60 * 1000,
  ).toISOString();

  // Columnas según `Suscripcion.toMap()` (admin_console/data/models/suscripcion.dart).
  const { error: subError } = await supabase.from("suscripciones").insert({
    tenant_id: d.tenantId,
    plan_id: trialPlanId,
    estado: "trial",
    iniciado_en: new Date().toISOString(),
    trial_vence_en: venceEn,
    auto_renovar: true,
  });

  if (subError) {
    console.error(
      "[create-tenant] Error insertando en suscripciones:",
      subError.message,
    );
  }
}

function jsonResponse(status: number, body: unknown) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}