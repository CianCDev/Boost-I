'use client';

import { useEffect, useState } from 'react';

export default function CookieConsent() {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const stored = localStorage.getItem('boostipos_cookie_consent');
    if (!stored) {
      const timer = setTimeout(() => setVisible(true), 1200);
      return () => clearTimeout(timer);
    }
  }, []);

  const accept = () => {
    localStorage.setItem('boostipos_cookie_consent', 'all');
    setVisible(false);
  };

  const reject = () => {
    localStorage.setItem('boostipos_cookie_consent', 'essential');
    setVisible(false);
  };

  if (!visible) return null;

  return (
    <div
      className={`
        fixed bottom-4 left-4 right-4 z-[100]
        md:left-auto md:right-6 md:bottom-6 md:max-w-md
        transition-all duration-500 ease-out
        ${visible ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4'}
      `}
    >
      <div className="rounded-2xl bg-[#1E293B]/95 backdrop-blur-xl border border-white/10 shadow-2xl shadow-black/50 p-5">
        {/* Header */}
        <div className="flex items-start gap-3 mb-4">
          <div className="w-10 h-10 rounded-xl bg-[#8B5CF6]/15 flex items-center justify-center flex-shrink-0">
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="w-5 h-5 text-[#8B5CF6]"
            >
              <path d="M12 2a10 10 0 1 0 10 10 4 4 0 0 1-5-5 4 4 0 0 1-5-5" />
              <path d="M8.5 8.5v.01" />
              <path d="M16 12v.01" />
              <path d="M12 16v.01" />
            </svg>
          </div>
          <div className="flex-1">
            <h3 className="text-white font-bold text-sm">Cookies y privacidad</h3>
            <p className="text-white/60 text-xs mt-1 leading-relaxed">
              Usamos cookies para mejorar tu experiencia, analizar el tráfico y personalizar contenido. Puedes aceptar todas o solo las esenciales.
            </p>
          </div>
        </div>

        {/* Acciones */}
        <div className="flex flex-col sm:flex-row gap-2">
          <button
            onClick={accept}
            className="flex-1 inline-flex items-center justify-center gap-1.5 px-4 py-2.5 rounded-lg bg-gradient-to-r from-[#8B5CF6] to-[#59B1E4] text-white text-xs font-bold hover:opacity-90 transition-all"
          >
            Aceptar todas
          </button>
          <button
            onClick={reject}
            className="flex-1 inline-flex items-center justify-center px-4 py-2.5 rounded-lg bg-white/5 text-white/80 text-xs font-semibold border border-white/10 hover:bg-white/10 hover:text-white transition-all"
          >
            Solo esenciales
          </button>
        </div>

        {/* Link a política */}
        <a
          href="/privacidad"
          className="mt-3 block text-center text-[11px] text-white/40 hover:text-white/70 transition-colors"
        >
          Leer política de privacidad →
        </a>
      </div>
    </div>
  );
}