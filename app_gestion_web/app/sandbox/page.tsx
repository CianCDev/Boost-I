'use client';

import Link from 'next/link';
import { useRef, useState, useCallback, useEffect } from 'react';
import DemoTutorialDialog from '../components/DemoTutorialDialog';

export default function SandboxPage() {
  const iframeRef = useRef<HTMLIFrameElement>(null);

  // Estados del iframe
  const [showIframe, setShowIframe] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  // Estados del tutorial
  const [tutorialOpen, setTutorialOpen] = useState(false);

  /* ============================================================
     AUTO-ABRIR TUTORIAL EN PRIMERA VISITA
     ============================================================ */
  useEffect(() => {
    const done = localStorage.getItem('boostipos_demo_tutorial_done');
    if (!done) {
      const timer = setTimeout(() => setTutorialOpen(true), 1000);
      return () => clearTimeout(timer);
    }
  }, []);

  /* ============================================================
     HANDLERS DEL IFRAME
     ============================================================ */
  const handleReset = useCallback(() => {
    if (iframeRef.current?.contentWindow) {
      iframeRef.current.contentWindow.postMessage({ type: 'RESET_DEMO' }, '*');
    }
  }, []);

  const handleLoadIframe = () => {
    setIsLoading(true);
    setShowIframe(true);
  };

  return (
    <main className="relative min-h-screen bg-[#0B1120] overflow-hidden isolate">
      {/* ============================================================
          BACKGROUND ANIMADO
          ============================================================ */}
      <div className="fixed inset-0 -z-10 pointer-events-none transform-gpu">
        <div className="absolute inset-0 bg-[radial-gradient(ellipse_80%_80%_at_50%_-20%,rgba(139,92,246,0.15),rgba(11,17,32,0))]" />

        <div className="absolute top-[-10%] left-[-10%] w-[500px] h-[500px] rounded-full bg-[#8B5CF6]/15 blur-[90px] animate-blob-slow transform-gpu" />
        <div className="absolute top-[40%] right-[-5%] w-[450px] h-[450px] rounded-full bg-[#59B1E4]/10 blur-[80px] animate-blob-medium transform-gpu" />
        <div className="absolute bottom-[-10%] left-[20%] w-[400px] h-[400px] rounded-full bg-[#10B981]/10 blur-[80px] animate-blob-slow transform-gpu" />

        <div
          className="absolute inset-0 opacity-[0.04] mix-blend-overlay"
          style={{
            backgroundImage:
              "url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='100' height='100'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='2' /%3E%3C/filter%3E%3Crect width='100' height='100' filter='url(%23n)'/%3E%3C/svg%3E\")",
          }}
        />
      </div>

      {/* ============================================================
          HEADER FLOTANTE
          ============================================================ */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 z-10">
        <div className="flex items-center justify-between">
          <Link
            href="/"
            className="group inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/[0.04] backdrop-blur-md border border-white/10 text-white/80 text-sm font-medium hover:bg-white/[0.08] hover:border-white/20 hover:text-white transition-all duration-300"
          >
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="w-4 h-4 group-hover:-translate-x-1 transition-transform duration-300"
            >
              <line x1="19" y1="12" x2="5" y2="12" />
              <polyline points="12 19 5 12 12 5" />
            </svg>
            Volver al inicio
          </Link>

          <div className="flex items-center gap-3">
            {/* Botón tutorial */}
            <button
              onClick={() => setTutorialOpen(true)}
              className="group inline-flex items-center gap-2 px-4 py-2.5 rounded-xl bg-white/[0.04] backdrop-blur-md border border-white/10 text-white/80 text-sm font-medium hover:bg-white/[0.08] hover:border-white/20 hover:text-white transition-all duration-300"
            >
              <svg
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="w-4 h-4"
              >
                <circle cx="12" cy="12" r="10" />
                <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
                <line x1="12" y1="17" x2="12.01" y2="17" />
              </svg>
              <span className="hidden sm:inline">Ver tutorial</span>
            </button>

            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-[#8B5CF6] via-[#59B1E4] to-[#10B981] flex items-center justify-center shadow-lg shadow-[#8B5CF6]/20">
                <svg viewBox="0 0 24 24" fill="none" className="w-5 h-5 text-white">
                  <rect x="3" y="3" width="18" height="18" rx="4" fill="currentColor" />
                  <path d="M8 12h8M12 8v8" stroke="white" strokeWidth="2" strokeLinecap="round" />
                </svg>
              </div>
              <span className="font-bold text-xl text-white tracking-tight hidden sm:block">
                BoostI POS
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* ============================================================
          CONTENIDO PRINCIPAL
          ============================================================ */}
      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-16 z-10 animate-fade-up">
        {/* Título */}
        <div className="text-center mb-10">
          <span className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#10B981]/15 text-[#34D399] text-xs font-semibold border border-[#10B981]/30 backdrop-blur-sm shadow-sm">
            <span className="w-2 h-2 rounded-full bg-[#10B981] animate-pulse" />
            Demo interactiva
          </span>
          <h1 className="mt-6 text-4xl sm:text-5xl font-extrabold text-white tracking-tight">
            Prueba el POS en vivo
          </h1>
          <p className="mt-4 text-lg text-white/60 max-w-2xl mx-auto font-medium">
            Interactúa con el sistema. Todos los datos son de prueba y se reinician con un clic.
          </p>
        </div>

        {/* Toolbar */}
        <div className="flex flex-wrap items-center justify-center gap-4 mb-8">
          <button
            onClick={handleReset}
            disabled={!showIframe || isLoading}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-white/[0.04] backdrop-blur-sm border border-white/10 text-white/90 text-sm font-semibold hover:bg-white/[0.08] hover:border-white/20 transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-white/[0.04]"
          >
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className={`w-4 h-4 ${!isLoading && showIframe ? 'hover:rotate-180 transition-transform duration-500' : ''}`}
            >
              <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
              <path d="M21 3v5h-5" />
              <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
              <path d="M3 21v-5h5" />
            </svg>
            Restablecer datos
          </button>

          <button
            onClick={() => setTutorialOpen(true)}
            className="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#8B5CF6]/10 border border-[#8B5CF6]/25 text-[#C4B5FD] text-sm font-semibold hover:bg-[#8B5CF6]/20 transition-all"
          >
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="w-4 h-4"
            >
              <circle cx="12" cy="12" r="10" />
              <path d="M12 16v-4" />
              <path d="M12 8h.01" />
            </svg>
            ¿Cómo funciona?
          </button>
        </div>

        {/* ============================================================
            IFRAME CONTAINER
            ============================================================ */}
        <div className="relative w-full overflow-hidden rounded-[2rem] shadow-2xl shadow-[#8B5CF6]/15 border border-white/10 bg-[#1E293B]/40 backdrop-blur-md transform-gpu">
          {/* Barra tipo navegador */}
          <div className="flex items-center gap-2 px-5 py-3.5 bg-black/20 border-b border-white/5">
            <div className="flex gap-2">
              <span className="w-3 h-3 rounded-full bg-[#FF5F57] shadow-inner" />
              <span className="w-3 h-3 rounded-full bg-[#FEBC2E] shadow-inner" />
              <span className="w-3 h-3 rounded-full bg-[#28C840] shadow-inner" />
            </div>
            <div className="flex-1 mx-4">
              <div className="px-4 py-1.5 rounded-lg bg-white/5 text-xs text-white/40 font-mono text-center max-w-md mx-auto truncate">
                <span className="text-[#10B981]">https://</span>demo.boostipos.com/app
              </div>
            </div>
          </div>

          {/* Iframe */}
          <div className="relative aspect-[16/10] sm:aspect-[16/9] w-full bg-[#0B1120]">
            {/* Estado 1: Botón de inicio */}
            {!showIframe && (
              <button
                onClick={handleLoadIframe}
                className="absolute inset-0 flex flex-col items-center justify-center bg-[#0B1120]/80 z-20 hover:bg-[#0B1120]/60 transition-colors duration-500 group"
              >
                <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-[#8B5CF6] via-[#59B1E4] to-[#10B981] flex items-center justify-center shadow-2xl shadow-[#8B5CF6]/40 mb-6 group-hover:scale-110 transition-transform duration-500 ease-out">
                  <svg viewBox="0 0 24 24" fill="white" className="w-10 h-10 ml-1">
                    <polygon points="6 4 20 12 6 20 6 4" />
                  </svg>
                </div>
                <p className="text-white font-bold text-xl tracking-tight">
                  Iniciar demo interactiva
                </p>
                <p className="text-white/50 text-sm mt-3 max-w-sm text-center">
                  Se cargará la aplicación completa directamente en tu navegador.
                </p>
              </button>
            )}

            {/* Estado 2: Cargando */}
            {isLoading && showIframe && (
              <div className="absolute inset-0 flex flex-col items-center justify-center bg-[#0B1120] z-10">
                <div className="relative w-14 h-14">
                  <div className="absolute inset-0 rounded-full border-4 border-white/10" />
                  <div className="absolute inset-0 rounded-full border-4 border-[#8B5CF6] border-t-transparent animate-spin" />
                </div>
                <p className="text-sm text-white/50 font-medium mt-6 animate-pulse">
                  Conectando al entorno de pruebas...
                </p>
              </div>
            )}

            {/* Estado 3: Iframe cargado */}
            {showIframe && (
              <iframe
                ref={iframeRef}
                src="/sandbox/index.html"
                className={`w-full h-full border-0 absolute inset-0 z-0 transition-opacity duration-700 ease-out ${
                  isLoading ? 'opacity-0' : 'opacity-100'
                }`}
                sandbox="allow-scripts allow-same-origin allow-forms"
                referrerPolicy="no-referrer"
                onLoad={() => setIsLoading(false)}
                onError={() => setIsLoading(false)}
              />
            )}
          </div>
        </div>

        {/* ============================================================
            FOOTER INFO
            ============================================================ */}
        <div className="mt-12 grid sm:grid-cols-3 gap-5 text-sm animate-fade-up-delay">
          {[
            { title: 'Datos de prueba seguros', desc: 'Experimenta libremente. Nada se guarda y todo se reinicia.' },
            { title: 'Acceso inmediato', desc: 'Sin fricción: no requieres registro, correos ni tarjetas.' },
            { title: '100% Funcional', desc: 'Prueba cierres de caja, lectura de códigos y reportes.' },
          ].map((item, i) => (
            <div
              key={i}
              className="p-6 rounded-2xl bg-white/[0.03] backdrop-blur-sm border border-white/10 hover:bg-white/[0.06] transition-colors"
            >
              <div className="w-2 h-2 rounded-full bg-[#10B981] mb-4" />
              <p className="font-bold text-white text-base">{item.title}</p>
              <p className="text-white/60 mt-2 leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </div>

      {/* ============================================================
          BOTÓN FLOTANTE DE AYUDA
          ============================================================ */}
      <button
        onClick={() => setTutorialOpen(true)}
        className="fixed bottom-6 left-6 z-40 group"
        aria-label="Abrir tutorial"
      >
        <div className="relative">
          <div className="absolute inset-0 rounded-full bg-[#8B5CF6]/40 animate-ping" />
          <div className="relative w-14 h-14 rounded-full bg-gradient-to-br from-[#8B5CF6] to-[#59B1E4] flex items-center justify-center shadow-xl shadow-[#8B5CF6]/40 hover:scale-110 transition-transform duration-300">
            <svg
              viewBox="0 0 24 24"
              fill="none"
              stroke="white"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
              className="w-6 h-6"
            >
              <circle cx="12" cy="12" r="10" />
              <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
              <line x1="12" y1="17" x2="12.01" y2="17" />
            </svg>
          </div>
          <div className="absolute left-full ml-3 top-1/2 -translate-y-1/2 px-3 py-1.5 rounded-lg bg-[#1E293B] border border-white/10 text-white text-xs font-semibold whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none shadow-lg">
            Ver tutorial
          </div>
        </div>
      </button>

      {/* ============================================================
          TUTORIAL
          ============================================================ */}
      <DemoTutorialDialog open={tutorialOpen} onClose={() => setTutorialOpen(false)} />
    </main>
  );
}