import 'package:flutter_test/flutter_test.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog_provider.dart';

void main() {
  group('productoCoincideConFiltroTipo', () {
    final ordinaryProduct = ProductoEntity()..id = 1;
    final ingredient = ProductoEntity()
      ..id = 2
      ..esIngrediente = true;
    final dish = ProductoEntity()..id = 3;
    final productsWithRecipe = {3};

    test('todos includes products, ingredients, and dishes', () {
      expect(
        [
          ordinaryProduct,
          ingredient,
          dish,
        ].every(
          (product) => productoCoincideConFiltroTipo(
            product,
            'todos',
            productsWithRecipe,
          ),
        ),
        isTrue,
      );
    });

    test('productos excludes ingredients and products with recipes', () {
      expect(
        productoCoincideConFiltroTipo(
          ordinaryProduct,
          'productos',
          productsWithRecipe,
        ),
        isTrue,
      );
      expect(
        productoCoincideConFiltroTipo(
          ingredient,
          'productos',
          productsWithRecipe,
        ),
        isFalse,
      );
      expect(
        productoCoincideConFiltroTipo(
          dish,
          'productos',
          productsWithRecipe,
        ),
        isFalse,
      );
    });

    test('platos includes only products with an active recipe', () {
      expect(
        productoCoincideConFiltroTipo(
          ordinaryProduct,
          'platos',
          productsWithRecipe,
        ),
        isFalse,
      );
      expect(
        productoCoincideConFiltroTipo(
          ingredient,
          'platos',
          productsWithRecipe,
        ),
        isFalse,
      );
      expect(
        productoCoincideConFiltroTipo(
          dish,
          'platos',
          productsWithRecipe,
        ),
        isTrue,
      );
    });
  });
}
