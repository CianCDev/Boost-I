import PageLayout from '../components/PageLayout';

export default function PrivacidadPage() {
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
            Política de Privacidad
          </h1>
          <p className="text-white/60">Última actualización: Noviembre 2026</p>
        </div>

        <div className="prose lg:prose-xl text-white/70 leading-relaxed space-y-6">
          <h2 className="text-xl font-bold text-white">1. Información que recopilamos</h2>
          <p className="text-white/60">
            Recopilamos información necesaria para proporcionar el servicio,
            como nombre de usuario, correo electrónico y datos del negocio.
          </p>

          <h2 className="text-xl font-bold text-white">2. Uso de la información</h2>
          <p className="text-white/60">
            Usamos tus datos para operar, mejorar y personalizar tu experiencia
            con BoostI POS.
          </p>

          <h2 className="text-xl font-bold text-white">3. Seguridad</h2>
          <p className="text-white/60">
            Implementamos medidas de seguridad para proteger tu información
            contra accesos no autorizados.
          </p>

          <h2 className="text-xl font-bold text-white">4. Compartir información</h2>
          <p className="text-white/60">
            No vendemos ni compartimos tus datos personales con terceros.
          </p>

          <h2 className="text-xl font-bold text-white">5. Tus derechos</h2>
          <p className="text-white/60">
            Puedes acceder, corregir o eliminar tus datos en cualquier momento.
          </p>

          <p className="mt-8 text-white/50 text-sm">
            ¿Preguntas? Contáctanos en <a href="mailto:privacidad@boostipos.com" className="text-electric hover:underline">privacidad@boostipos.com</a>
          </p>
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
