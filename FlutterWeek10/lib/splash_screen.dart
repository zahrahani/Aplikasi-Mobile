import 'dart:async';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'item_list_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  int _dotCount = 1;
  late final Timer _dotTimer;

  @override
  void initState() {
    super.initState();

    // Fade in seluruh konten
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Animasi titik-titik: 1 → 2 → 3 → 1 dst
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount % 3) + 1);
    });

    // Navigasi setelah 5 detik
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ItemListPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark1,
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama aplikasi
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'ITory',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: AppColors.yellow2,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Item Inventory Manager',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.yellow1,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 48),

              // Titik-titik loading
              Text(
                '.' * _dotCount,
                style: const TextStyle(
                  fontSize: 32,
                  color: AppColors.yellow1,
                  letterSpacing: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}