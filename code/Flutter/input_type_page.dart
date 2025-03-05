import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:leftover_hub/input_type/image_input_page.dart';
import 'package:leftover_hub/input_type/text_input_page.dart';
import 'package:leftover_hub/input_type/voice_input_page.dart';
import 'package:leftover_hub/test/voice_input_test.dart';

class InputTypePage extends StatelessWidget {
  const InputTypePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Input Type'),
      ),
      body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/background.jpg"),
                  fit: BoxFit.fill)),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Select Input Type',
                  style: TextStyle(fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print("input type : image");
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  const ImageInputPage()),
                    );
                  },
                  child: const Text('Image'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print("input type : voice");
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  const VoiceInputPage()),
                    );

                  },
                  child: const Text('Voice'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print("input type : text");
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TextInputPage()),
                    );
                  },
                  child: const Text('Text'),
                ),
              ],
            ),
          )),
    );
  }
}
