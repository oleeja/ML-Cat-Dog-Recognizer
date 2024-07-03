import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Cat&Dog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ML Cat&Dog'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  List? _prediction;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  detectImage(File image) async {
    _prediction = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_prediction != null && _prediction![0] != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 56.0),
                child: Text(
                  'It\'s a ${_prediction![0]!['label']}\nConfidence is ${_prediction![0]!['confidence']}',
                  style: TextStyle(color: Colors.redAccent, fontSize: 24),
                ),
              ),
            const SizedBox(
              height: 24,
            ),
            _image == null
                ? Image.asset(
                    'assets/dog_cat.png',
                    height: 112,
                  )
                : Image.file(
                    _image!,
                    height: 112,
                  ),
            const SizedBox(
              height: 24,
            ),
            MaterialButton(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              color: Colors.green,
              child: const Text(
                'Open Camera',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final xFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (xFile == null) return;
                _image = File(xFile.path);
                detectImage(_image!);
                setState(() {});
              },
            ),
            const SizedBox(
              height: 24,
            ),
            MaterialButton(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              color: Colors.green,
              child: const Text(
                'Choose from Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                final xFile =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (xFile == null) return;
                _image = File(xFile.path);
                detectImage(_image!);
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}
