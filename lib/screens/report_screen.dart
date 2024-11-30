import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:big_bolos/models/production_model.dart';
import 'package:big_bolos/models/production.dart'; // Importar FinishedProduction

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final productionModel = Provider.of<ProductionModel>(context);
    final allProductions = productionModel.finishedProductions;
    final filteredProductions = allProductions.where((production) {
      bool matchesDate = true;
      if (_startDate != null && _endDate != null) {
        matchesDate = production.finishDate.isAfter(_startDate!) &&
            production.finishDate.isBefore(_endDate!.add(Duration(days: 1)));
      }
      return matchesDate;
    }).toList();

    final ingredientTotals = _calculateIngredientTotals(filteredProductions);
    final recipeTotals = _calculateRecipeTotals(filteredProductions);
    final totalBolosFeitos = filteredProductions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Relatório de Produção',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: _pickStartDate,
                  child: Text('Data Inicial'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _startDate == null
                        ? 'Nenhuma data selecionada'
                        : DateFormat('dd/MM/yyyy').format(_startDate!),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _pickEndDate,
                  child: Text('Data Final'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _endDate == null
                        ? 'Nenhuma data selecionada'
                        : DateFormat('dd/MM/yyyy').format(_endDate!),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSummaryTile(
                    'Total de Bolos Feitos', '$totalBolosFeitos unidades'),
                _buildExpandableTile(
                    'Quantidade de Bolos por Sabor', recipeTotals, ' unidades'),
                _buildExpandableTile('Quantidade Total de Ingredientes Usados',
                    ingredientTotals),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  void _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Map<String, String> _calculateIngredientTotals(
      List<FinishedProduction> productions) {
    final totals = <String, Map<String, double>>{};
    for (final production in productions) {
      for (final entry in production.ingredients.entries) {
        final unit = production.units[entry.key]!;
        if (!totals.containsKey(entry.key)) {
          totals[entry.key] = {};
        }
        totals[entry.key]!.update(unit, (value) => value + entry.value,
            ifAbsent: () => entry.value);
      }
    }
    final result = <String, String>{};
    totals.forEach((ingredient, units) {
      units.forEach((unit, total) {
        result['$ingredient (${_abbreviateUnit(unit)})'] =
            _formatQuantity(total);
      });
    });
    return result;
  }

  Map<String, int> _calculateRecipeTotals(
      List<FinishedProduction> productions) {
    final totals = <String, int>{};
    for (final production in productions) {
      totals.update(production.name, (value) => value + 1, ifAbsent: () => 1);
    }
    return totals;
  }

  Widget _buildSummaryTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        value,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildExpandableTile(String title, Map<String, dynamic> items,
      [String suffix = '']) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: items.entries.map((entry) {
        return ListTile(
          title: Text('${entry.key}: ${entry.value}$suffix'),
        );
      }).toList(),
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
