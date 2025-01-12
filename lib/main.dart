//Before running this make sure Ollama run llama3.2-vision on your CMD or Terminal
//Make sure all your dependencies like http and image_picker are installed in pubspec.yaml

import 'package:flutter/material.dart';
import 'package:helloworld/first.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Hello App',
      home: First(),
    );
  }
}
