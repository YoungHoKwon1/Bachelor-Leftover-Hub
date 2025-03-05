import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:leftover_hub/api/api_consts.dart';

class ApiService {
  //request for openAI GPT
  static Future<List<String>> postRecipes(List<String> ingredients) async {
    try {
      var response = await http.post(Uri.parse(API_URL),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "model": "text-davinci-003",
            // "model": "gpt-3.5-turbo",
            "prompt": "suggest 3 recipes base on those:\n\n$ingredients",
            "temperature": 0.83,
            "max_tokens": 997,
            "top_p": 1,
            "frequency_penalty": 0.8,
            "presence_penalty": 0
          }));
      Map jsonResponse = jsonDecode(response.body);
      String recipes = jsonResponse["choices"][0]["text"];
      String recipe1 = recipes.substring(recipes.indexOf('1. '), recipes.indexOf('2. '));
      String recipe2 = recipes.substring(recipes.indexOf('2. '), recipes.indexOf('3. '));
      String recipe3 = recipes.substring(recipes.indexOf('3. '));
      return [recipe1, recipe2, recipe3];
    } catch (error) {
      print("error-postRecipes-response: $error");
      return ['recipe request failed'];
    }
  }

  // api request for Image Generation Model
  static Future<String> postImage(String recipe1) async {
    try {
      var response = await http.post(Uri.parse(API_IMG_URL),
          headers: {
            'Authorization': 'Bearer $API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode({"prompt": recipe1, "n": 1, "size": "256x256"}));
      Map jsonResponse = jsonDecode(response.body);
      // print("getImage: $jsonResponse");
      String img_url = jsonResponse["data"][0]["url"];
      // print("img url: $img_url");
      return img_url;
    } catch (error) {
      print("error-postImage-response: $error");
      return 'image request failed';
    }
  }
}
