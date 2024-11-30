import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:big_bolos/models/recipe_model.dart';
import 'recipe_form_screen.dart';
import 'production_in_progress_screen.dart';
import 'report_screen.dart';
import 'package:big_bolos/widgets/recipe_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipes = Provider.of<RecipeModel>(context).recipes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BIG BOLOS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              switch (result) {
                case 'Criar Nova Receita':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecipeFormScreen()));
                  break;
                case 'Produção em Andamento':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductionInProgressScreen()));
                  break;
                case 'Produção Finalizada':
                  // Remova FinishedProductionScreen se não estiver usando
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => FinishedProductionScreen()));
                  break;
                case 'Relatório':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ReportScreen()));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Criar Nova Receita',
                child: Text('Criar Nova Receita'),
              ),
              const PopupMenuItem<String>(
                value: 'Produção em Andamento',
                child: Text('Produção em Andamento'),
              ),
              const PopupMenuItem<String>(
                value: 'Produção Finalizada',
                child: Text('Produção Finalizada'),
              ),
              const PopupMenuItem<String>(
                value: 'Relatório',
                child: Text('Relatório'),
              ),
            ],
          ),
        ],
      ),
      body: recipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cake, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Nenhuma receita cadastrada ainda!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Comece criando uma nova receita.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return RecipeCard(
                    recipe:
                        recipe); // Certifique-se de que RecipeCard existe ou importe-o corretamente
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Nova Receita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Produção em Andamento',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Relatório',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RecipeFormScreen()));
              break;
            case 1:
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductionInProgressScreen()));
              break;
            case 2:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReportScreen()));
              break;
          }
        },
      ),
    );
  }
}
