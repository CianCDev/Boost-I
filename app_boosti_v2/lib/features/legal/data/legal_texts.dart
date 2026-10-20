// lib/features/legal/data/legal_texts.dart
//
// Textos legales de Boosti POS.
//
// Son la version que se muestra en la pantalla de aceptacion del registro.
// Cada cambio de texto obliga a subir `version`: si el usuario ya habia
// aceptado la v1 y el texto cambia a v2, el hash de version deja de coincidir
// y hay que volver a pedir la aceptacion.
//
// NO editar el contenido sin subir la version. Editarlo sin subir la version
// significa que un usuario que ya acepto nunca ve el texto nuevo, y eso es
// exactamente el escenario que un aviso legal tiene que cubrir.
//
// Los marcadores [REVISAR: ...] son puntos que un abogado debe validar antes
// de publicar. No son texto para el usuario final.

/// Version del documento legal. Incrementar en cada cambio de texto.
const String kLegalVersion = '2026-10-18';

/// Fecha de redaccion del documento.
const String kLegalFecha = '18 de octubre de 2026';

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
  static const String titulo = 'Terminos y Condiciones';

  static const List<({String titulo, String cuerpo})> secciones = [
    (
      titulo: '1. Objeto',
      cuerpo:
          'Boosti POS es un sistema de punto de venta y gestion de negocios '
          'que el Cliente instala en su dispositivo y opera. Este contrato '
          'regula el acceso al sistema, la suscripcion al plan contratado y '
          'el tratamiento de los datos que el Cliente introduce en el '
          'sistema. La suscripcion es de caracter mensual, Renovandose por '
          'periodos iguales salvo que el Cliente solicite su cancelacion.',
    ),
    (
      titulo: '2. Requisitos tecnicos',
      cuerpo:
          'Boosti POS opera en tablets, telefonos yomina equipos con Android '
          'o Windows. El Cliente es responsable de mantener actualizado su '
          'equipo y de procurar una conexion estable. El sistema funciona sin '
          'internet y sincroniza de forma automatica cuando la conexion se '
          'restablece.',
    ),
    (
      titulo: '3. Alcance del servicio',
      cuerpo:
          'La suscripcion incluye el acceso completo a los modulos habilitados '
          'en el plan contratado. No se venden modulos de forma individual. '
          'Las funciones disponibles dependen del plan y del modo de negocio '
          'configurado (mercado o restaurante).',
    ),
    (
      titulo: '4. Precios y forma de pago',
      cuerpo:
          'El precio del plan es mensual y se factura por adelantado. No hay '
          'cuota de instalacion ni de puesta en marcha: la suscripcion es el '
          'unico concepto obligatorio. El Cliente acepta que el precio del '
          'plan es el indicado en la propuesta comercial vigente al momento '
          'de la suscripcion. [REVISAR:(indexar aqui el precio de cada plan y '
          'la politica de ajustes de precio con aviso previo]',
    ),
    (
      titulo: '5. Obligaciones del Cliente',
      cuerpo:
          'El Cliente se obliga a: mantener confidenciales sus credenciales y '
          'su PIN de acceso; no compartir un mismo usuario entre varias '
          'personas; utilizar el sistema dentro de la ley aplicable; y no '
          'utilizar el sistema para registrar operaciones ficticias. El '
          'incumplimiento de estas obligaciones faculta al prestador a '
          'suspender el servicio previo aviso.',
    ),
    (
      titulo: '6. Propiedad intelectual',
      cuerpo:
          'El codigo fuente, el diseño, la marca y los activos de Boosti POS '
          'son propiedad de JAHTLABS. El Cliente obtiene una licencia de uso '
          'no exclusiva, no transferible y limitada al periodo contratado. '
          'Los datos que el Cliente introduce en el sistema son de propiedad '
          'exclusiva del Cliente.',
    ),
    (
      titulo: '7. Limitacion de responsabilidad',
      cuerpo:
          'En la maxima medida permitida por la ley, JAHTLABS no responde por '
          'perdidas de lucro, lucro cesante, perdida de datos o danos '
          'indirectos derivados del uso o la imposibilidad de uso del '
          'sistema. La responsabilidad total de JAHTLABS por cualquier '
          'reclamacion se limita al monto efectivamente pagado por el '
          'Cliente en los tres meses anteriores al hecho que dio origen a la '
          'reclamacion. [REVISAR: este limite debe validarse contra la '
          'normativa vigente y contra la practica del sector]',
    ),
    (
      titulo: '8. Disponibilidad y soporte',
      cuerpo:
          'El soporte tecnico operativo se incluye en la mensualidad. El '
          'Cliente reconoce que el sistema puede requerir actualizaciones y '
          'mantenimiento programados. [REVISAR: definir un nivel de servicio '
          'concreto (horas de respuesta, horario, dias habiles) y su '
          'relacion con el plan contratado]',
    ),
    (
      titulo: '9. Cancelacion',
      cuerpo:
          'El Cliente puede cancelar en cualquier momento, sin multa ni '
          'compromiso de permanencia. La cancelacion surte efecto al cierre '
          'del periodo mensual en curso. El Cliente conserva el derecho a '
          'exportar sus datos antes de la cancelacion. JAHTLABS conserva los '
          'datos del Cliente por el plazo que establece la seccion 10.',
    ),
    (
      titulo: '10. Proteccion de datos',
      cuerpo:
          'El tratamiento de los datos personales del Cliente se rige por la '
          'Ley Organica de Proteccion de Datos Personales (LOPDP) y por la '
          'politica de privacidad que el Cliente acepta simultaneamente con '
          'estos terminos. Esa politica forma parte integra de este '
          'contrato.',
    ),
    (
      titulo: '11. Confidencialidad',
      cuerpo:
          'Cada parte se obliga a mantener confidencial la informacion a la '
          'que tenga acceso con motivo de este contrato y a no divulgarla a '
          'terceros, salvo obligacion legal o requerimiento de autoridad '
          'competente.',
    ),
    (
      titulo: '12. Legislacion aplicable',
      cuerpo:
          'Este contrato se rige por las leyes de la Republica '
          'Bolivariana de Venezuela. Las partes se someten a la '
          'jurisdiccion de los tribunales competentes de la ciudad de '
          'Valencia, estado Carabobo. [REVISAR: confirmar la jurisdiccion y '
          'la clausula arbitral si se prefiere arbitraje]',
    ),
  ];
}

/// La politica de privacidad, por seccion.
class LegalPrivacidad {
  static const String titulo = 'Politica de Privacidad';

  static const List<({String titulo, String cuerpo})> secciones = [
    (
      titulo: '1. Responsable del tratamiento',
      cuerpo:
          'JAHTLABS (Jehova Tech Labs), titular de Boosti POS, es el '
          'responsable del tratamiento de los datos personales que el '
          'Cliente introduce en el sistema. Contacto: ${LegalIdentidad.razonSocial}, '
          'titular ${LegalIdentidad.titular}, correo ${LegalIdentidad.correo}.',
    ),
    (
      titulo: '2. Que datos se tratan',
      cuerpo:
          'Ventas, productos, existencias, clientes, proveedores, gastos, '
          'empleados y usuarios del negocio. Los datos de clientes incluyen '
          'nombre, documento de identidad, direccion, telefono y correo '
          'electronico. Los datos de empleados incluyen documento de '
          'identidad, cargo y registro de operacones.',
    ),
    (
      titulo: '3. Para que se usan',
      cuerpo:
          'Unicamente para prestar el servicio contratado: registrar '
          'operaciones, mantener el inventario, emitir reportes y gestionar '
          'la relacion comercial. No se usan los datos con fines publicitarios '
          'ni se ceden a terceros con fines distintos de los aqui '
          'senalados en esta politica.',
    ),
    (
      titulo: '4. Donde se almacenan',
      cuerpo:
          'En un servidor en la nube bajo control de JAHTLABS, y en el '
          'dispositivo del Cliente. Los datos del Cliente estan separados de '
          'los de otros clientes por mecanismos de aislamiento a nivel de '
          'base de datos. JAHTLABS no accede a los datos operativos del '
          'Cliente.',
    ),
    (
      titulo: '5. Terceros que intervienen',
      cuerpo:
          'Con el fin de prestar el servicio se utilizan los siguientes '
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
      cuerpo:
          'La aplicacion envia datos tecnicos de error de forma automatica '
          'para mejorar el servicio. Antes de salir del dispositivo se elimina '
          'la informacion que permite identificar a una persona: documentos '
          'de identidad, correos, telefonos y credenciales. El Cliente puede '
          'desactivar este envio en los ajustes del dispositivo.',
    ),
    (
      titulo: '7. Plazo de conservacion',
      cuerpo:
          'Los datos del Cliente se conservan mientras la suscripcion este '
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
      cuerpo:
          'El titular de los datos puede solicitar a JAHTLABS el acceso, la '
          'rectificacion, la eliminacion, el acceso a la informacion y la '
          'oposicion al tratamiento, conforme a la LOPDP. La solicitud se '
          'atiende por correo electronico y se responde dentro del plazo '
          'legal. El Cliente es responsable de atender las solicitudes de sus '
          'propios clientes.',
    ),
    (
      titulo: '10. Cambios en esta politica',
      cuerpo:
          'Si esta politica cambia de forma sustancial, se mostrara en la '
          'pantalla de aceptacion y el Cliente debera aceptarla antes de '
          'seguir usando el sistema.',
    ),
  ];
}