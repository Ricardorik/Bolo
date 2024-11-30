import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:big_bolos/models/ingredient.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final List<String> _units = ['ml', 'litro', 'grama', 'unidade'];
  String _selectedUnit = 'grama'; // Unidade inicial

  @override
  Widget build(BuildContext context) {
    final ingredientModel = Provider.of<IngredientModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Controle de Estoque',
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
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return ingredientModel.ingredients
                    .where((ingredient) => ingredient.name
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()))
                    .map((ingredient) => ingredient.name);
              },
              onSelected: (String selection) {
                _nameController.text = selection;
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: _nameController,
                  focusNode: fieldFocusNode,
                  decoration: InputDecoration(labelText: 'Nome do Ingrediente'),
                );
              },
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantidade'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              onChanged: (newValue) {
                setState(() {
                  _selectedUnit = newValue!;
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
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _quantityController.text.isNotEmpty &&
                    _selectedUnit.isNotEmpty) {
                  final String name = _nameController.text;
                  final double quantity =
                      double.parse(_quantityController.text);
                  final String unit = _selectedUnit;
                  final ingredient =
                      Ingredient(name: name, quantity: quantity, unit: unit);

                  Provider.of<IngredientModel>(context, listen: false)
                      .add(ingredient);
                  _nameController.clear();
                  _quantityController.clear();
                  setState(() {
                    _selectedUnit = 'grama';
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Preencha todos os campos')),
                  );
                }
              },
              child: Text('Adicionar ao Estoque'),
            ),
            Expanded(
              child: Consumer<IngredientModel>(
                builder: (context, ingredientModel, child) {
                  return ListView.builder(
                    itemCount: ingredientModel.ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredientModel.ingredients[index];
                      return ListTile(
                        title: Text(ingredient.name),
                        subtitle: Text(
                            'Quantidade: ${ingredient.quantity} ${ingredient.unit}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
