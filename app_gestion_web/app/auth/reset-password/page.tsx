'use client';

import Link from 'next/link';
import { Suspense, useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

function ResetPasswordForm() {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loadingSession, setLoadingSession] = useState(true);
  const [loading, setLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [ready, setReady] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  useEffect(() => {
    let active = true;

    const prepareRecoverySession = async () => {
      try {
        const supabase = createClient();
        const url = new URL(window.location.href);
        const tokenHash = url.searchParams.get('token_hash');
        const type = url.searchParams.get('type');

        if (tokenHash) {
          if (type !== 'recovery') {
            throw new Error(
              'El enlace no corresponde a una recuperación de contraseña.',
            );
          }

          const { error } = await supabase.auth.verifyOtp({
            token_hash: tokenHash,
            type: 'recovery',
          });
          if (error) throw error;
        }

        // El cliente de navegador intercambia el código PKCE y lee los
        // tokens del flujo implícito durante su primera inicialización.
        const { data, error } = await supabase.auth.getSession();
        if (error) throw error;
        if (!data.session) {
          throw new Error(
            'El enlace de recuperación no es válido o ya venció. Solicita uno nuevo.',
          );
        }

        url.searchParams.delete('code');
        url.searchParams.delete('token_hash');
        url.searchParams.delete('type');
        url.searchParams.delete('error');
        url.searchParams.delete('error_description');
        url.hash = '';
        window.history.replaceState({}, '', url);

        if (active) setReady(true);
      } catch (error) {
        console.error('Error al validar el enlace de recuperación:', error);
        if (active) {
          setErrorMessage(
            error instanceof Error
              ? error.message
              : 'No se pudo validar el enlace. Solicita uno nuevo.',
          );
        }
      } finally {
        if (active) setLoadingSession(false);
      }
    };

    void prepareRecoverySession();

    return () => {
      active = false;
    };
  }, []);

  const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setErrorMessage('');
    setSubmitted(false);

    if (password.length < 6) {
      setErrorMessage('La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    if (password !== confirmPassword) {
      setErrorMessage('Las contraseñas no coinciden.');
      return;
    }

    setLoading(true);
    try {
      const supabase = createClient();
      const { error } = await supabase.auth.updateUser({ password });
      if (error) throw error;
      setSubmitted(true);
      setPassword('');
      setConfirmPassword('');
    } catch (error) {
      console.error('Error al actualizar la contraseña:', error);
      setErrorMessage(
        error instanceof Error
          ? error.message
          : 'No se pudo actualizar la contraseña. Inténtalo de nuevo.',
      );
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
          Crear contraseña nueva
        </h1>

        {loadingSession ? (
          <p role="status" className="mt-4 text-sm text-white/60">
            Validando el enlace…
          </p>
        ) : ready && !submitted ? (
          <>
            <p className="mt-2 text-sm text-white/60">
              Elige una contraseña nueva para tu cuenta.
            </p>
            <form onSubmit={handleSubmit} className="mt-8 space-y-5">
              <div>
                <label
                  htmlFor="password"
                  className="mb-2 block text-sm font-medium text-white/80"
                >
                  Nueva contraseña
                </label>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="new-password"
                  minLength={6}
                  required
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-white outline-none transition-colors duration-300 ease-in-out focus:border-electric"
                />
              </div>
              <div>
                <label
                  htmlFor="confirm-password"
                  className="mb-2 block text-sm font-medium text-white/80"
                >
                  Confirmar contraseña
                </label>
                <input
                  id="confirm-password"
                  name="confirm-password"
                  type="password"
                  autoComplete="new-password"
                  minLength={6}
                  required
                  value={confirmPassword}
                  onChange={(event) => setConfirmPassword(event.target.value)}
                  className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-white outline-none transition-colors duration-300 ease-in-out focus:border-electric"
                />
              </div>

              {errorMessage && (
                <p role="alert" className="text-sm text-red-300">
                  {errorMessage}
                </p>
              )}

              <button
                type="submit"
                disabled={loading}
                className="w-full rounded-xl bg-linear-to-r from-electric to-indigo px-6 py-3.5 font-semibold text-white transition-all duration-300 ease-in-out hover:opacity-90 disabled:opacity-60"
              >
                {loading ? 'Guardando…' : 'Guardar contraseña'}
              </button>
            </form>
          </>
        ) : (
          <div className="mt-4 space-y-4">
            {submitted ? (
              <p role="status" className="text-sm text-emerald-300">
                Tu contraseña se actualizó correctamente.
              </p>
            ) : (
              <p role="alert" className="text-sm text-red-300">
                {errorMessage}
              </p>
            )}
            <Link
              href={submitted ? '/auth/login' : '/auth/forgot-password'}
              className="inline-flex text-sm font-semibold text-lilac transition-colors duration-300 ease-in-out hover:text-white"
            >
              {submitted ? 'Iniciar sesión' : 'Solicitar otro enlace'}
            </Link>
          </div>
        )}
      </section>
    </main>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense
      fallback={
        <main className="flex min-h-screen items-center justify-center bg-bg-base px-4 py-16 text-white">
          <p role="status" className="text-sm text-white/60">
            Cargando…
          </p>
        </main>
      }
    >
      <ResetPasswordForm />
    </Suspense>
  );
}
