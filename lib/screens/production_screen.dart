import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:big_bolos/models/recipe.dart'; // Certifique-se de que este arquivo existe
import 'package:big_bolos/models/production_model.dart';

class ProductionScreen extends StatelessWidget {
  final Recipe recipe;

  ProductionScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produção de ${recipe.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'Nome do Bolo: ${recipe.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Ingredientes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recipe.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredientName =
                      recipe.ingredients.keys.elementAt(index);
                  final quantity = recipe.ingredients[ingredientName];
                  return ListTile(
                    title: Text(
                        '$ingredientName: $quantity ${recipe.units[ingredientName]}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final productionModel =
                    Provider.of<ProductionModel>(context, listen: false);

                // Adicionando a produção em andamento
                productionModel.addProduction(recipe);

                Navigator.pop(context);
              },
              child: Text('Iniciar Produção'),
            ),
          ],
        ),
      ),
    );
  }
}
