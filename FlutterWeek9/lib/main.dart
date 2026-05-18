import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/input_page.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi locale untuk format tanggal Bahasa Indonesia
  await initializeDateFormatting('id', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator BMI',
      debugShowCheckedModeBanner: false,
      theme: appTheme, // Menggunakan design sistem dari theme.dart
      home: const InputPage(),
    );
  }
}