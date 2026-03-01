import 'package:flutter/material.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 0, 77, 141),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                //height: 100,
                width: 20,
                padding: EdgeInsets.all(10),
                color: Colors.red,
                child: Text("P"),
              ),
              Container(
                //height: 100,
                width: 20,
                padding: EdgeInsets.all(10),
                color: Colors.yellow,
                child: Text("Hallooo"),
              ),
              SizedBox(width: 25),
              Container(
                //height: 100,
                width: 20,
                padding: EdgeInsets.all(10),
                color: Colors.green,
                child: Text("Aku hani :P"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
