// import 'dart:io';
// import 'package:image/image.dart' as img;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:leftover_hub/classifier.dart';
// import 'package:leftover_hub/classifier_quant.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
//
// class TFLite_Helper extends StatefulWidget {
//   TFLite_Helper({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   _TFLite_HelperState createState() => _TFLite_HelperState();
// }
//
// class _TFLite_HelperState extends State<TFLite_Helper> {
//   late Classifier _classifier;
//
//   File? _image;
//   final picker = ImagePicker();
//
//   Image? _imageWidget;
//
//   img.Image? fox;
//
//   Category? category;
//
//   @override
//   void initState() {
//     super.initState();
//     _classifier = ClassifierQuant();
//   }
//
//   Future getImage() async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//
//     setState(() {
//       _image = File(pickedFile!.path);
//       _imageWidget = Image.file(_image!);
//
//       _predict();
//     });
//   }
//
//   void _predict() async {
//     img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
//     var pred = _classifier.predict(imageInput);
//
//     setState(() {
//       this.category = pred;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('TfLite Flutter Helper',
//             style: TextStyle(color: Colors.white)),
//       ),
//       body: Column(
//         children: <Widget>[
//           Center(
//             child: _image == null
//                 ? Text('No image selected.')
//                 : Container(
//               constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height / 2),
//               decoration: BoxDecoration(
//                 border: Border.all(),
//               ),
//               child: _imageWidget,
//             ),
//           ),
//           SizedBox(
//             height: 36,
//           ),
//           Text(
//             category != null ? category!.label : '',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           SizedBox(
//             height: 8,
//           ),
//           Text(
//             category != null
//                 ? 'Confidence: ${category!.score.toStringAsFixed(3)}'
//                 : '',
//             style: TextStyle(fontSize: 16),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: getImage,
//         tooltip: 'Pick Image',
//         child: Icon(Icons.add_a_photo),
//       ),
//     );
//   }
// }