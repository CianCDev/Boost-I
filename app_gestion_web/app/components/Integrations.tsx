'use client';

const INTEGRATIONS = [
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
];

export default function Integrations() {
  return (
    <section id="integrations" className="py-24 relative">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-3xl mx-auto mb-16">
          <span className="text-sm font-semibold text-[#59B1E4] uppercase tracking-[0.2em]">
            Compatibilidad total
          </span>
          <h2 className="mt-4 text-4xl sm:text-5xl font-extrabold text-white tracking-tight leading-tight">
            Se integra con el hardware que ya tienes
          </h2>
          <p className="mt-5 text-lg text-white/60">
            Impresoras térmicas, lectores de código de barras, básculas y más. Sin configuraciones complicadas.
          </p>
        </div>

        {/* Grid de marcas */}
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-4">
          {INTEGRATIONS.map((brand, i) => (
            <div
              key={i}
              className="group relative p-6 rounded-2xl bg-[#1E293B]/40 border border-white/10 hover:border-[#8B5CF6]/40 hover:bg-[#1E293B]/70 transition-all duration-300 hover:-translate-y-1"
            >
              <div className="text-center">
                <div className="text-lg font-extrabold text-white/80 group-hover:text-white transition-colors">
                  {brand.name}
                </div>
                <div className="text-[10px] font-bold uppercase tracking-widest text-white/40 group-hover:text-[#8B5CF6] transition-colors mt-1">
                  {brand.category}
                </div>
              </div>
            </div>
          ))}
        </div>

        <p className="mt-10 text-center text-sm text-white/50">
          ¿Usas otro hardware?{' '}
          <a href="#contact" className="text-[#8B5CF6] hover:text-[#C4B5FD] font-semibold transition-colors">
            Consúltanos →
          </a>
        </p>
      </div>
    </section>
  );
}