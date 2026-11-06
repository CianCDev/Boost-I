// lib/features/legal/data/legal_texts.dart
//
// Textos legales de Boosti POS.
//
// Los terminos son el EULA oficial y se muestran en la pantalla de aceptacion.
// Cada cambio de texto obliga a subir `version`: si el usuario ya habia
// aceptado la v1 y el texto cambia a v2, el hash de version deja de coincidir
// y hay que volver a pedir la aceptacion.
//
// NO editar el contenido sin subir la version. Editarlo sin subir la version
// significa que un usuario que ya acepto nunca ve el texto nuevo, y eso es
// exactamente el escenario que un aviso legal tiene que cubrir.

/// Version del documento legal. Incrementar en cada cambio de texto.
const String kLegalVersion = '2026-11-05';

/// Fecha de redaccion del documento.
const String kLegalFecha = '5 de noviembre de 2026';

/// Identidad del prestador.
class LegalIdentidad {
  static const String razonSocial = 'JAHTLABS (Jehova Tech Labs)';
  static const String titular = 'Yan David Camacaro Delgado';
  static const String cargo = 'CEO y Propietario Intelectual';
  static const String ciudad = 'Valencia, Venezuela';
  static const String contacto = '0412-8438195';

  /// Correo de contacto para el ejercicio de derechos.
  /// [REVISAR: confirmar que exista y que alguien lo lea. La LOPDP exige una
  /// via de contacto para el titular.]
  static const String correo = 'camacaroyan@gmail.com';
}

/// Los terminos y condiciones, por seccion.
///
/// Se guardan como lista de pares (titulo, cuerpo) para que la pantalla los
/// pueda numerar y desplegar sin parsear markdown en runtime.
class LegalTerminos {
  static const String titulo = 'Términos y Condiciones de Servicio y EULA';

  static const List<({String titulo, String cuerpo})> secciones = [
    (
      titulo: '1. IDENTIFICACIÓN DEL PRESTADOR',
      cuerpo: 'El presente contrato es celebrado entre Yan David Camacaro '
          'Delgado, titular de la Cédula de Identidad N° V-30.155.457 y RIF '
          'personal, con domicilio en Valencia, Estado Carabobo, Venezuela, '
          'en adelante "El Prestador" o "JAHTLABS"; y la persona natural o '
          'jurídica que contrata el servicio, en adelante "El Cliente".\n\n'
          'Correo de contacto: jahtlabs@gmail.com',
    ),
    (
      titulo: '2. OBJETO Y ACEPTACIÓN',
      cuerpo:
          'El Prestador otorga al Cliente una licencia de uso no exclusiva, '
              'no transferible y revocable sobre el software Boosti POS (en '
              'adelante, "El Software").\n\n'
              'La aceptación de estos términos es un requisito obligatorio e '
              'indelegable para el uso del Software. Al marcar la casilla de '
              'aceptación en la aplicación, el Cliente declara haber leído, '
              'entendido y aceptado la totalidad de estas cláusulas.',
    ),
    (
      titulo: '3. LICENCIA DE USO Y PROPIEDAD INTELECTUAL',
      cuerpo: '3.1. El Software, su código fuente, diseño, arquitectura, '
          'logotipos y documentación son propiedad intelectual exclusiva '
          'de JAHTLABS. El Cliente no adquiere ningún derecho de propiedad '
          'sobre el código o la marca.\n\n'
          '3.2. El Cliente se compromete a no realizar ingeniería inversa, '
          'descompilar, modificar, sublicenciar, alquilar o revender el '
          'Software sin autorización expresa y por escrito del Prestador.\n\n'
          '3.3. Propiedad de los Datos: Todos los datos operativos ingresados '
          'por el Cliente (inventario, ventas, clientes, empleados, etc.) '
          'son propiedad exclusiva del Cliente. El Prestador no reclama '
          'ningún derecho sobre dicha información.',
    ),
    (
      titulo: '4. PLANES, PRECIOS Y FACTURACIÓN',
      cuerpo: 'El Software opera bajo un modelo de suscripción (SaaS) y un plan '
          'de licencia vitalicia, detallados a continuación:\n\n'
          '• Plan Básico: Quince dólares (\$15 USD) mensuales. Sujeto a los '
          'límites funcionales establecidos en la app.\n'
          '• Plan Pro: Treinta dólares (\$30 USD) mensuales. Incluye '
          'funcionalidades avanzadas y mayor capacidad.\n'
          '• Plan Enterprise (Vitalicio): Doscientos veinte dólares '
          '(\$220 USD) en un pago único. Otorga acceso total e ilimitado, '
          'participación como tester en versiones beta, y descuentos en el '
          'ecosistema de apps de JAHTLABS.\n\n'
          '4.1. Prueba Gratuita (Trial): El Cliente dispone de un período de '
          'prueba de quince (15) días. Al finalizar este período, o si no se '
          'registra el pago correspondiente, el sistema se bloqueará '
          'automáticamente hasta que se regularice la situación.\n\n'
          '4.2. Métodos de Pago: El Prestador acepta pagos en Divisas, Pago '
          'Móvil y Binance. Los montos y tasas de cambio se regirán por lo '
          'estipulado en el momento de la facturación.\n\n'
          '4.3. Política de Reembolso: No se realizarán reembolsos por '
          'períodos ya facturados o servicios prestados. El Cliente puede '
          'cancelar su suscripción en cualquier momento, pero mantendrá '
          'acceso hasta el final del ciclo pagado.',
    ),
    (
      titulo: '5. SOPORTE TÉCNICO (SLA)',
      cuerpo: 'El Prestador brindará soporte técnico a través de WhatsApp, '
          'Telegram y Correo Electrónico.\n\n'
          '• Horario de atención: Lunes a Sábado, de 9:00 AM a 5:00 PM '
          '(Hora local de Venezuela).\n'
          '• Tiempo de respuesta: Hasta cuarenta y ocho (48) horas hábiles.\n\n'
          'No se garantiza la resolución inmediata de incidencias, sino el '
          'acuse de recibo y el inicio del diagnóstico dentro del plazo '
          'estipulado.',
    ),
    (
      titulo: '6. PRIVACIDAD Y PROTECCIÓN DE DATOS',
      cuerpo: '6.1. Aislamiento de Datos: El Software garantiza el aislamiento '
          'de la información por cada local (Tenant). El Prestador asegura '
          'que los datos de un Cliente no serán accesibles por otros '
          'Clientes.\n\n'
          '6.2. Rol del Prestador: El Prestador actúa únicamente como '
          'proveedor de infraestructura tecnológica y no tiene acceso a los '
          'datos operativos del negocio, salvo estrictamente para fines de '
          'diagnóstico técnico o soporte, previa autorización del Cliente.\n\n'
          '6.3. Sincronización: El Cliente reconoce y acepta que el Software '
          'utiliza una arquitectura Offline-First que sincroniza los datos '
          'locales con la nube (Supabase) para garantizar la continuidad del '
          'servicio.',
    ),
    (
      titulo: '7. OBLIGACIONES Y RESPONSABILIDAD DEL CLIENTE',
      cuerpo: 'El Cliente es el único y exclusivo responsable de:\n\n'
          '• La legalidad de los datos que ingresa en el Software.\n'
          '• El cumplimiento de sus obligaciones fiscales y contables ante '
          'el SENIAT u organismos competentes. El Software es una herramienta '
          'de gestión y no sustituye la facturación fiscal ni emite '
          'documentos fiscales.\n'
          '• Mantener la confidencialidad de sus credenciales de acceso y '
          'las de su personal.\n'
          '• La veracidad de la información ingresada (precios, inventario, '
          'datos de clientes).',
    ),
    (
      titulo: '8. LIMITACIÓN DE RESPONSABILIDAD',
      cuerpo: '8.1. Exclusión de Garantías: El Software se proporciona "TAL '
          'CUAL" y "SEGÚN DISPONIBILIDAD". El Prestador no garantiza que el '
          'uso del Software sea ininterrumpido o libre de errores.\n\n'
          '8.2. Daños Indirectos: En la máxima medida permitida por la ley '
          'venezolana, el Prestador no será responsable por daños indirectos, '
          'incidentales, especiales, consecuenciales o punitivos, ni por '
          'lucro cesante, pérdida de datos, pérdida de negocios o '
          'interrupción de la actividad comercial.\n\n'
          '8.3. Límite de Responsabilidad: La responsabilidad total y '
          'acumulada del Prestador frente al Cliente por cualquier reclamo '
          'derivado de este contrato, no excederá el monto total '
          'efectivamente pagado por el Cliente al Prestador durante los '
          'doce (12) meses anteriores al evento que dio origen al reclamo. '
          'En el caso del Plan Enterprise, el límite será el monto del pago '
          'único realizado.\n\n'
          '8.4. Fuerza Mayor: El Prestador no será responsable por fallos '
          'derivados de cortes de energía eléctrica, fallas en el servicio '
          'de internet del Cliente, caídas de servicios de terceros '
          '(Supabase, proveedores de nube) o eventos de fuerza mayor.',
    ),
    (
      titulo: '9. MODIFICACIONES Y TERMINACIÓN',
      cuerpo: '9.1. El Prestador se reserva el derecho de actualizar estos '
          'Términos y Condiciones. Los cambios sustanciales serán notificados '
          'con treinta (30) días de anticipación, y el Cliente deberá '
          'aceptarlos al próximo inicio de sesión.\n\n'
          '9.2. El Prestador podrá suspender el servicio de forma inmediata '
          'ante el uso indebido del Software, intentos de hackeo, o falta '
          'de pago.',
    ),
    (
      titulo: '10. LEGISLACIÓN APLICABLE Y JURISDICCIÓN',
      cuerpo: 'Este contrato se rige por las leyes de la República Bolivariana '
          'de Venezuela. Cualquier controversia derivada del presente '
          'contrato será resuelta en los tribunales competentes de la ciudad '
          'de Valencia, Estado Carabobo.',
    ),
  ];
}

/// La politica de privacidad, por seccion.
class LegalPrivacidad {
  static const String titulo = 'Politica de Privacidad';

  static const List<({String titulo, String cuerpo})> secciones = [
    (
      titulo: '1. Responsable del tratamiento',
      cuerpo: 'JAHTLABS (Jehova Tech Labs), titular de Boosti POS, es el '
          'responsable del tratamiento de los datos personales que el '
          'Cliente introduce en el sistema. Contacto: ${LegalIdentidad.razonSocial}, '
          'titular ${LegalIdentidad.titular}, correo ${LegalIdentidad.correo}.',
    ),
    (
      titulo: '2. Que datos se tratan',
      cuerpo: 'Ventas, productos, existencias, clientes, proveedores, gastos, '
          'empleados y usuarios del negocio. Los datos de clientes incluyen '
          'nombre, documento de identidad, direccion, telefono y correo '
          'electronico. Los datos de empleados incluyen documento de '
          'identidad, cargo y registro de operacones.',
    ),
    (
      titulo: '3. Para que se usan',
      cuerpo: 'Unicamente para prestar el servicio contratado: registrar '
          'operaciones, mantener el inventario, emitir reportes y gestionar '
          'la relacion comercial. No se usan los datos con fines publicitarios '
          'ni se ceden a terceros con fines distintos de los aqui '
          'senalados en esta politica.',
    ),
    (
      titulo: '4. Donde se almacenan',
      cuerpo: 'En un servidor en la nube bajo control de JAHTLABS, y en el '
          'dispositivo del Cliente. Los datos del Cliente estan separados de '
          'los de otros clientes por mecanismos de aislamiento a nivel de '
          'base de datos. JAHTLABS no accede a los datos operativos del '
          'Cliente.',
    ),
    (
      titulo: '5. Terceros que intervienen',
      cuerpo: 'Con el fin de prestar el servicio se utilizan los siguientes '
          'terceros, que reciben unicamente la informacion minima necesaria '
          'para su funcion: '
          '(a) un proveedor de almacenamiento en la nube, que aloja la base '
          'de datos; '
          '(b) Sentry (sentry.io), que recibe datos tecnicos de error segun '
          'lo descrito en la seccion 6; '
          '(c) Shorebird, que distribuye las actualizaciones de la '
          'aplicacion y recibe un identificador de instalacion anonimo, sin '
          'relacion con el usuario. '
          '[REVISAR: confirmar el nombre y la ubicacion del proveedor de '
          'nube, que en este documento esta escrito de forma generica]',
    ),
    (
      titulo: '6. Datos que salen del dispositivo del Cliente',
      cuerpo: 'La aplicacion envia datos tecnicos de error de forma automatica '
          'para mejorar el servicio. Antes de salir del dispositivo se elimina '
          'la informacion que permite identificar a una persona: documentos '
          'de identidad, correos, telefonos y credenciales. El Cliente puede '
          'desactivar este envio en los ajustes del dispositivo.',
    ),
    (
      titulo: '7. Plazo de conservacion',
      cuerpo: 'Los datos del Cliente se conservan mientras la suscripcion este '
          'activa y por el plazo que JAHTLABS considere necesario para '
          'cumplir obligaciones legales y tributarias. [REVISAR: definir el '
          'plazo concreto en anos y el procedimiento de eliminacion o '
          'an anonimizacion al vencer]',
    ),
    (
      titulo: '8. Seguridad',
      cuerpo:
          'El acceso a los datos del Cliente se controla por rol: cada usuario '
              'accede unicamente a lo que su puesto permite. Los registros de '
              'operaciones no pueden modificarse ni eliminarse una vez '
              'confirmados. Las credenciales de la aplicacion no se almacenan en '
              'el codigo del producto.',
    ),
    (
      titulo: '9. Derechos del titular',
      cuerpo: 'El titular de los datos puede solicitar a JAHTLABS el acceso, la '
          'rectificacion, la eliminacion, el acceso a la informacion y la '
          'oposicion al tratamiento, conforme a la LOPDP. La solicitud se '
          'atiende por correo electronico y se responde dentro del plazo '
          'legal. El Cliente es responsable de atender las solicitudes de sus '
          'propios clientes.',
    ),
    (
      titulo: '10. Cambios en esta politica',
      cuerpo: 'Si esta politica cambia de forma sustancial, se mostrara en la '
          'pantalla de aceptacion y el Cliente debera aceptarla antes de '
          'seguir usando el sistema.',
    ),
  ];
}
