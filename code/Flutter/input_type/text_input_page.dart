import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leftover_hub/api/api_service.dart';
import 'package:leftover_hub/result.dart';

class TextInputPage extends StatefulWidget {
  const TextInputPage({Key? key}) : super(key: key);

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  List<String> ingredients = <String>[];
  late List<String> recipes;
  late String imgUrl;

  TextEditingController itemController = TextEditingController();

  void addItemToList() {
    // add text from textfield to listview
    setState(() {
      ingredients.insert(0, itemController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, //to void keyboard push screen
      appBar: AppBar(
        title: const Text('List up what you have'),
      ),
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.fill)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: itemController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Insert Ingredient',
                      filled: true,
                      fillColor: Color.fromRGBO(150, 150, 200, 150)),
                ),
              ),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  addItemToList();
                  itemController.clear();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: ingredients.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 50,
                          margin: const EdgeInsets.all(2),
                          color: const Color.fromRGBO(150, 150, 200, 150),
                          child: Center(
                              child: Text(
                            ingredients[index],
                            style: const TextStyle(fontSize: 18),
                          )),
                        );
                      })),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text('Search'),
                onPressed: () async {
                  if (kDebugMode) {
                    print("Search");
                  }
                  try {
                    recipes = await ApiService.postRecipes(ingredients);
                    imgUrl = await ApiService.postImage(recipes[0]);
                  } catch (error) {
                    if (kDebugMode) {
                      print("error $error");
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Result(
                              recipes: recipes,
                              ingredients: ingredients,
                              imgUrl: imgUrl,
                            )),
                  );
                },
              ),
              const SizedBox(
                height: 40,
              )
            ],
          )),
    );
  }
}
