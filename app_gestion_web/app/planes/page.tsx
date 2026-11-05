import PageLayout from '../components/PageLayout';

export default function PlanesPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-mint/15 text-leaf text-xs font-semibold border border-mint/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-leaf animate-pulse" />
            Planes
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Precios simples y transparentes
          </h1>
          <p className="text-lg text-white/60 leading-relaxed mb-10 max-w-2xl mx-auto">
            Sin costos ocultos. Cancela cuando quieras. Elige el plan que mejor se adapte a tu negocio.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              name: 'Starter',
              price: '19',
              desc: 'Para comercios pequeños que están empezando.',
              features: ['1 local', '2 usuarios', 'Ventas ilimitadas', 'Reportes básicos', 'Soporte por email'],
              cta: 'Comenzar',
              highlighted: false,
            },
            {
              name: 'Pro',
              price: '49',
              desc: 'Para negocios en crecimiento con múltiples locales.',
              features: ['3 locales', '10 usuarios', 'Ventas ilimitadas', 'Reportes avanzados', 'Sincronización en tiempo real', 'Soporte prioritario'],
              cta: 'Probar 14 días gratis',
              highlighted: true,
            },
            {
              name: 'Enterprise',
              price: 'A medida',
              desc: 'Para cadenas y franquicias con necesidades específicas.',
              features: ['Locales ilimitados', 'Usuarios ilimitados', 'API personalizada', 'Onboarding dedicado', 'SLA garantizado'],
              cta: 'Contactar ventas',
              highlighted: false,
            },
          ].map((plan, i) => (
            <div
              key={i}
              className={`
                p-8 rounded-3xl transition-all duration-300 ease-in-out
                ${
                  plan.highlighted
                    ? 'bg-linear-to-b from-electric via-indigo to-bg-base shadow-2xl shadow-electric/30 border border-electric/50'
                    : 'bg-deep-slate/50 backdrop-blur-md border border-white/10 hover:border-electric/40'
                }
              `}
            >
              {plan.highlighted && (
                <span className="inline-block px-3 py-1 rounded-full bg-mint text-bg-base text-xs font-extrabold mb-4">
                  MÁS POPULAR
                </span>
              )}
              <h3 className="text-2xl font-bold text-white">{plan.name}</h3>
              <p className="mt-2 text-sm text-white/70">{plan.desc}</p>
              <div className="mt-6 flex items-baseline gap-1">
                {plan.price !== 'A medida' && <span className="text-2xl text-white/60">$</span>}
                <span className="text-5xl font-extrabold text-white">{plan.price}</span>
                {plan.price !== 'A medida' && <span className="text-white/60">/mes</span>}
              </div>
              <ul className="mt-6 space-y-3">
                {plan.features.map((f, j) => (
                  <li key={j} className="flex items-start gap-2 text-sm text-white/80">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="w-4 h-4 mt-0.5 flex-shrink-0 text-mint">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                    {f}
                  </li>
                ))}
              </ul>
              <button
                className={`mt-8 block w-full text-center px-4 py-3.5 rounded-xl font-bold transition-all duration-300 ease-in-out ${
                  plan.highlighted
                    ? 'bg-white text-slate-900 hover:bg-slate-100'
                    : 'bg-white/10 text-white hover:bg-white/20 border border-white/10'
                }`}
              >
                {plan.cta}
              </button>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
