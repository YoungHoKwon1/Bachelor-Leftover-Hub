import 'package:flutter/material.dart';
import 'package:leftover_hub/provider/recipes.dart';
import 'package:provider/provider.dart';

class Result extends StatefulWidget {
  final List<String> recipes;
  final List<String> ingredients;
  final String imgUrl;

  const Result(
      {Key? key,
      required this.recipes,
      required this.ingredients,
      required this.imgUrl})
      : super(key: key);

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.imgUrl,
                  width: 256,
                  height: 256,
                ),
              ),
              Center(
                child: Text(widget.recipes[0].substring(
                    widget.recipes[0].indexOf('.') + 1,
                    widget.recipes[0].indexOf(':'))),
              ),
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('[Ingredients]'),
              ),
              if (widget.ingredients.length % 2 == 1) ...[
                //입력 재료 홀수개
                for (int c = 0;
                    c < (widget.ingredients.length - 1) / 2;
                    c++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int r = 0; r < 2; r++) ...[
                        Container(
                          width: 150,
                          margin: const EdgeInsets.only(top: 20),
                          decoration: const BoxDecoration(
                              border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.black),
                          )),
                          child: Text(widget.ingredients[2 * c + r]),
                        ),
                      ]
                    ],
                  )
                ],
                Container(
                  width: 150,
                  margin: const EdgeInsets.only(left: 37, top: 20),
                  decoration: const BoxDecoration(
                      border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black),
                  )),
                  child:
                      Text(widget.ingredients[widget.ingredients.length - 1]),
                ),
              ] else ...[
                //입력 재료 짝수개
                for (int c = 0;
                    c < (widget.ingredients.length - 1) / 2;
                    c++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int r = 0; r < 2; r++) ...[
                        Container(
                          width: 150,
                          margin: const EdgeInsets.only(top: 20),
                          decoration: const BoxDecoration(
                              border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.black),
                          )),
                          child: Text(widget.ingredients[2 * c + r]),
                        ),
                      ]
                    ],
                  )
                ],
              ],
              const SizedBox(
                height: 30,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text('[Recipe]'),
              ),
              for (int i = 0; i < widget.recipes.length; i++) ...[
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 350, child: Text(widget.recipes[i]))
                    ],
                  ),
                ),
              ],
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
