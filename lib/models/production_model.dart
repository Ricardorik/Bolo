import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'production.dart';
import 'recipe.dart';

class ProductionModel extends ChangeNotifier {
  List<Production> _productions = [];
  List<FinishedProduction> _finishedProductions = [];

  List<Production> get productions => _productions;
  List<FinishedProduction> get finishedProductions => _finishedProductions;

  Future<void> addProduction(Recipe recipe) async {
    final production = Production(
        name: recipe.name,
        ingredients: recipe.ingredients,
        units: recipe.units);
    _productions.add(production);
    // Persistir produções em andamento no banco de dados
    await DatabaseHelper().insertProduction(production);
    notifyListeners();
  }

  Future<void> finalizeProduction(Production production) async {
    _productions.remove(production);
    final finishedProduction = FinishedProduction(
      name: production.name,
      ingredients: production.ingredients,
      units: production.units,
      finishDate: DateTime.now(),
    );
    _finishedProductions.add(finishedProduction);
    await DatabaseHelper().insertFinishedProduction(finishedProduction);
    notifyListeners();
  }

  Future<void> removeProduction(Production production) async {
    _productions.remove(production);
    await DatabaseHelper().deleteProduction(production.name);
    notifyListeners();
  }

  Future<void> loadProductions() async {
    _productions = await DatabaseHelper().getProductions();
    _finishedProductions = await DatabaseHelper().getFinishedProductions();
    notifyListeners();
  }
}
