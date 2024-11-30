import 'dart:convert';

class Recipe {
  String name;
  Map<String, double> ingredients;
  Map<String, String> units;

  Recipe({required this.name, required this.ingredients, required this.units});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': jsonEncode(
          ingredients), // Convertendo o map para string com aspas duplas
      'units':
          jsonEncode(units), // Convertendo o map para string com aspas duplas
    };
  }

  static Recipe fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      ingredients: Map<String, double>.from(
          jsonDecode(json['ingredients'])), // Convertendo a string para map
      units: Map<String, String>.from(
          jsonDecode(json['units'])), // Convertendo a string para map
    );
  }
}
