import Link from 'next/link';
import PageLayout from '../components/PageLayout';

export default function BlogPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-indigo/15 text-[#C4B5FD] text-xs font-semibold border border-indigo/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-lilac animate-pulse" />
            Blog
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Blog de BoostI
          </h1>
          <p className="text-lg text-white/60 leading-relaxed mb-10 max-w-2xl mx-auto">
            Tips, novedades y mejores prácticas para gestionar tu negocio.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              title: 'Cómo reducir los tiempos de espera en caja',
              desc: 'Técnicas prácticas para agilizar el cobro y mejorar la experiencia de tus clientes.',
              date: 'Nov 03, 2026',
            },
            {
              title: 'Control de inventario por lotes',
              desc: 'Cómo gestionar vencimientos y evitar pérdidas de stock en tu comercio.',
              date: 'Oct 28, 2026',
            },
            {
              title: 'Ventas al por mayor con BoostI POS',
              desc: 'Configura precios por volumen y distribuye eficientemente a tus clientes mayoristas.',
              date: 'Oct 20, 2026',
            },
          ].map((post, i) => (
            <div key={i} className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10 hover:border-electric/40 transition-all duration-300 ease-in-out group">
              <div className="text-xs text-muted mb-3 uppercase tracking-wider font-medium">{post.date}</div>
              <h3 className="text-xl font-bold text-white mb-3 group-hover:text-electric transition-colors">{post.title}</h3>
              <p className="text-white/60 text-sm leading-relaxed mb-6">{post.desc}</p>
              <Link href="#" className="inline-flex items-center gap-1 text-sm font-semibold text-electric hover:underline">
                Leer más →
              </Link>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
