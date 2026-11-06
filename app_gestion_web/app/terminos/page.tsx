import Link from 'next/link';
import PageLayout from '../components/PageLayout';

const sections = [
  {
    title: '1. IDENTIFICACIÓN DEL PRESTADOR',
    content: 'El presente contrato es celebrado entre Yan David Camacaro Delgado, titular de la Cédula de Identidad N° V-30.155.457 y RIF personal, con domicilio en Valencia, Estado Carabobo, Venezuela, en adelante "El Prestador" o "JAHTLABS"; y la persona natural o jurídica que contrata el servicio, en adelante "El Cliente".\n\nCorreo de contacto: jahtlabs@gmail.com',
  },
  {
    title: '2. OBJETO Y ACEPTACIÓN',
    content: 'El Prestador otorga al Cliente una licencia de uso no exclusiva, no transferible y revocable sobre el software Boosti POS (en adelante, "El Software").\n\nLa aceptación de estos términos es un requisito obligatorio e indelegable para el uso del Software. Al marcar la casilla de aceptación en la aplicación, el Cliente declara haber leído, entendido y aceptado la totalidad de estas cláusulas.',
  },
  {
    title: '3. LICENCIA DE USO Y PROPIEDAD INTELECTUAL',
    content: '3.1. El Software, su código fuente, diseño, arquitectura, logotipos y documentación son propiedad intelectual exclusiva de JAHTLABS. El Cliente no adquiere ningún derecho de propiedad sobre el código o la marca.\n\n3.2. El Cliente se compromete a no realizar ingeniería inversa, descompilar, modificar, sublicenciar, alquilar o revender el Software sin autorización expresa y por escrito del Prestador.\n\n3.3. Propiedad de los Datos: Todos los datos operativos ingresados por el Cliente (inventario, ventas, clientes, empleados, etc.) son propiedad exclusiva del Cliente. El Prestador no reclama ningún derecho sobre dicha información.',
  },
  {
    title: '4. PLANES, PRECIOS Y FACTURACIÓN',
    content: 'El Software opera bajo un modelo de suscripción (SaaS) y un plan de licencia vitalicia, detallados a continuación:\n\n• Plan Básico: Quince dólares ($15 USD) mensuales. Sujeto a los límites funcionales establecidos en la app.\n• Plan Pro: Treinta dólares ($30 USD) mensuales. Incluye funcionalidades avanzadas y mayor capacidad.\n• Plan Enterprise (Vitalicio): Doscientos veinte dólares ($220 USD) en un pago único. Otorga acceso total e ilimitado, participación como tester en versiones beta, y descuentos en el ecosistema de apps de JAHTLABS.\n\n4.1. Prueba Gratuita (Trial): El Cliente dispone de un período de prueba de quince (15) días. Al finalizar este período, o si no se registra el pago correspondiente, el sistema se bloqueará automáticamente hasta que se regularice la situación.\n\n4.2. Métodos de Pago: El Prestador acepta pagos en Divisas, Pago Móvil y Binance. Los montos y tasas de cambio se regirán por lo estipulado en el momento de la facturación.\n\n4.3. Política de Reembolso: No se realizarán reembolsos por períodos ya facturados o servicios prestados. El Cliente puede cancelar su suscripción en cualquier momento, pero mantendrá acceso hasta el final del ciclo pagado.',
  },
  {
    title: '5. SOPORTE TÉCNICO (SLA)',
    content: 'El Prestador brindará soporte técnico a través de WhatsApp, Telegram y Correo Electrónico.\n\n• Horario de atención: Lunes a Sábado, de 9:00 AM a 5:00 PM (Hora local de Venezuela).\n• Tiempo de respuesta: Hasta cuarenta y ocho (48) horas hábiles.\n\nNo se garantiza la resolución inmediata de incidencias, sino el acuse de recibo y el inicio del diagnóstico dentro del plazo estipulado.',
  },
  {
    title: '6. PRIVACIDAD Y PROTECCIÓN DE DATOS',
    content: '6.1. Aislamiento de Datos: El Software garantiza el aislamiento de la información por cada local (Tenant). El Prestador asegura que los datos de un Cliente no serán accesibles por otros Clientes.\n\n6.2. Rol del Prestador: El Prestador actúa únicamente como proveedor de infraestructura tecnológica y no tiene acceso a los datos operativos del negocio, salvo estrictamente para fines de diagnóstico técnico o soporte, previa autorización del Cliente.\n\n6.3. Sincronización: El Cliente reconoce y acepta que el Software utiliza una arquitectura Offline-First que sincroniza los datos locales con la nube (Supabase) para garantizar la continuidad del servicio.',
  },
  {
    title: '7. OBLIGACIONES Y RESPONSABILIDAD DEL CLIENTE',
    content: 'El Cliente es el único y exclusivo responsable de:\n\n• La legalidad de los datos que ingresa en el Software.\n• El cumplimiento de sus obligaciones fiscales y contables ante el SENIAT u organismos competentes. El Software es una herramienta de gestión y no sustituye la facturación fiscal ni emite documentos fiscales.\n• Mantener la confidencialidad de sus credenciales de acceso y las de su personal.\n• La veracidad de la información ingresada (precios, inventario, datos de clientes).',
  },
  {
    title: '8. LIMITACIÓN DE RESPONSABILIDAD',
    content: '8.1. Exclusión de Garantías: El Software se proporciona "TAL CUAL" y "SEGÚN DISPONIBILIDAD". El Prestador no garantiza que el uso del Software sea ininterrumpido o libre de errores.\n\n8.2. Daños Indirectos: En la máxima medida permitida por la ley venezolana, el Prestador no será responsable por daños indirectos, incidentales, especiales, consecuenciales o punitivos, ni por lucro cesante, pérdida de datos, pérdida de negocios o interrupción de la actividad comercial.\n\n8.3. Límite de Responsabilidad: La responsabilidad total y acumulada del Prestador frente al Cliente por cualquier reclamo derivado de este contrato, no excederá el monto total efectivamente pagado por el Cliente al Prestador durante los doce (12) meses anteriores al evento que dio origen al reclamo. En el caso del Plan Enterprise, el límite será el monto del pago único realizado.\n\n8.4. Fuerza Mayor: El Prestador no será responsable por fallos derivados de cortes de energía eléctrica, fallas en el servicio de internet del Cliente, caídas de servicios de terceros (Supabase, proveedores de nube) o eventos de fuerza mayor.',
  },
  {
    title: '9. MODIFICACIONES Y TERMINACIÓN',
    content: '9.1. El Prestador se reserva el derecho de actualizar estos Términos y Condiciones. Los cambios sustanciales serán notificados con treinta (30) días de anticipación, y el Cliente deberá aceptarlos al próximo inicio de sesión.\n\n9.2. El Prestador podrá suspender el servicio de forma inmediata ante el uso indebido del Software, intentos de hackeo, o falta de pago.',
  },
  {
    title: '10. LEGISLACIÓN APLICABLE Y JURISDICCIÓN',
    content: 'Este contrato se rige por las leyes de la República Bolivariana de Venezuela. Cualquier controversia derivada del presente contrato será resuelta en los tribunales competentes de la ciudad de Valencia, Estado Carabobo.',
  },
];

export default function TerminosPage() {
  return (
    <PageLayout>
      <div className="min-h-screen text-white">
        <main className="max-w-3xl mx-auto px-6 py-32 lg:py-40">
          <div className="text-center mb-12">
            <div className="w-12 h-12 mx-auto rounded-2xl bg-white/5 border border-white/10 flex items-center justify-center mb-6 text-indigo">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="w-6 h-6">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" />
                <polyline points="14 2 14 8 20 8" />
              </svg>
            </div>
            <h1 className="text-4xl sm:text-5xl font-extrabold tracking-tight mb-4">
              Términos y Condiciones de Servicio y EULA — Boosti POS
            </h1>
            <p className="text-white/60">EULA oficial · Última actualización: 5 de noviembre de 2026</p>
          </div>

          <div className="space-y-10 text-white/60 leading-relaxed">
            {sections.map((section) => (
              <section key={section.title}>
                <h2 className="text-xl font-bold text-white mb-3">{section.title}</h2>
                <p className="whitespace-pre-line">{section.content}</p>
              </section>
            ))}
            <p>
              Para consultas, también puede visitar nuestra{' '}
              <Link href="/contacto" className="text-electric hover:text-indigo transition-colors duration-300 ease-in-out">
                página de contacto
              </Link>.
            </p>
          </div>
        </main>
      </div>
    </PageLayout>
  );
}
