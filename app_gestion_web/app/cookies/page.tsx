import PageLayout from '../components/PageLayout';

export default function CookiesPage() {
  return (
    <PageLayout>
    <div className="min-h-screen text-white">
      <main className="max-w-3xl mx-auto px-6 py-32 lg:py-40">
        <div className="text-center mb-12">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-indigo/15 text-[#C4B5FD] text-xs font-semibold border border-indigo/30 mb-6">
            <span className="w-2 h-2 rounded-full bg-lilac animate-pulse" />
            Legal
          </div>
          <h1 className="text-4xl sm:text-5xl font-extrabold tracking-tight mb-4">
            Política de Cookies
          </h1>
          <p className="text-white/60">Última actualización: Noviembre 2026</p>
        </div>

        <div className="prose lg:prose-xl text-white/70 leading-relaxed space-y-6">
          <h2 className="text-xl font-bold text-white">1. ¿Qué son las cookies?</h2>
          <p className="text-white/60">
            Las cookies son pequeños archivos de texto que se almacenan en tu
            dispositivo cuando visitas nuestro sitio web.
          </p>

          <h2 className="text-xl font-bold text-white">2. Tipos de cookies que usamos</h2>
          <ul className="list-disc list-inside text-white/60 space-y-3">
            <li><strong>Cookies esenciales:</strong> Necesarias para el funcionamiento del sitio.</li>
            <li><strong>Cookies de rendimiento:</strong> Nos ayudan a analizar el uso del sitio.</li>
            <li><strong>Cookies funcionales:</strong> Permiten recordar tus preferencias.</li>
          </ul>

          <h2 className="text-xl font-bold text-white">3. Gestión de cookies</h2>
          <p className="text-white/60">
            Puedes configurar tu navegador para aceptar o rechazar cookies.
          </p>

          <h2 className="text-xl font-bold text-white">4. Cookies de terceros</h2>
          <p className="text-white/60">
            Podemos usar servicios de terceros que instalan cookies en tu dispositivo.
          </p>

          <p className="mt-8 text-white/50 text-sm">
            ¿Preguntas? Contáctanos en <a href="mailto:cookies@boostipos.com" className="text-electric hover:underline">cookies@boostipos.com</a>
          </p>
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
