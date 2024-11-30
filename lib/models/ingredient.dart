import 'package:flutter/foundation.dart';

class Ingredient {
  final String name;
  double quantity;
  final String unit;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });
}

class IngredientModel extends ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;

  void add(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  void remove(Ingredient ingredient) {
    _ingredients.remove(ingredient);
    notifyListeners();
  }
}
