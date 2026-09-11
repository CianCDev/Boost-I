'use client';

import { useEffect, useState } from 'react';

interface OnboardingDialogProps {
  open: boolean;
  onClose: () => void;
}

const STEPS = [
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8 text-white">
        <circle cx="9" cy="21" r="1" />
        <circle cx="20" cy="21" r="1" />
        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
      </svg>
    ),
    title: '¡Bienvenido a BoostI POS!',
    description: 'Te mostramos en 4 pasos rápidos cómo sacar el máximo provecho a esta demo interactiva.',
    gradient: 'from-[#8B5CF6] to-[#59B1E4]',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8 text-white">
        <rect x="3" y="11" width="18" height="11" rx="2" />
        <path d="M7 11V7a5 5 0 0 1 10 0v4" />
      </svg>
    ),
    title: 'Inicia sesión con PIN',
    description: 'Usa el PIN 1234 para el Administrador o 1010 para el cajero. Es un entorno seguro y de prueba.',
    gradient: 'from-[#10B981] to-[#59B1E4]',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8 text-white">
        <path d="M3 3v18h18" />
        <path d="M7 14l4-4 4 4 5-5" />
      </svg>
    ),
    title: 'Explora todas las funciones',
    description: 'Registra ventas, gestiona inventario, imprime tickets, revisa reportes… Todo funciona de verdad.',
    gradient: 'from-[#FF984F] to-[#8B5CF6]',
  },
  {
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-8 h-8 text-white">
        <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
        <path d="M21 3v5h-5" />
        <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
        <path d="M3 21v-5h5" />
      </svg>
    ),
    title: 'Reinicia cuando quieras',
    description: 'Con un solo clic puedes restablecer todos los datos y empezar desde cero. ¡Experimenta sin miedo!',
    gradient: 'from-[#59B1E4] to-[#10B981]',
  },
];

export default function OnboardingDialog({ open, onClose }: OnboardingDialogProps) {
  const [step, setStep] = useState(0);
  const [dontShowAgain, setDontShowAgain] = useState(false);

  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden';
      const onEsc = (e: KeyboardEvent) => e.key === 'Escape' && handleClose();
      document.addEventListener('keydown', onEsc);
      return () => {
        document.body.style.overflow = '';
        document.removeEventListener('keydown', onEsc);
      };
    }
  }, [open]);

  const handleClose = () => {
    if (dontShowAgain) {
      localStorage.setItem('boostipos_onboarding_done', '1');
    }
    onClose();
    setStep(0);
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
      <div
        className="absolute inset-0 bg-[#0B1120]/85 backdrop-blur-sm"
        onClick={handleClose}
      />

      <div className="relative w-full max-w-md rounded-3xl bg-[#1E293B] border border-white/10 shadow-2xl shadow-black/50 overflow-hidden">
        {/* Barra de progreso */}
        <div className="absolute top-0 left-0 right-0 h-1 bg-white/5">
          <div
            className="h-full bg-gradient-to-r from-[#8B5CF6] to-[#10B981] transition-all duration-500 ease-out"
            style={{ width: `${progress}%` }}
          />
        </div>

        {/* Botón cerrar */}
        <button
          onClick={handleClose}
          className="absolute top-4 right-4 z-10 p-2 rounded-lg text-white/60 hover:text-white hover:bg-white/10 transition-colors"
          aria-label="Cerrar"
        >
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" className="w-5 h-5">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
        </button>

        <div className="p-8 pt-12">
          {/* Icono */}
          <div className={`w-20 h-20 mx-auto rounded-3xl bg-gradient-to-br ${currentStep.gradient} flex items-center justify-center shadow-xl mb-6`}>
            {currentStep.icon}
          </div>

          {/* Contenido */}
          <div className="text-center min-h-[140px]">
            <div className="text-[10px] font-bold uppercase tracking-[0.2em] text-white/40 mb-2">
              Paso {step + 1} de {STEPS.length}
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
                className="w-4 h-4 rounded border-white/20 bg-white/5 text-[#8B5CF6] focus:ring-[#8B5CF6] focus:ring-offset-0 cursor-pointer"
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
              className={`${step > 0 ? 'flex-1' : 'w-full'} px-4 py-3 rounded-xl bg-gradient-to-r from-[#8B5CF6] to-[#59B1E4] text-white text-sm font-bold hover:opacity-90 transition-all shadow-lg shadow-[#8B5CF6]/25`}
            >
              {isLast ? '¡Empezar ahora!' : 'Siguiente'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}