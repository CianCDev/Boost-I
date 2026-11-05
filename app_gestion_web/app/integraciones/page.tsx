import PageLayout from '../components/PageLayout';

export default function IntegracionesPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-electric/15 text-lilac text-xs font-semibold border border-electric/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-electric animate-pulse" />
            Integraciones
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Se integra con tu hardware
          </h1>
          <p className="text-lg text-white/60 leading-relaxed mb-10 max-w-2xl mx-auto">
            Impresoras térmicas, lectores de código de barras, básculas y más.
            Sin configuraciones complicadas.
          </p>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {[
            { name: 'Epson', category: 'Impresoras' },
            { name: 'Star Micronics', category: 'Impresoras' },
            { name: 'Xprinter', category: 'Impresoras' },
            { name: 'Honeywell', category: 'Lectores' },
            { name: 'Zebra', category: 'Lectores' },
            { name: 'Datalogic', category: 'Lectores' },
            { name: 'Torrey', category: 'Básculas' },
            { name: 'CAS', category: 'Básculas' },
            { name: 'Supabase', category: 'Backend' },
            { name: 'Expo', category: 'Móvil' },
            { name: 'Flutter', category: 'Apps' },
            { name: 'Stripe', category: 'Pagos' },
          ].map((brand, i) => (
            <div
              key={i}
              className="p-6 rounded-2xl bg-deep-slate/40 border border-white/10 hover:border-electric/40 hover:bg-deep-slate/70 transition-all duration-300 ease-in-out"
            >
              <div className="text-center">
                <div className="text-lg font-extrabold text-white/80">{brand.name}</div>
                <div className="text-[10px] font-bold uppercase tracking-widest text-white/40 mt-1">
                  {brand.category}
                </div>
              </div>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
