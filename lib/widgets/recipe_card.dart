import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:big_bolos/models/production_model.dart';
import 'package:big_bolos/models/recipe_model.dart';
import 'package:big_bolos/models/recipe.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;

  const RecipeCard({required this.recipe, Key? key}) : super(key: key);

  @override
  _RecipeCardState createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool _isExpanded = false;
  int _productionCount = 0;

  @override
  Widget build(BuildContext context) {
    final productionModel = Provider.of<ProductionModel>(context);
    final currentProductionCount = productionModel.productions
        .where((production) => production.name == widget.recipe.name)
        .length;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Receita ${widget.recipe.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (currentProductionCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      'Produção em Andamento: $currentProductionCount',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredientes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...widget.recipe.ingredients.entries.map((entry) {
                    return Text(
                      '${entry.key}: ${_formatQuantity(entry.value)} ${_abbreviateUnit(widget.recipe.units[entry.key]!)}',
                    );
                  }).toList(),
                ],
              ),
            ),
          if (_isExpanded)
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    int? count = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmar Início da Produção'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                  'Você realmente deseja iniciar a produção?'),
                              TextField(
                                decoration: const InputDecoration(
                                    labelText: 'Quantidade'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _productionCount = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              },
                            ),
                            TextButton(
                              child: const Text('Iniciar'),
                              onPressed: () {
                                Navigator.of(context).pop(_productionCount);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (count != null && count > 0) {
                      setState(() {
                        for (int i = 0; i < count; i++) {
                          Provider.of<ProductionModel>(context, listen: false)
                              .addProduction(widget.recipe);
                        }
                      });
                    }
                  },
                  child: const Text('Iniciar Produção'),
                ),
                if (currentProductionCount > 0)
                  ElevatedButton(
                    onPressed: () async {
                      int? count = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                const Text('Confirmar Finalização da Produção'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    'Quantas produções você deseja finalizar?'),
                                TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Quantidade'),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {
                                      _productionCount =
                                          int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(context).pop(null);
                                },
                              ),
                              TextButton(
                                child: const Text('Finalizar'),
                                onPressed: () {
                                  Navigator.of(context).pop(_productionCount);
                                },
                              ),
                            ],
                          );
                        },
                      );
                      if (count != null && count > 0) {
                        if (count > currentProductionCount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'A quantidade inserida é maior do que a quantidade em produção.'),
                            ),
                          );
                        } else {
                          setState(() {
                            for (int i = 0; i < count; i++) {
                              final production = productionModel.productions
                                  .firstWhere((prod) =>
                                      prod.name == widget.recipe.name);
                              Provider.of<ProductionModel>(context,
                                      listen: false)
                                  .finalizeProduction(production);
                            }
                          });
                        }
                      }
                    },
                    child: const Text('Finalizar Produção'),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    bool confirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: const Text(
                              'Você realmente deseja excluir esta receita?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text('Excluir'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed) {
                      Provider.of<RecipeModel>(context, listen: false)
                          .remove(widget.recipe);
                      // Implement logic to remove recipe from the database if needed
                    }
                  },
                  child: const Text('Excluir'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatQuantity(double quantity) {
    return quantity
        .toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2);
  }

  String _abbreviateUnit(String unit) {
    switch (unit) {
      case 'litro':
        return 'L';
      case 'ml':
        return 'ml';
      case 'grama':
        return 'g';
      case 'unidade':
        return 'un';
      default:
        return unit;
    }
  }
}
