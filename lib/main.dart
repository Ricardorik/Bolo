import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/recipe_model.dart';
import 'models/production_model.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final recipeModel = RecipeModel();
  final productionModel = ProductionModel();

  await recipeModel.loadRecipes();
  await productionModel.loadProductions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => recipeModel),
        ChangeNotifierProvider(create: (_) => productionModel),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BIG BOLOS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
