import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:big_bolos/models/recipe.dart';
import 'package:big_bolos/models/recipe_model.dart';

class RecipeFormScreen extends StatefulWidget {
  @override
  _RecipeFormScreenState createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _ingredientControllers = [
    TextEditingController()
  ];
  final List<TextEditingController> _quantityControllers = [
    TextEditingController()
  ];
  final List<String> _selectedUnits = ['grama'];

  final List<String> _units = ['ml', 'litro', 'grama', 'unidade'];

  void _addIngredientField() {
    setState(() {
      _ingredientControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController());
      _selectedUnits.add(_units[0]);
    });
  }

  void _removeIngredientField(int index) {
    setState(() {
      _ingredientControllers.removeAt(index);
      _quantityControllers.removeAt(index);
      _selectedUnits.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova Receita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome do Bolo'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _ingredientControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ingredientControllers[index],
                          decoration: InputDecoration(labelText: 'Ingrediente'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _quantityControllers[index],
                          decoration: InputDecoration(labelText: 'Quantidade'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnits[index],
                          onChanged: (newValue) {
                            setState(() {
                              _selectedUnits[index] = newValue!;
                            });
                          },
                          items: _units.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          decoration: InputDecoration(labelText: 'Unidade'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => _removeIngredientField(index),
                      ),
                    ],
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _addIngredientField,
              child: Text('Adicionar Ingrediente'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _ingredientControllers
                        .every((controller) => controller.text.isNotEmpty) &&
                    _quantityControllers
                        .every((controller) => controller.text.isNotEmpty)) {
                  final String name = _nameController.text;
                  final Map<String, double> ingredients = {};
                  final Map<String, String> units = {};
                  for (int i = 0; i < _ingredientControllers.length; i++) {
                    final ingredientName = _ingredientControllers[i].text;
                    final quantity = double.parse(_quantityControllers[i].text);
                    final unit = _selectedUnits[i];
                    ingredients[ingredientName] = quantity;
                    units[ingredientName] = unit;
                  }

                  final recipe = Recipe(
                      name: name, ingredients: ingredients, units: units);
                  Provider.of<RecipeModel>(context, listen: false).add(recipe);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Preencha todos os campos')),
                  );
                }
              },
              child: Text('Salvar Receita'),
            ),
          ],
        ),
      ),
    );
  }
}
