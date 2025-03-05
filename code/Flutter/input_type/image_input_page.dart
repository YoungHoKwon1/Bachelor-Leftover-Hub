import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:leftover_hub/api/api_service.dart';
import 'package:leftover_hub/result.dart';

class ImageInputPage extends StatefulWidget {
  const ImageInputPage({super.key});

  @override
  State<ImageInputPage> createState() => _ImageInputPageState();
}

class _ImageInputPageState extends State<ImageInputPage> {

  static const modelPath = 'assets/modelMobileNetV2.tflite';
  static const labelsPath = 'assets/Labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;

  Tensor? inputTensor;
  Tensor? outputTensor;

  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;


  List<String> ingredients = <String>[];

  late List<String> recipes;
  late String imgUrl;

  @override
  void initState() {
    super.initState();
    // Load model and labels from assets
    loadModel();
    loadLabels();
  }

  // Clean old results when press some take picture button
  void cleanResult() {
    imagePath = null;
    image = null;
    setState(() {});
  }

  // Load model
  Future<void> loadModel() async {
    final options = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    // Use GPU Delegate
    // doesn't work on emulator
    if (Platform.isAndroid) {
      options.addDelegate(GpuDelegateV2());
    }

    // Use Metal Delegate
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);

    // Get tensor input shape [1, 224, 224, 3]
    inputTensor = interpreter.getInputTensors().first;
    // Get tensor output shape [1, 36]
    outputTensor = interpreter.getOutputTensors().first;
    setState(() {});
    log('Interpreter loaded successfully');
  }

  // Load labels from assets
  Future<void> loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
  }

  // Process picked image
  Future<void> processImage() async {
    if (imagePath != null) {
      // Read image bytes from file
      final imageData = File(imagePath!).readAsBytesSync(); //List<int>

      // Decode image using package:image/image.dart (https://pub.dev/image)
      image = img.decodeImage(imageData);
      setState(() {});

      // Resize image for model input (Mobilenet use [256, 256])
      final imageInput = img.copyResize(
        image!,
        width: 256,
        height: 256,
      );
      // Image(256, 256, uint8, 3)

      // Get image matrix representation [256, 256, 3]
      final imageMatrix = List.generate(
        imageInput.height,
            (y) => List.generate(
          imageInput.width,
              (x) {
            final pixel = imageInput.getPixel(x, y);
            return [pixel.r / 255, pixel.g / 255, pixel.b / 255]; //generalization
          },
        ),
      );

      // Run model inference
      runInference(imageMatrix);
    }
  }

  // Run inference
  Future<void> runInference(List<List<List<num>>> imageMatrix) async {
    // Set tensor input [1, 256, 256, 3]
    final input = [imageMatrix];

    // Set tensor output [1, 36]
    final output = [List<double>.filled(36, 0)];

    // Run inference
    interpreter.run(input, output);

    // Get first output tensor
    // result : [probabilities]
    final result = output.first;

    // argmax result
    // resultIndex : The biggest probability Index
    final resultIndex = argmax(result);

    // label : classified ingredient
    final label = labels[resultIndex];
    showConfirmationDialog(File(imagePath!), label);
    setState(() {});
  }

  int argmax(List<dynamic> X) {
    int idx = 0;
    int l = X.length;
    for (int i = 0; i < l; i++) {
      idx = X[i] > X[idx] ? i : idx;
    }
    return idx;
  }

  Future showConfirmationDialog(File image, String label) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: Image.file(image),
          actions: <Widget>[
            TextButton(
              child: const Text('Accept'),
              onPressed: () {
                setState(() {
                  ingredients.insert(0, label);
                });
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload image of what you have'),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.jpg"), fit: BoxFit.fill)),
        child: Column(
          children: [
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
                Navigator.push(context, MaterialPageRoute(
                      builder: (resultContext) => Result(
                        recipes: recipes,
                        ingredients: ingredients,
                        imgUrl: imgUrl,
                      )),
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  heroTag: 'btnCamera',
                  onPressed: () async {
                    cleanResult();
                    final result = await imagePicker.pickImage(
                      source: ImageSource.camera,
                    );

                    imagePath = result?.path;
                    setState(() {});
                    processImage();
                  },
                  child: const Icon(Icons.add_a_photo),
                ),
                FloatingActionButton(
                  heroTag: 'btnGallery',
                  onPressed: () async {
                    cleanResult();
                    final result = await imagePicker.pickImage(
                      source: ImageSource.gallery,
                    );

                    imagePath = result?.path;
                    setState(() {});
                    processImage();
                  },
                  child: const Icon(Icons.wallpaper),
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
