import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'recipe.dart';

class RecipeModel extends ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  Future<void> add(Recipe recipe) async {
    _recipes.add(recipe);
    await DatabaseHelper().insertRecipe(recipe);
    notifyListeners();
  }

  Future<void> remove(Recipe recipe) async {
    _recipes.remove(recipe);
    notifyListeners();
  }

  Future<void> loadRecipes() async {
    _recipes = await DatabaseHelper().getRecipes();
    notifyListeners();
  }
}
