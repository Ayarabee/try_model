import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pneumonia Detection'),
        ),
        body: ImagePredictor(),
      ),
    );
  }
}

class ImagePredictor extends StatefulWidget {
  @override
  _ImagePredictorState createState() => _ImagePredictorState();
}

class _ImagePredictorState extends State<ImagePredictor> {
  File? _image;
  String _result = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model4.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
    );
    print(res);
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      predictImage(File(pickedFile.path));
    }
  }

  Future<void> predictImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.5,
      asynch: true,
    );

    setState(() {
      if (recognitions != null && recognitions.isNotEmpty) {
        _result = recognitions[0]['label'];
      } else {
        _result = "No Pneumonia Detected";
      }
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _image == null
              ? Text('No image selected.')
              : Image.file(_image!),
          Text(
            'Result: $_result',
            style: TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: pickImage,
            child: Text('Pick Image'),
          ),
        ],
      ),
    );
  }
}