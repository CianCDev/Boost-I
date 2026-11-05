import PageLayout from '../components/PageLayout';

export default function TrabajaConNosotrosPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center mb-12">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-lilac/15 text-[#C4B5FD] text-xs font-semibold border border-lilac/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-lilac animate-pulse" />
            Empleo
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Trabaja con nosotros
          </h1>
          <p className="text-lg text-white/60 leading-relaxed max-w-2xl mx-auto">
            Únete al equipo de BoostI y ayuda a transformar el comercio del país.
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          {[
            { title: 'Desarrollador Frontend', desc: 'React, Next.js, Tailwind. Remoto.' },
            { title: 'Desarrollador Backend', desc: 'Node.js, Supabase, APIs REST.' },
            { title: 'Soporte Técnico', desc: 'Atención a clientes y resolución de problemas.' },
            { title: 'Diseñador UX/UI', desc: 'Diseño de interfaces para aplicaciones web y móvil.' },
            { title: 'Comercial', desc: 'Ventas y expansión de BoostI POS en el país.' },
            { title: 'QA Tester', desc: 'Pruebas de calidad y aseguramiento de software.' },
          ].map((job, i) => (
            <div key={i} className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10 hover:border-electric/40 transition-all duration-300 ease-in-out group">
              <h4 className="text-lg font-bold text-white mb-2 group-hover:text-electric transition-colors">{job.title}</h4>
              <p className="text-white/60 text-sm">{job.desc}</p>
              <button className="mt-4 text-sm text-electric font-medium hover:underline">
                Aplicar →
              </button>
            </div>
          ))}
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
