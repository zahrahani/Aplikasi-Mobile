import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Hello, World! I'm here",
            style: TextStyle(
              color: const Color.fromARGB(213, 255, 255, 255),
              fontWeight: FontWeight.bold
              ),
            ),
          backgroundColor: Color.fromARGB(255, 30, 61, 115),
        ),
        body: Center(
          child: Image(
              image: AssetImage('images/blue_emo.png'),
          ),
        ),
      )
    ),
  );
}