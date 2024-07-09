import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TestModelView extends StatefulWidget {
  const TestModelView({super.key});

  @override
  State<TestModelView> createState() => _TestModelViewState();
}

class _TestModelViewState extends State<TestModelView> {
  File? _image;
  List? result;
  final picker = ImagePicker();
  bool picked = false;

  @override
  initState() {
    super.initState();
    loadModel().then((_) {
      // Model loaded successfully
      print("********* Loaded model successfully. ********");
      setState(() {});
    }).catchError((error) {
      print("Error loading model: $error");
    });
  }

  detectImage(File image) async {
    print("Starting image detection...");
    try {
      var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        imageMean: 0.0,
        imageStd: 255.0,
        threshold: 0.2,
        asynch: true,
      );
      if (output == null) {
        throw Exception("************Null output from model************");
      }
      print("Image detection completed.");
      setState(() {
        result = output;
      });
    } catch (e) {
      print("*************error*************");
      print("Error detecting image: $e");
    }
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
        model: 'assets/model3.tflite',
        labels: 'assets/label3.txt',
        isAsset: true,
        useGpuDelegate: false,
        numThreads: 1,
      );
    } catch (e) {
      print("Error loading model: $e");
      throw e;
    }
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _image = File(image.path);
    });
    detectImage(_image!);
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Model'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 250,
            margin: const EdgeInsets.all(20),
            child: _image != null
                ? Image.file(_image!)
                : Image.asset("assets/default.jpg"),
          ),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () {
                pickGalleryImage();
                setState(() {
                  picked = true;
                });
              },
              child: const Text(
                "Choose Image",
                style: TextStyle(fontSize: 20, color: Colors.black),
              )),
          const SizedBox(
            height: 20,
          ),
          picked && result != null
              ? Text(
                  "Result: ${result![0]["label"]}",
                  style: const TextStyle(fontSize: 20, color: Colors.blue),
                )
              : Container(),
        ],
      ),
    );
  }
}
