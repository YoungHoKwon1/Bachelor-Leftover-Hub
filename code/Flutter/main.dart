import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leftover_hub/input_type_page.dart';
import 'package:leftover_hub/provider/recipes.dart';
import 'package:provider/provider.dart';


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHome());
  }
}
class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Leftover Hub!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Press Start button to get Recommendation',
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (kDebugMode) {
                  print("Find Recipes");
                }
                Navigator.push(context, MaterialPageRoute(builder: (context) => const InputTypePage()),);
              },
              child: const Text('Find Recipes'),
            ),
          ],
        ),
      ),
    );
  }
}
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
