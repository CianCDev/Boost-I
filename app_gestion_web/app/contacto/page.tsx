'use client';

import PageLayout from '../components/PageLayout';

export default function ContactoPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-4xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-electric/15 text-lilac text-xs font-semibold border border-electric/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-electric animate-pulse" />
            Contacto
          </div>
          <h1 className="text-5xl sm:text-6xl font-extrabold tracking-tight mb-6">
            Contáctanos
          </h1>
          <p className="text-lg text-white/60 leading-relaxed mb-10 max-w-2xl mx-auto">
            ¿Tienes preguntas? Estamos aquí para ayudarte. Escríbenos y te responderemos a la brevedad.
          </p>
        </div>

        <div className="grid md:grid-cols-2 gap-12">
          <div className="space-y-6">
            <div className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10 flex items-start gap-4">
              <div className="w-12 h-12 rounded-2xl bg-electric/20 flex items-center justify-center shrink-0 text-electric">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                </svg>
              </div>
              <div>
                <h4 className="text-white font-bold">Teléfono</h4>
                <p className="text-white/60">+58 212-555-0199</p>
              </div>
            </div>
            <div className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10 flex items-start gap-4">
              <div className="w-12 h-12 rounded-2xl bg-electric/20 flex items-center justify-center shrink-0 text-electric">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                  <polyline points="22,6 12,13 2,6" />
                </svg>
              </div>
              <div>
                <h4 className="text-white font-bold">Correo electrónico</h4>
                <a className="text-white/60 hover:text-mint transition-colors duration-300 ease-in-out" href="mailto:jahtlabs@gmail.com">
                  jahtlabs@gmail.com
                </a>
              </div>
            </div>
          </div>
          <div className="p-8 rounded-3xl bg-deep-slate/50 border border-white/10">
            <h3 className="text-xl font-bold text-white mb-6">Envíanos un mensaje</h3>
            <form className="space-y-4" onSubmit={(e) => e.preventDefault()}>
              <div>
                <label className="block text-sm font-medium text-white mb-1">Nombre</label>
                <input type="text" className="w-full px-4 py-3 rounded-xl bg-white/[0.05] border border-white/10 text-white placeholder-white/30 focus:border-electric focus:outline-none transition-colors" placeholder="Tu nombre" />
              </div>
              <div>
                <label className="block text-sm font-medium text-white mb-1">Correo electrónico</label>
                <input type="email" className="w-full px-4 py-3 rounded-xl bg-white/[0.05] border border-white/10 text-white placeholder-white/30 focus:border-electric focus:outline-none transition-colors" placeholder="tu@correo.com" />
              </div>
              <div>
                <label className="block text-sm font-medium text-white mb-1">Mensaje</label>
                <textarea rows={4} className="w-full px-4 py-3 rounded-xl bg-white/[0.05] border border-white/10 text-white placeholder-white/30 focus:border-electric focus:outline-none transition-colors" placeholder="Cuéntanos cómo podemos ayudarte"></textarea>
              </div>
              <button type="submit" className="w-full px-6 py-3.5 rounded-xl bg-linear-to-r from-electric to-indigo text-white font-semibold hover:opacity-90 transition-all duration-300 ease-in-out">
                Enviar mensaje
              </button>
            </form>
          </div>
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
