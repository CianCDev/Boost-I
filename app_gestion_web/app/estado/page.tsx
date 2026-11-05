import PageLayout from '../components/PageLayout';

export default function EstadoPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center mb-12">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-mint/15 text-leaf text-xs font-semibold border border-mint/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-leaf animate-pulse" />
            Estado
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Estado del sistema
          </h1>
          <p className="text-lg text-white/60 leading-relaxed max-w-2xl mx-auto">
            Consulta el estado actual de todos los servicios de BoostI POS.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-6">
          {[
            { name: 'Sincronización', status: 'operativo', desc: 'Sincronización offline-first activa' },
            { name: 'Impresión', status: 'operativo', desc: 'Impresoras térmicas y tickets disponibles' },
            { name: 'Dashboard', status: 'operativo', desc: 'Reportes y estadísticas en tiempo real' },
          ].map((service, i) => (
            <div key={i} className="p-6 rounded-2xl bg-deep-slate/50 border border-white/10 flex items-center justify-between">
              <div>
                <h4 className="text-white font-bold">{service.name}</h4>
                <p className="text-sm text-white/60">{service.desc}</p>
              </div>
              <div className="flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-leaf animate-pulse" />
                <span className="text-sm font-medium text-leaf">Operativo</span>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
