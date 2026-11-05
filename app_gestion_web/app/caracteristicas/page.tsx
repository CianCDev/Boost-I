import PageLayout from '../components/PageLayout';

export default function CaracteristicasPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-electric/15 text-lilac text-xs font-semibold border border-electric/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-mint animate-pulse" />
            Características
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Características principales
          </h1>
          <p className="text-lg text-white/60 leading-relaxed mb-10 max-w-2xl mx-auto">
            Descubre todas las funciones que hacen de BoostI POS el sistema de
            punto de venta más completo para tu negocio.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              title: 'Ventas ultrarrápidas',
              desc: 'Cobra en segundos con lector de código de barras, balanza integrada y múltiples métodos de pago.',
            },
            {
              title: 'Inventario inteligente',
              desc: 'Controla stock, lotes y vencimientos automáticamente. Recibe alertas antes de quedarte sin producto.',
            },
            {
              title: 'Multi-local',
              desc: 'Gestiona varios locales desde un solo panel. Sincronización en tiempo real entre sucursales.',
            },
            {
              title: 'Reportes en vivo',
              desc: 'Dashboard con métricas clave: ventas por día, top productos, rendimiento por empleado.',
            },
            {
              title: 'Impresión flexible',
              desc: 'Compatible con impresoras térmicas, Bluetooth y red. Tickets, etiquetas y códigos de barras.',
            },
            {
              title: 'Siempre sincronizado',
              desc: 'Trabaja offline y sincroniza automáticamente cuando vuelvas a estar conectado.',
            },
          ].map((item, i) => (
            <div
              key={i}
              className="p-8 rounded-3xl bg-deep-slate/50 backdrop-blur-md border border-white/10 hover:border-electric/40 transition-all duration-300 ease-in-out"
            >
              <div className="w-12 h-12 rounded-2xl bg-electric/20 flex items-center justify-center mb-5 text-electric">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6">
                  <rect x="1" y="4" width="22" height="16" rx="2" ry="2" />
                  <line x1="1" y1="10" x2="7" y2="10" />
                  <line x1="1" y1="14" x2="7" y2="14" />
                </svg>
              </div>
              <h3 className="text-xl font-bold text-white mb-3">{item.title}</h3>
              <p className="text-white/60 text-sm leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
