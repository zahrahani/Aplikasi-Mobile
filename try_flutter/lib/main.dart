import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 234, 205),
      body: Center(
        child: Text(
          "Hello! This is my first Flutter homepage.",
          style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 42, 36, 19))
        ),
      )
    )
  ));
}