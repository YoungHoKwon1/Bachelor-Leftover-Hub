import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter/services.dart';
import 'package:leftover_hub/api/api_service.dart';
import 'package:leftover_hub/result.dart';

class VoiceInputPage extends StatefulWidget {
  const VoiceInputPage({super.key});

  @override
  State<VoiceInputPage> createState() => _VoiceInputPageState();
}

class _VoiceInputPageState extends State<VoiceInputPage> {
  List<String> ingredients = <String>[];
  late List<String> recipes;
  late String imgUrl;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button and start speaking';

  static const String localeId = 'en_US';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            // ingredients.add(_text);
            splitTextBySpace();
          }),
          localeId: localeId
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void splitTextBySpace() {
    setState(() => ingredients = _text.split(' '));
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Say what you have'),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.jpg"), fit: BoxFit.fill)),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 200,),
              Text(_text),
              const SizedBox(height: 40,),
              FloatingActionButton(
                onPressed: _listen,
                child: Icon(_isListening ? Icons.stop : Icons.mic),
              ),
              const SizedBox(
                height: 200,
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

            ],
          ),
        )
      ),
    );
  }
}
