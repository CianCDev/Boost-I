import PageLayout from '../components/PageLayout';

export default function DocumentacionPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-5xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-indigo/15 text-[#C4B5FD] text-xs font-semibold border border-indigo/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-lilac animate-pulse" />
            Documentación
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Documentación técnica
          </h1>
          <p className="text-lg text-white/60 leading-relaxed max-w-2xl mx-auto">
            Guías de instalación, referencia de API y tutoriales para integrar
            BoostI POS con tu negocio.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              title: 'Inicio rápido',
              desc: 'Guía para comenzar a usar BoostI POS en menos de 5 minutos.',
            },
            {
              title: 'Referencia de API',
              desc: 'Documentación completa de endpoints para integraciones personalizadas.',
            },
            {
              title: 'Hardware compatible',
              desc: 'Lista de impresoras, lectores y básculas soportadas.',
            },
            {
              title: 'Configuración de impresora',
              desc: 'Pasos para conectar impresoras térmicas y configurar tickets.',
            },
            {
              title: 'Sincronización offline',
              desc: 'Cómo funciona la arquitectura offline-first y la sincronización automática.',
            },
            {
              title: 'Multi-local',
              desc: 'Configuración para gestionar múltiples sucursales desde un solo panel.',
            },
          ].map((item, i) => (
            <div key={i} className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10 hover:border-electric/40 transition-all duration-300 ease-in-out group">
              <div className="w-10 h-10 rounded-xl bg-electric/20 flex items-center justify-center mb-4 text-electric group-hover:bg-electric group-hover:text-white transition-colors">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-5 h-5">
                  <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                  <polyline points="14 2 14 8 20 8" />
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
