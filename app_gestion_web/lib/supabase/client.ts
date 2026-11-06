import { createBrowserClient } from '@supabase/ssr';

/**
 * Cliente de Supabase para componentes de navegador.
 *
 * La web se publica como exportación estática (`output: 'export'`), por lo
 * que no hay runtime de servidor: todas las llamadas de auth se hacen desde
 * el navegador con este cliente.
 */
export function createClient() {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error(
      'Configura NEXT_PUBLIC_SUPABASE_URL y NEXT_PUBLIC_SUPABASE_ANON_KEY para habilitar la autenticación.',
    );
  }

  return createBrowserClient(supabaseUrl, supabaseAnonKey);
}
