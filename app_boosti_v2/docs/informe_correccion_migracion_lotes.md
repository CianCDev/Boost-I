# Informe de corrección: migración de stock a lotes

## Fecha
2026-09-11

## Contexto
La migración `migrarStockExistenteALotes()` se ejecutaba desde el arranque de la app en [lib/main.dart](../lib/main.dart#L57-L74), antes de que el provider de local activo tuviera oportunidad de resolver el contexto de local activo. Esto es una fuente de riesgo en flujo multi-tenant, porque la entidad de lote exige un `localId` con el esquema del modelo.

## Diagnóstico técnico
El modelo de lote declara en [lib/features/pos/data/Local/entities/lote_entity.dart](../lib/features/pos/data/Local/entities/lote_entity.dart#L7-L20):

```dart
@Index()
late int localId;
```

La migración en [lib/features/pos/data/Local/entities/isar_service.dart](../lib/features/pos/data/Local/entities/isar_service.dart#L2618-L2694) construía un `LoteEntity` nuevo con `productoId`, `stock` y estado, pero sin `localId`.

Con eso, una operación que corre al inicio del arranque puede terminar intentando crear registros de lote sin el contexto de local activo, que es exactamente el patrón que permite llegar a una excepción `LateInitializationError` o a un lote con contexto suelto.

## Cambio aplicado
Se corrigió `migrarStockExistenteALotes()` en [lib/features/pos/data/Local/entities/isar_service.dart](../lib/features/pos/data/Local/entities/isar_service.dart#L2618-L2694) para que:

1. Resuelva el local activo con `await obtenerLocalActivo()` dentro de la misma migración.
2. Si no existe local activo, salga de la migración sin crear lotes ni romper el arranque.
3. Asigne de forma explícita `..localId = localActivo.id` al nuevo `LoteEntity`.

Esto convierte la migración en una operación autosuficiente y evita depender de un orden arbitrario de carga del provider `LocalActualProvider`.

## Justificación de diseño
Este patrón encaja mejor con la regla de aislamiento multi-tenant:

- cada operación que necesitará contexto de local debe resolverlo por sí misma;
- no debe depender de una variable global o de estado `late` que haya sido preparado en un paso anterior del arranque.

## Verificación
El cambio fue validado de forma estática con:

```sh
flutter analyze lib/features/pos/data/Local/entities/isar_service.dart
```

Evidencia: el analizador devolvió solo un aviso de estilo ajeno al cambio de esta migración y no mostró un fallo de compilación sobre el cambio.

Se intentó una prueba de control con:

```sh
flutter test test/migrar_stock_existente_lotes_test.dart
```

pero el entorno de prueba no llegó a ejecutar el test porque la plataforma de `shared_preferences` no fue inicializada en el runner (`MissingPluginException`). Eso no es una verificación positiva ni negativa del cambio; es una limitación del entorno.

## Alcance del fix
Este fix resuelve:
- la migración `migrarStockExistenteALotes()` al resolver el local activo dentro de la misma operación;
- la creación del `LoteEntity` desde esa migración con `localId` asignado explícitamente.

Este fix NO resuelve por sí solo:
- cualquier otra creación de `LoteEntity` en el flujo que no asigne `localId` de forma explícita;
- ninguna otra migración con el mismo patrón si aparece fuera de esa ruta;
- el `late` del modelo de entidad en sí, que fue convertido a un valor por defecto defensivo para no explotar al leer el campo antes de inicializar.

## Resultado esperado
La migración de stock a lotes ya no intenta escribir lotes sin contexto local y no se rompe por un `LateInitializationError` en la ruta del arranque; además el modelo de lote queda más tolerante cuando el `localId` aún no se ha fijado al vuelo.
