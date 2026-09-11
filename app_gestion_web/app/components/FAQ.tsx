'use client';

import { useState } from 'react';

const FAQS = [
  {
    q: '¿Necesito instalar algo para usar BoostI POS?',
    a: 'No. BoostI POS funciona 100% desde el navegador. Solo necesitas conexión a internet y un dispositivo (PC, tablet o celular). También puedes instalarlo como app de escritorio o móvil si lo prefieres.',
  },
  {
    q: '¿Funciona sin conexión a internet?',
    a: 'Sí. Nuestro sistema está diseñado con arquitectura offline-first: puedes seguir vendiendo sin conexión y toda la información se sincroniza automáticamente cuando vuelvas a estar en línea.',
  },
  {
    q: '¿Qué hardware es compatible?',
    a: 'Soportamos impresoras térmicas (Epson, Star, Xprinter), lectores de código de barras USB/Bluetooth, básculas seriales y Bluetooth, y cualquier PC con navegador moderno. Los cajones de dinero se activan desde la impresora.',
  },
  {
    q: '¿Mis datos están seguros?',
    a: 'Sí. Utilizamos cifrado TLS de extremo a extremo, autenticación por PIN, backups automáticos diarios y almacenamiento redundante. Tu información vive en tu local y se respalda en la nube.',
  },
  {
    q: '¿Puedo probar antes de pagar?',
    a: '¡Por supuesto! Puedes usar la demo interactiva todo lo que quieras sin compromiso. Cuando estés listo, ofrecemos 14 días de prueba gratis del plan Pro sin necesidad de tarjeta de crédito.',
  },
  {
    q: '¿Cómo migro mis productos actuales?',
    a: 'Ofrecemos importación desde Excel/CSV y también podemos hacer migraciones personalizadas desde otros sistemas (como WooCommerce, Shopify o POS antiguos). Nuestro equipo de onboarding te ayuda sin costo.',
  },
  {
    q: '¿Hay contrato mínimo?',
    a: 'No. Puedes cancelar cuando quieras, sin penalizaciones. Los planes son mensuales y puedes cambiar de plan en cualquier momento según crezca tu negocio.',
  },
];

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <section id="faq" className="py-24 relative">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-[#A78BFA] uppercase tracking-[0.2em]">
            Preguntas frecuentes
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight">
            ¿Tienes dudas? Tenemos respuestas
          </h2>
          <p className="mt-5 text-lg text-white/60">
            Las preguntas más comunes sobre BoostI POS.
          </p>
        </div>

        <div className="space-y-3">
          {FAQS.map((item, i) => {
            const isOpen = openIndex === i;
            return (
              <div
                key={i}
                className={`
                  rounded-2xl border transition-all duration-300 overflow-hidden
                  ${isOpen
                    ? 'bg-[#1E293B]/70 border-[#8B5CF6]/40 shadow-lg shadow-[#8B5CF6]/5'
                    : 'bg-[#1E293B]/40 border-white/10 hover:border-white/20'}
                `}
              >
                <button
                  onClick={() => setOpenIndex(isOpen ? null : i)}
                  className="w-full flex items-center justify-between gap-4 p-6 text-left"
                  aria-expanded={isOpen}
                >
                  <span className="text-base font-bold text-white pr-4">
                    {item.q}
                  </span>
                  <span
                    className={`
                      flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center transition-all duration-300
                      ${isOpen
                        ? 'bg-[#8B5CF6] text-white rotate-45'
                        : 'bg-white/5 text-white/60'}
                    `}
                  >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" className="w-4 h-4">
                      <line x1="12" y1="5" x2="12" y2="19" />
                      <line x1="5" y1="12" x2="19" y2="12" />
                    </svg>
                  </span>
                </button>
                <div
                  className={`
                    overflow-hidden transition-all duration-300 ease-out
                    ${isOpen ? 'max-h-96 opacity-100' : 'max-h-0 opacity-0'}
                  `}
                >
                  <p className="px-6 pb-6 text-sm text-white/70 leading-relaxed">
                    {item.a}
                  </p>
                </div>
              </div>
            );
          })}
        </div>

        <div className="mt-12 text-center">
          <p className="text-white/60 text-sm">
            ¿No encuentras tu respuesta?{' '}
            <a
              href="#contact"
              className="text-[#8B5CF6] hover:text-[#C4B5FD] font-semibold transition-colors"
            >
              Contáctanos →
            </a>
          </p>
        </div>
      </div>
    </section>
  );
}