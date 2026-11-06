'use client';

import Link from 'next/link';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

/// URL de retorno del correo de recuperación en producción.
/// Se fija explícitamente para que el enlace funcione aunque la app se abra
/// desde un dominio distinto o desde la exportación estática en Netlify.
const RESET_PASSWORD_REDIRECT_URL =
  'https://boostisoftware.netlify.app/auth/reset-password';

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setLoading(true);
    setErrorMessage('');
    setSubmitted(false);

    try {
      const supabase = createClient();
      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: RESET_PASSWORD_REDIRECT_URL,
      });

      if (error) {
        throw error;
      }

      setSubmitted(true);
    } catch (error) {
      console.error(
        'Error al solicitar el restablecimiento de contraseña:',
        error,
      );
      setErrorMessage('No se pudo procesar la solicitud. Inténtalo de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-bg-base px-4 py-16 text-white">
      <section className="w-full max-w-md rounded-3xl border border-white/10 bg-deep-slate/70 p-8 shadow-2xl shadow-black/30">
        <Link
          href="/auth/login"
          className="text-sm text-white/60 transition-colors duration-300 ease-in-out hover:text-white"
        >
          ← Volver al inicio de sesión
        </Link>
        <h1 className="mt-6 text-3xl font-extrabold tracking-tight">
          Recuperar contraseña
        </h1>
        <p className="mt-2 text-sm text-white/60">
          Ingresa tu correo y, si está asociado a una cuenta, recibirás un
          enlace para crear una contraseña nueva.
        </p>

        <form onSubmit={handleSubmit} className="mt-8 space-y-5">
          <div>
            <label
              htmlFor="email"
              className="mb-2 block text-sm font-medium text-white/80"
            >
              Correo electrónico
            </label>
            <input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(event) => setEmail(event.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-white outline-none transition-colors duration-300 ease-in-out focus:border-electric"
            />
          </div>

          {errorMessage && (
            <p role="alert" className="text-sm text-red-300">
              {errorMessage}
            </p>
          )}
          {submitted && (
            <p role="status" className="text-sm text-emerald-300">
              Si el correo está registrado, recibirás instrucciones para
              restablecer tu contraseña.
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-linear-to-r from-electric to-indigo px-6 py-3.5 font-semibold text-white transition-all duration-300 ease-in-out hover:opacity-90 disabled:opacity-60"
          >
            {loading ? 'Enviando…' : 'Enviar enlace'}
          </button>
        </form>
      </section>
    </main>
  );
}
