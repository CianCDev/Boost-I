import PageLayout from '../components/PageLayout';

export default function CentroAyudaPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-5xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-mint/15 text-leaf text-xs font-semibold border border-mint/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-leaf animate-pulse" />
            Centro de ayuda
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Centro de ayuda
          </h1>
          <p className="text-lg text-white/60 leading-relaxed max-w-2xl mx-auto">
            Respuestas a las preguntas más frecuentes sobre BoostI POS.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              title: 'Preguntas frecuentes',
              desc: 'Encuentra respuestas rápidas a las dudas más comunes.',
              icon: 'FAQ',
            },
            {
              title: 'Guías paso a paso',
              desc: 'Tutoriales detallados para configurar y usar cada función.',
              icon: 'Guía',
            },
            {
              title: 'Resolución de problemas',
              desc: 'Soluciones a errores comunes y problemas técnicos.',
              icon: 'Soporte',
            },
            {
              title: 'Facturación y pagos',
              desc: 'Información sobre planes, facturas y métodos de pago.',
              icon: 'Pago',
            },
            {
              title: 'Cuenta y usuarios',
              desc: 'Gestión de perfiles, roles y permisos de empleados.',
              icon: 'Usuario',
            },
            {
              title: 'Hardware y dispositivos',
              desc: 'Configuración de impresoras, lectores y otros dispositivos.',
              icon: 'Dispositivo',
            },
          ].map((item, i) => (
            <div key={i} className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10 hover:border-electric/40 transition-all duration-300 ease-in-out group">
              <div className="w-12 h-12 rounded-2xl bg-electric/20 flex items-center justify-center mb-4 text-electric">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6">
                  <circle cx="12" cy="12" r="10" />
                  <line x1="12" y1="16" x2="12" y2="16" />
                  <line x1="12" y1="8" x2="12.01" y2="8" />
                </svg>
              </div>
              <h3 className="text-lg font-bold text-white mb-2 group-hover:text-electric transition-colors">{item.title}</h3>
              <p className="text-white/60 text-sm leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
