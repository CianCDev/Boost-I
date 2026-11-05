import PageLayout from '../components/PageLayout';

export default function APIPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-5xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center mb-12">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-indigo/15 text-[#C4B5FD] text-xs font-semibold border border-indigo/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-lilac animate-pulse" />
            API
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            API de BoostI POS
          </h1>
          <p className="text-lg text-white/60 leading-relaxed max-w-2xl mx-auto">
            Integra BoostI POS con tus propios sistemas usando nuestra API REST.
          </p>
        </div>

        <div className="space-y-6">
          <div className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10">
            <div className="flex items-center gap-2 mb-4">
              <span className="px-2 py-1 rounded bg-mint/20 text-leaf text-xs font-bold">GET</span>
              <code className="text-electric text-sm">/api/v1/ventas</code>
            </div>
            <h4 className="text-white font-bold mb-2">Listar ventas</h4>
            <p className="text-white/60 text-sm">Obtiene el listado de ventas realizadas en el sistema.</p>
          </div>
          <div className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10">
            <div className="flex items-center gap-2 mb-4">
              <span className="px-2 py-1 rounded bg-mint/20 text-leaf text-xs font-bold">POST</span>
              <code className="text-electric text-sm">/api/v1/ventas</code>
            </div>
            <h4 className="text-white font-bold mb-2">Crear venta</h4>
            <p className="text-white/60 text-sm">Registra una nueva venta en el punto de venta.</p>
          </div>
          <div className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10">
            <div className="flex items-center gap-2 mb-4">
              <span className="px-2 py-1 rounded bg-mint/20 text-leaf text-xs font-bold">GET</span>
              <code className="text-electric text-sm">/api/v1/inventario</code>
            </div>
            <h4 className="text-white font-bold mb-2">Consultar inventario</h4>
            <p className="text-white/60 text-sm">Obtiene el stock actual de productos por lote.</p>
          </div>
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
