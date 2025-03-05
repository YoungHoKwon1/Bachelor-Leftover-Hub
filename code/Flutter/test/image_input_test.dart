/*
 * Copyright 2023 The TensorFlow Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *             http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteTest extends StatefulWidget {
  const TfliteTest({super.key});

  @override
  State<TfliteTest> createState() => _TfliteTestState();
}

class _TfliteTestState extends State<TfliteTest> {

  static const modelPath = 'assets/modelMobileNetV2.tflite';
  static const labelsPath = 'assets/Labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;

  Tensor? inputTensor;
  Tensor? outputTensor;

  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;

  Map<String, double>? classification;

  List<String> ingredients = <String>[];
  TextEditingController itemController = TextEditingController();

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
    classification = null;
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
      print('imageInput: $imageInput'); // Image(256, 256, uint8, 3)

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
    final result = output.first;
    final resultIndex = argmax(result);
    print(result[resultIndex].runtimeType);
    print('result: $result');
    print('resultIndex: $resultIndex');
    print(result[resultIndex]);
    print(labels[resultIndex]);
    // Set classification map {label: points}
    classification = <String, double>{};
    classification![labels[resultIndex]] = result[resultIndex];

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
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (imagePath != null) Image.file(File(imagePath!)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(),
                              // Show model information
                              Text(
                                'Input: (shape: ${inputTensor?.shape} type: ${inputTensor?.type})',
                              ),
                              Text(
                                'Output: (shape: ${outputTensor?.shape} type: ${outputTensor?.type})',
                              ),
                              const SizedBox(height: 8),
                              // Show picked image information
                              if (image != null) ...[
                                // Text('Num channels: ${image?.numChannels}'),
                                // Text('Bits per channel: ${image?.bitsPerChannel}'),
                                Text('Height: ${image?.height}'),
                                Text('Width: ${image?.width}'),
                              ],
                              const SizedBox(height: 24),
                              // Show classification result
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (classification != null)
                                        ...(classification!.entries.toList()
                                              ..sort(
                                                (a, b) =>
                                                    a.value.compareTo(b.value),
                                              ))
                                            .reversed
                                            .map(
                                              (e) => Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: Colors.orange
                                                    .withOpacity(0.3),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                        '${e.key}: ${e.value}'),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              // Expanded(
                              //     child: ListView.builder(
                              //         itemCount: ingredients.length,
                              //         itemBuilder: (BuildContext context, int index) {
                              //           return Container(
                              //             height: 50,
                              //             margin: const EdgeInsets.all(2),
                              //             color: const Color.fromRGBO(150, 150, 200, 150),
                              //             child: Center(
                              //                 child: Text(
                              //                   ingredients[index],
                              //                   style: const TextStyle(fontSize: 18),
                              //                 )),
                              //           );
                              //         })),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
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
                SizedBox(
                  height: 30,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
