import 'package:flutter/material.dart';
import 'package:helloworld/second.dart';

class First extends StatelessWidget {
  const First({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Calorie Counter'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to My App'),
            const Text('This app will calculate your Food Calories'),
            TextButton(
                onPressed: () {
                  //code to next page
                  MaterialPageRoute route =
                      MaterialPageRoute(builder: (Context) => Second());
                  Navigator.push(context, route);
                },
                child: const Text('Proceed'))
          ],
        ),
      ),
    );
  }
}
