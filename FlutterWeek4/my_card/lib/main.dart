import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 124, 124, 124),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  "images/cat.jpg",
                ),
              ),
              Text("Connie Fishy",
                  style: GoogleFonts.pacifico(
                    fontSize: 40, 
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  )),
              Text("PROJECT MANAGER",
                  style: GoogleFonts.sourceSans3(
                    fontSize: 20, 
                    color: const Color.fromARGB(255, 44, 44, 44),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  )),

              SizedBox(
                height: 25,
                width: 150,
                child: Divider(
                  color: const Color.fromARGB(170, 0, 0, 0),
                ),
              ),

              // Container Nomor HP
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 25,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "0801234567890",
                      style: GoogleFonts.sourceSans3(fontSize: 20),
                    ),
                  ],
                ),
              ),

              // Container Email
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                margin: EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 25,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "connie@mail.com",
                      style: GoogleFonts.sourceSans3(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
