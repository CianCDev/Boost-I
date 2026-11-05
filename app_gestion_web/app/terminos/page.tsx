import Link from 'next/link';
import PageLayout from '../components/PageLayout';

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
            Términos y Condiciones de BoostI POS
          </h1>
          <p className="text-white/60">Última actualización: Noviembre 2026</p>
        </div>

        <div className="space-y-10 text-white/60 leading-relaxed">
          {/* 1 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">1. Aceptación de los Términos</h2>
            <p>
              Al crear una cuenta y utilizar BoostI POS (el &quot;Servicio&quot;), operado por JAH Lab (la
              &quot;Compañía&quot;), usted acepta cumplir y estar sujeto a estos Términos y Condiciones. Si no está
              de acuerdo con alguna parte de estos términos, no debe utilizar el Servicio.
            </p>
          </section>

          {/* 2 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">2. Cuentas de Usuario</h2>
            <p>
              Para acceder a la mayoría de las funciones del Servicio, debe registrar una cuenta. Usted es
              responsable de mantener la confidencialidad de su cuenta y contraseña, y acepta la
              responsabilidad de todas las actividades que ocurran bajo su cuenta. Usted se compromete a
              proporcionar información precisa, completa y actualizada.
            </p>
          </section>

          {/* 3 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">3. Contenido del Usuario</h2>
            <p>
              Nuestro Servicio le permite publicar, cargar y almacenar información (como datos de inventario,
              ventas, imágenes de productos, etc.). Usted conserva todos sus derechos sobre dicho contenido. Al
              cargar contenido, nos otorga una licencia mundial, no exclusiva y libre de regalías para alojar,
              usar y mostrar dicho contenido con el único fin de operar y mejorar el Servicio.
            </p>
          </section>

          {/* 4 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">4. Suscripciones, Pagos y Compras</h2>
            <ul className="space-y-4 mt-3">
              <li>
                <strong className="text-white">Suscripciones:</strong> Ofrecemos planes de suscripción
                recurrentes. Al suscribirse, acepta pagar las tarifas aplicables según el plan seleccionado
                (mensual o anual). Los pagos son no reembolsables, salvo que la ley aplicable exija lo
                contrario.
              </li>
              <li>
                <strong className="text-white">Compras y Productos:</strong> El Servicio permite a los usuarios
                realizar compras únicas de bienes o servicios. Las transacciones se procesan de forma segura, y
                el usuario es responsable de proporcionar métodos de pago válidos.
              </li>
              <li>
                <strong className="text-white">Compras dentro de la App:</strong> Cualquier compra de funciones
                adicionales o módulos dentro de la aplicación está sujeta a estos mismos términos.
              </li>
              <li>
                <strong className="text-white">Prueba Gratuita:</strong> Podemos ofrecer períodos de prueba. Al
                finalizar el período de prueba, se le cobrará automáticamente la tarifa de suscripción a menos
                que cancele antes.
              </li>
            </ul>
          </section>

          {/* 5 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">5. Propiedad Intelectual</h2>
            <p>
              El Servicio y su contenido original (excluyendo el contenido que usted proporcione), las
              características y la funcionalidad son y seguirán siendo propiedad exclusiva de JAH Lab y BoostI
              POS. Nuestras marcas comerciales, logotipos y diseño visual no pueden ser copiados, imitados o
              utilizados sin nuestro permiso previo por escrito.
            </p>
          </section>

          {/* 6 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">6. Comentarios y Sugerencias</h2>
            <p>
              Si nos proporciona comentarios, sugerencias o ideas (Feedback), usted acepta que podemos
              utilizarlos sin compensación o crédito hacia usted. Nos reservamos el derecho de implementar
              cualquier feedback que consideremos útil para mejorar el Servicio.
            </p>
          </section>

          {/* 7 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">7. Promociones y Concursos</h2>
            <p>
              Ocasionalmente, podemos ofrecer promociones, concursos o sorteos. Todos estos estarán regidos por
              reglas específicas que se le proporcionarán en el momento de la promoción, las cuales se
              consideran parte de estos Términos.
            </p>
          </section>

          {/* 8 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">8. Limitación de Responsabilidad</h2>
            <p>
              En ningún caso JAH Lab, ni sus directores, empleados o socios, serán responsables de daños
              indirectos, incidentales, especiales o consecuentes derivados del uso o la imposibilidad de usar
              el Servicio (incluyendo, sin limitación, pérdida de datos o ganancias).
            </p>
          </section>

          {/* 9 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">9. Modificaciones</h2>
            <p>
              Nos reservamos el derecho de modificar o reemplazar estos Términos en cualquier momento. Si los
              cambios son importantes, le notificaremos con al menos 30 días de antelación antes de que los
              nuevos términos entren en vigencia.
            </p>
          </section>

          {/* 10 */}
          <section>
            <h2 className="text-xl font-bold text-white mb-3">10. Contacto</h2>
            <p className="mb-3">Si tiene alguna pregunta sobre estos Términos y Condiciones, puede contactarnos:</p>
            <ul className="space-y-2">
              <li>
                Por correo electrónico:{' '}
                <a href="mailto:jahtlabs@gmail.com" className="text-electric hover:text-indigo transition-colors duration-300 ease-in-out">
                  jahtlabs@gmail.com
                </a>
              </li>
              <li>
                A través de nuestro sitio web:{' '}
                <Link href="/contacto" className="text-electric hover:text-indigo transition-colors duration-300 ease-in-out">
                  Página de contacto
                </Link>{' '}
                en boostipos.com
              </li>
            </ul>
          </section>
        </div>
      </main>
    </div>
    </PageLayout>
  );
}
