'use client';

import Link from 'next/link';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
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
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        throw error;
      }

      setSubmitted(true);
    } catch (error) {
      console.error('Error al iniciar sesión:', error);
      setErrorMessage(
        error instanceof Error
          ? error.message
          : 'No se pudo iniciar sesión. Inténtalo de nuevo.',
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-bg-base px-4 py-16 text-white">
      <section className="w-full max-w-md rounded-3xl border border-white/10 bg-deep-slate/70 p-8 shadow-2xl shadow-black/30">
        <Link
          href="/"
          className="text-sm text-white/60 transition-colors duration-300 ease-in-out hover:text-white"
        >
          ← Volver al inicio
        </Link>
        <h1 className="mt-6 text-3xl font-extrabold tracking-tight">
          Iniciar sesión
        </h1>
        <p className="mt-2 text-sm text-white/60">
          Ingresa con el correo y la contraseña de tu cuenta.
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
          <div>
            <label
              htmlFor="password"
              className="mb-2 block text-sm font-medium text-white/80"
            >
              Contraseña
            </label>
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-white outline-none transition-colors duration-300 ease-in-out focus:border-electric"
            />
          </div>

          <div className="text-right">
            <Link
              href="/auth/forgot-password"
              className="text-sm text-lilac transition-colors duration-300 ease-in-out hover:text-white"
            >
              ¿Olvidaste tu contraseña?
            </Link>
          </div>

          {errorMessage && (
            <p role="alert" className="text-sm text-red-300">
              {errorMessage}
            </p>
          )}
          {submitted && (
            <p role="status" className="text-sm text-emerald-300">
              Inicio de sesión exitoso.
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-xl bg-linear-to-r from-electric to-indigo px-6 py-3.5 font-semibold text-white transition-all duration-300 ease-in-out hover:opacity-90 disabled:opacity-60"
          >
            {loading ? 'Iniciando sesión…' : 'Iniciar sesión'}
          </button>
        </form>
      </section>
    </main>
  );
}
