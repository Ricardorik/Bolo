import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:big_bolos/models/production_model.dart';

class ProductionInProgressScreen extends StatefulWidget {
  @override
  _ProductionInProgressScreenState createState() =>
      _ProductionInProgressScreenState();
}

class _ProductionInProgressScreenState
    extends State<ProductionInProgressScreen> {
  int _productionCount = 0;
  List<bool> _expandedList = [];

  @override
  void initState() {
    super.initState();
    final productionModel =
        Provider.of<ProductionModel>(context, listen: false);
    _expandedList =
        List<bool>.filled(productionModel.productions.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final productionModel = Provider.of<ProductionModel>(context);
    final productions = productionModel.productions;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produção em Andamento',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2),
        ),
      ),
      body: productions.isEmpty
          ? Center(
              child: Text(
                'Nenhuma produção em andamento!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: productions.length,
              itemBuilder: (context, index) {
                final production = productions[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(production.name),
                        trailing: IconButton(
                          icon: Icon(_expandedList[index]
                              ? Icons.expand_less
                              : Icons.expand_more),
                          onPressed: () {
                            setState(() {
                              _expandedList[index] = !_expandedList[index];
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _expandedList[index] = !_expandedList[index];
                          });
                        },
                      ),
                      if (_expandedList[index])
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ingredientes:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...production.ingredients.entries.map((entry) {
                                return Text(
                                  '${entry.key}: ${_formatQuantity(entry.value)} ${_abbreviateUnit(production.units[entry.key]!)}',
                                );
                              }).toList(),
                              ButtonBar(
                                alignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      int? count = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Confirmar Finalização da Produção'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    'Quantas produções você deseja finalizar?'),
                                                TextField(
                                                  decoration: InputDecoration(
                                                      labelText: 'Quantidade'),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _productionCount =
                                                          int.tryParse(value) ??
                                                              0;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(null);
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Finalizar'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(_productionCount);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (count != null && count > 0) {
                                        if (count > productions.length) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'A quantidade inserida é maior do que a quantidade em produção.'),
                                            ),
                                          );
                                        } else {
                                          setState(() {
                                            for (int i = 0; i < count; i++) {
                                              Provider.of<ProductionModel>(
                                                      context,
                                                      listen: false)
                                                  .finalizeProduction(
                                                      production);
                                            }
                                          });
                                        }
                                      }
                                    },
                                    child: Text('Finalizar Produção'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      bool confirmed = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmar Exclusão'),
                                            content: Text(
                                                'Você realmente deseja excluir esta produção?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Cancelar'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Excluir'),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirmed) {
                                        setState(() {
                                          Provider.of<ProductionModel>(context,
                                                  listen: false)
                                              .removeProduction(production);
                                        });
                                      }
                                    },
                                    child: Text('Excluir Produção'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
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
