import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class Second extends StatefulWidget {
  const Second({super.key});

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  String _response = ' ';
  bool _isLoading = false;

  Future<void> getCalories(String foodItem) async {
    final url = Uri.parse(
        'http://localhost:11434/api/generate'); // Replace with your machine's local IP
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "llama3.2-vision",
          "prompt": "What is the calories of $foodItem? Respond using json",
          "format": "json",
          "stream": false
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final responseString = responseData['response'];
        final parsedData = jsonDecode(responseString);

        final calories = parsedData['calories'];
        final components = parsedData['components'] ?? [];
        final breakdown = parsedData['approximate_calorie_breakdown'] ?? {};

        final componentsString = components.isNotEmpty
            ? components.join(', ')
            : 'No ingredients available';
        final breakdownString = breakdown.isNotEmpty
            ? breakdown.entries
                .map((entry) => '${entry.key}: ${entry.value} calories')
                .join('\n')
            : 'No calorie breakdown available';

        setState(() {
          _response = '''
Food Item: $foodItem
Total Calories: ${calories ?? 'Unknown'}
Ingredients: $componentsString

Approximate Calorie Breakdown:
$breakdownString
        ''';
        });
      } else {
        setState(() {
          _response = 'Error Fetching Calorie Count: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Failed to connect to server: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

//this upload Images to calculate calories
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadImage() async {
    print("Image picker is triggered. Show Image picker now!");
    try {
      // Show an action sheet to choose between Camera and Gallery
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () async {
                    Navigator.pop(context); // Close the action sheet
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.camera);
                    await _processImage(image); // Process the selected image
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context); // Close the action sheet
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);
                    await _processImage(image); // Process the selected image
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context); // Close the action sheet
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
      print("Error picking image: $e");
    }
  }

// Helper function to process the selected image
  Future<void> _processImage(XFile? image) async {
    if (image == null) return;

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Convert the image to a base64 string
      final bytes = await File(image.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      // API request payload
      final body = jsonEncode({
        "model": "llama3.2-vision",
        "prompt": "Describe this picture. Respond in JSON format.",
        "format": "json",
        "stream": false,
        "images": [base64Image],
      });

      // Send the POST request
      final response = await http.post(
        Uri.parse('http://localhost:11434/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          _response = jsonDecode(response.body)['response'] ?? 'No response';
        });
      } else {
        setState(() {
          _response = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Input'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              final makananController = TextEditingController();
              AlertDialog alert = AlertDialog(
                title: const Text('Input Food Item'),
                content: TextField(controller: makananController),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (makananController.text.isNotEmpty) {
                        getCalories(makananController.text);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Submit'),
                  ),
                ],
              );
              showDialog(
                context: context,
                builder: (context) {
                  return alert;
                },
              );
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
              onPressed: () {
                //upload image and calculate Calories
                print("Button pressed to open Image picker!");
                _uploadImage();
              },
              icon: const Icon(Icons.photo_camera))
        ],
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                _response,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
