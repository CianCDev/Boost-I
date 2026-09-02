// supabase/functions/create-user/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  try {
    // Verificar que el usuario autenticado tenga rol admin
    const authHeader = req.headers.get("Authorization")?.split(" ")[1];
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "No autorizado" }), { status: 401 });
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const { data: { user }, error: userError } = await supabase.auth.getUser(authHeader);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Token inválido" }), { status: 401 });
    }

    // Verificar que el usuario tenga rol admin en public.usuarios
    const { data: adminData, error: adminError } = await supabase
      .from("usuarios")
      .select("rol")
      .eq("id", user.id)
      .single();

    if (adminError || adminData?.rol !== "admin") {
      return new Response(JSON.stringify({ error: "Se requieren permisos de administrador" }), { status: 403 });
    }

    // Obtener los datos del nuevo usuario del body
    const { email, password, nombre, rol, pin } = await req.json();

    // Crear el usuario en auth.users
    const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { nombre, rol },
    });

    if (createError) {
      return new Response(JSON.stringify({ error: createError.message }), { status: 400 });
    }

    // Insertar en public.usuarios
    const { error: insertError } = await supabase
      .from("usuarios")
      .insert({
        id: newUser.user.id,
        id_isar: null, // Se actualizará después de sincronizar
        nombre,
        rol,
        pin,
        email,
        estado: "inactivo",
        // ... otros campos
      });

    if (insertError) {
      // Si falla la inserción, podríamos eliminar el usuario de auth para mantener consistencia
      await supabase.auth.admin.deleteUser(newUser.user.id);
      return new Response(JSON.stringify({ error: insertError.message }), { status: 400 });
    }

    return new Response(JSON.stringify({ success: true, userId: newUser.user.id }), { status: 200 });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});