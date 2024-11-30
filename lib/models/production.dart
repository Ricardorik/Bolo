import 'dart:convert';

class Production {
  String name;
  Map<String, double> ingredients;
  Map<String, String> units;

  Production(
      {required this.name, required this.ingredients, required this.units});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ingredients': jsonEncode(ingredients),
      'units': jsonEncode(units),
    };
  }

  static Production fromJson(Map<String, dynamic> json) {
    return Production(
      name: json['name'],
      ingredients: Map<String, double>.from(jsonDecode(json['ingredients'])),
      units: Map<String, String>.from(jsonDecode(json['units'])),
    );
  }
}

class FinishedProduction extends Production {
  DateTime finishDate;

  FinishedProduction({
    required String name,
    required Map<String, double> ingredients,
    required Map<String, String> units,
    required this.finishDate,
  }) : super(name: name, ingredients: ingredients, units: units);

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['finishDate'] = finishDate.toIso8601String();
    return data;
  }

  static FinishedProduction fromJson(Map<String, dynamic> json) {
    return FinishedProduction(
      name: json['name'],
      ingredients: Map<String, double>.from(jsonDecode(json['ingredients'])),
      units: Map<String, String>.from(jsonDecode(json['units'])),
      finishDate: DateTime.parse(json['finishDate']),
    );
  }
}
