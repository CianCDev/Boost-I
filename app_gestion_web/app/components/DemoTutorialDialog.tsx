'use client';

import { useEffect, useState } from 'react';

interface DemoTutorialDialogProps {
  open: boolean;
  onClose: () => void;
}

/* ============================================================
   PASOS DEL TUTORIAL
   ============================================================ */
const STEPS = [
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-9 h-9 text-white">
        <path d="M3 9l1-5h16l1 5M4 9v11a1 1 0 0 0 1 1h14a1 1 0 0 0 1-1V9M4 9h16" />
        <path d="M9 22V12h6v10" />
      </svg>
    ),
    title: 'Bienvenido a la demo',
    description: 'Este es un entorno de pruebas 100% funcional del POS. Todos los datos son ficticios y podrás experimentar sin límites.',
    gradient: 'from-[#8B5CF6] to-[#59B1E4]',
    badge: 'Paso 1 de 5',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-9 h-9 text-white">
        <polygon points="6 4 20 12 6 20 6 4" fill="currentColor" />
      </svg>
    ),
    title: 'Inicia la aplicación',
    description: 'Haz clic en el botón "Iniciar demo interactiva" para cargar el sistema completo. Puede tardar unos segundos la primera vez.',
    gradient: 'from-[#10B981] to-[#59B1E4]',
    badge: 'Paso 2 de 5',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-9 h-9 text-white">
        <rect x="3" y="11" width="18" height="11" rx="2" />
        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
      </svg>
    ),
    title: 'Ingresa con un PIN',
    description: 'Usa el PIN 1234 para el Administrador o 1010 para el Cajero. Son accesos de prueba, no compartas datos reales.',
    gradient: 'from-[#FF984F] to-[#8B5CF6]',
    badge: 'Paso 3 de 5',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-9 h-9 text-white">
        <path d="M3 3v18h18" />
        <path d="M7 14l4-4 4 4 5-5" />
      </svg>
    ),
    title: 'Explora cada módulo',
    description: 'Registra ventas, gestiona inventario, imprime tickets, revisa reportes y prueba la caja. Todo funciona de verdad.',
    gradient: 'from-[#59B1E4] to-[#10B981]',
    badge: 'Paso 4 de 5',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-9 h-9 text-white">
        <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
        <path d="M21 3v5h-5" />
        <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
        <path d="M3 21v-5h5" />
      </svg>
    ),
    title: 'Reinicia cuando quieras',
    description: 'Con el botón "Restablecer datos" puedes volver todo al estado inicial en cualquier momento. ¡Experimenta sin miedo!',
    gradient: 'from-[#8B5CF6] to-[#10B981]',
    badge: 'Paso 5 de 5',
  },
];

/* ============================================================
   COMPONENTE
   ============================================================ */
export default function DemoTutorialDialog({ open, onClose }: DemoTutorialDialogProps) {
  const [step, setStep] = useState(0);
  const [dontShowAgain, setDontShowAgain] = useState(false);

  // Bloquear scroll + ESC cuando está abierto
  useEffect(() => {
    if (!open) return;

    document.body.style.overflow = 'hidden';
    const onEsc = (e: KeyboardEvent) => {
      if (e.key === 'Escape') handleClose();
    };
    document.addEventListener('keydown', onEsc);

    return () => {
      document.body.style.overflow = '';
      document.removeEventListener('keydown', onEsc);
    };
  }, [open, dontShowAgain]);

  // Resetear al paso 0 al cerrar
  useEffect(() => {
    if (!open) setStep(0);
  }, [open]);

  const handleClose = () => {
    if (dontShowAgain) {
      localStorage.setItem('boostipos_demo_tutorial_done', '1');
    }
    onClose();
  };

  const next = () => {
    if (step < STEPS.length - 1) setStep(step + 1);
    else handleClose();
  };

  const prev = () => step > 0 && setStep(step - 1);

  if (!open) return null;

  const currentStep = STEPS[step];
  const isLast = step === STEPS.length - 1;
  const progress = ((step + 1) / STEPS.length) * 100;

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
      {/* Overlay */}
      <div
        className="absolute inset-0 bg-[#0B1120]/85 backdrop-blur-sm"
        onClick={handleClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-md rounded-3xl bg-[#1E293B] border border-white/10 shadow-2xl shadow-black/50 overflow-hidden animate-[fade-in_0.3s_ease-out]">
        {/* Barra de progreso */}
        <div className="absolute top-0 left-0 right-0 h-1 bg-white/5">
          <div
            className="h-full bg-gradient-to-r from-[#8B5CF6] to-[#10B981] transition-all duration-500 ease-out"
            style={{ width: `${progress}%` }}
          />
        </div>

        {/* Glow decorativo */}
        <div className="absolute -top-20 -right-20 w-64 h-64 bg-[#8B5CF6]/20 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-[#10B981]/15 rounded-full blur-3xl pointer-events-none" />

        {/* Botón cerrar */}
        <button
          onClick={handleClose}
          className="absolute top-4 right-4 z-10 p-2 rounded-lg text-white/60 hover:text-white hover:bg-white/10 transition-colors"
          aria-label="Cerrar tutorial"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" className="w-5 h-5">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        <div className="relative p-8 pt-12">
          {/* Icono */}
          <div
            className={`w-20 h-20 mx-auto rounded-3xl bg-gradient-to-br ${currentStep.gradient} flex items-center justify-center shadow-2xl shadow-black/40 mb-6`}
          >
            {currentStep.icon}
          </div>

          {/* Contenido */}
          <div className="text-center min-h-[150px]">
            <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white/5 text-[10px] font-bold uppercase tracking-wider text-white/50 mb-3">
              <span className="w-1 h-1 rounded-full bg-[#10B981]" />
              {currentStep.badge}
            </div>
            <h2 className="text-xl font-extrabold text-white tracking-tight">
              {currentStep.title}
            </h2>
            <p className="mt-3 text-sm text-white/60 leading-relaxed">
              {currentStep.description}
            </p>
          </div>

          {/* Indicadores */}
          <div className="flex items-center justify-center gap-1.5 my-6">
            {STEPS.map((_, i) => (
              <button
                key={i}
                onClick={() => setStep(i)}
                className={`h-1.5 rounded-full transition-all duration-300 ${
                  i === step
                    ? 'w-6 bg-[#8B5CF6]'
                    : i < step
                    ? 'w-1.5 bg-[#10B981]'
                    : 'w-1.5 bg-white/15 hover:bg-white/30'
                }`}
                aria-label={`Ir al paso ${i + 1}`}
              />
            ))}
          </div>

          {/* No mostrar de nuevo */}
          {isLast && (
            <label className="flex items-center gap-2 justify-center cursor-pointer mb-4 select-none">
              <input
                type="checkbox"
                checked={dontShowAgain}
                onChange={(e) => setDontShowAgain(e.target.checked)}
                className="w-4 h-4 rounded border-white/20 bg-white/5 text-[#8B5CF6] focus:ring-[#8B5CF6] focus:ring-offset-0 cursor-pointer accent-[#8B5CF6]"
              />
              <span className="text-xs text-white/60">No volver a mostrar</span>
            </label>
          )}

          {/* Navegación */}
          <div className="flex gap-2">
            {step > 0 && (
              <button
                onClick={prev}
                className="flex-1 px-4 py-3 rounded-xl bg-white/5 text-white/80 text-sm font-semibold border border-white/10 hover:bg-white/10 hover:text-white transition-all"
              >
                Anterior
              </button>
            )}
            <button
              onClick={next}
              className={`${
                step > 0 ? 'flex-1' : 'w-full'
              } px-4 py-3 rounded-xl bg-gradient-to-r from-[#8B5CF6] to-[#59B1E4] text-white text-sm font-bold hover:opacity-90 transition-all shadow-lg shadow-[#8B5CF6]/25`}
            >
              {isLast ? '¡Empezar a explorar!' : 'Siguiente'}
            </button>
          </div>
        </div>
      </div>

      {/* Keyframe inline para el fade-in del modal */}
      <style jsx>{`
        @keyframes fade-in {
          from { opacity: 0; transform: translateY(8px) scale(0.98); }
          to   { opacity: 1; transform: translateY(0) scale(1); }
        }
      `}</style>
    </div>
  );
}