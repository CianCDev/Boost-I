'use client';

import { useEffect, useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { Check } from 'lucide-react';
import PageLayout from '../components/PageLayout';

export default function SobreNosotrosPage() {
  const [showMascot, setShowMascot] = useState(false);

  useEffect(() => {
    const intervalId = window.setInterval(() => {
      setShowMascot((current) => !current);
    }, 3000);

    return () => window.clearInterval(intervalId);
  }, []);

  const values = [
    'Transparencia total: Sin costos ocultos, sin letra chiquita.',
    'Calma y comodidad: Diseñamos para reducir el estrés del día a día.',
    'Tecnología accesible: Herramientas potentes, fáciles de usar.',
  ];

  return (
    <PageLayout>
      <main className="mx-auto max-w-7xl px-6 pb-24 pt-32 sm:px-8 lg:pb-32 lg:pt-40">
        <div className="grid items-center gap-14 lg:grid-cols-[0.9fr_1.1fr] lg:gap-20">
          <div className="relative mx-auto w-full max-w-[500px]">
            <div className="absolute -inset-8 rounded-full bg-electric/20 blur-[90px]" />
            <motion.div
              animate={{ y: [0, -10, 0] }}
              transition={{ duration: 4, ease: 'easeInOut', repeat: Infinity }}
              className="relative grid aspect-square place-items-center overflow-hidden rounded-[2rem] border border-white/10 bg-white/5 p-8 shadow-2xl shadow-electric/10 backdrop-blur-md sm:p-12"
            >
              <div className="absolute inset-0 bg-linear-to-br from-electric/10 via-indigo/10 to-mint/10" />
              <AnimatePresence mode="wait">
                <motion.img
                  key={showMascot ? 'mascot' : 'logo'}
                  src={showMascot ? '/images/mascot-pointing.png' : '/images/logo.png'}
                  alt={showMascot ? 'Mascota de BoostI señalando' : 'Logo de BoostI'}
                  initial={{ scale: 0.8, opacity: 0 }}
                  animate={{ scale: 1.2, opacity: 1 }}
                  exit={{ scale: 0.8, opacity: 0 }}
                  transition={{ type: 'spring', stiffness: 180, damping: 16 }}
                  className={`relative z-10 object-contain ${showMascot ? 'h-full w-full' : 'h-[82%] w-[82%]'}`}
                />
              </AnimatePresence>
            </motion.div>
          </div>

          <div>
            <span className="inline-flex items-center gap-2 rounded-full border border-mint/20 bg-mint/10 px-4 py-1.5 text-xs font-semibold uppercase tracking-[0.18em] text-mint">
              Quiénes somos
            </span>
            <h1 className="mt-5 text-4xl font-extrabold leading-tight tracking-tight text-white sm:text-5xl lg:text-6xl">
              Detrás de <span className="text-mint">BoostI POS</span>
            </h1>
            <p className="mt-5 max-w-2xl text-lg leading-relaxed text-white/65 sm:text-xl">
              Construimos la herramienta que nos hubiera gustado tener cuando empezamos.
            </p>

            <div className="mt-10 grid gap-5 sm:grid-cols-2">
              <section className="rounded-2xl border border-white/10 bg-white/[0.04] p-6 backdrop-blur-sm">
                <h2 className="text-lg font-bold text-electric">Nuestra Misión</h2>
                <p className="mt-3 text-sm leading-relaxed text-white/65">
                  Digitalizar y potenciar los negocios del país. Queremos eliminar el caos operativo para que los comerciantes se enfoquen en lo que realmente importa: hacer crecer su negocio.
                </p>
              </section>

              <section className="rounded-2xl border border-white/10 bg-white/[0.04] p-6 backdrop-blur-sm">
                <h2 className="text-lg font-bold text-mint">Nuestra Visión</h2>
                <p className="mt-3 text-sm leading-relaxed text-white/65">
                  Ser el ecosistema de gestión comercial preferido por los emprendedores venezolanos, brindando herramientas de clase mundial con un soporte cercano y humano.
                </p>
              </section>
            </div>

            <section className="mt-8">
              <h2 className="text-lg font-bold text-white">Nuestros Valores</h2>
              <ul className="mt-4 space-y-3">
                {values.map((value) => (
                  <li key={value} className="flex items-start gap-3 text-sm leading-relaxed text-white/70">
                    <span className="mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-mint/10 text-mint">
                      <Check className="h-3.5 w-3.5" strokeWidth={3} />
                    </span>
                    {value}
                  </li>
                ))}
              </ul>
            </section>
          </div>
        </div>
      </main>
    </PageLayout>
  );
}
