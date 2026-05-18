// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'result_page.dart';
import 'profile_page.dart';

import '../models/bmi_record_model.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
 
class InputPage extends StatefulWidget {
  const InputPage({super.key});
 
  @override
  State<InputPage> createState() => _InputPageState();
}
 
class _InputPageState extends State<InputPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _profileService = ProfileService();
 
  ProfileModel? _activeProfil;
  bool _isLoading = true;
 
  @override
  void initState() {
    super.initState();
    _loadActiveProfil();
  }
 
  // Muat profil aktif dari service
  Future<void> _loadActiveProfil() async {
    final profil = await _profileService.getActiveProfil();
    setState(() {
      _activeProfil = profil;
      _isLoading = false;
    });
  }
 
  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
 
  // Navigasi ke halaman profil, lalu reload saat kembali
  Future<void> _bukaHalamanProfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
    _loadActiveProfil(); // Reload profil setelah kembali
  }
 
  // Hitung BMI dan navigasi ke halaman hasil
  Future<void> _hitungBmi() async {
    if (!_formKey.currentState!.validate()) return;
    if (_activeProfil == null) {
      _showSnackbar('Pilih profil terlebih dahulu.');
      return;
    }
 
    final berat = double.parse(_weightController.text);
    final tinggi = double.parse(_heightController.text);
    final bmi = BmiUtils.hitungBmi(berat, tinggi);
 
    // Simpan ke riwayat profil
    final record = BmiRecord(
      tanggal: DateTime.now(),
      berat: berat,
      tinggi: tinggi,
      bmi: bmi,
    );
    await _profileService.tambahRiwayat(_activeProfil!.id, record);
 
    if (!mounted) return;
 
    // Navigasi ke hasil dengan fade transition
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ResultPage(
          profil: _activeProfil!,
          record: record,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    ).then((_) {
      _weightController.clear();
      _heightController.clear();
    }
    );
  }
 
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kalkulator BMI'),
        backgroundColor: AppColors.background,
        actions: [
          // Tombol buka halaman profil
          IconButton(
            onPressed: _bukaHalamanProfil,
            icon: const Icon(Icons.people_outline),
            tooltip: 'Kelola Profil',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                // Fix overflow: bisa di-scroll saat keyboard muncul
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Profil Aktif
                    _buildProfilBanner(),
                    const SizedBox(height: 24),

                    // Input Berat Badan
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        suffixText: 'kg',
                        labelText: 'Berat Badan',
                        prefixIcon: Icon(
                          Icons.monitor_weight_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      validator: (value) => _validateAngka(
                        value,
                        label: 'Berat badan',
                        min: 10,
                        max: 300,
                      ),
                    ),
                    const SizedBox(height: 20),
 
                    // Input Tinggi Badan
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        suffixText: 'cm',
                        labelText: 'Tinggi Badan',
                        prefixIcon: Icon(
                          Icons.height,
                          color: AppColors.primary,
                        ),
                      ),
                      validator: (value) => _validateAngka(
                        value,
                        label: 'Tinggi badan',
                        min: 50,
                        max: 250,
                      ),
                    ),
                    const SizedBox(height: 32),
 
                    // Info Profil (dari profil aktif)
                    if (_activeProfil != null)
                      _buildInfoProfilCard(_activeProfil!),
                    const SizedBox(height: 32),
 
                    // Tombol Hitung
                    ElevatedButton(
                      onPressed: _activeProfil == null ? null : _hitungBmi,
                      child: const Text('Hitung BMI'),
                    ),
 
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
 
  // Banner menampilkan profil aktif atau ajakan membuat profil
  Widget _buildProfilBanner() {
    if (_activeProfil == null) {
      return GestureDetector(
        onTap: _bukaHalamanProfil,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 233, 231),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Belum ada profil. Tap untuk membuat profil baru.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.red, size: 20),
            ],
          ),
        ),
      );
    }
 
    return GestureDetector(
      onTap: _bukaHalamanProfil,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Text(
                _activeProfil!.nama[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _activeProfil!.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_activeProfil!.usia} tahun • ${_activeProfil!.gender}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Ganti',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
 
  // Card ringkasan info profil aktif
  Widget _buildInfoProfilCard(ProfileModel profil) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Text(
            'Menghitung untuk ',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13),
          ),
          Text(
            profil.nama,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            '${profil.riwayat.length}× ukur',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
 
  // Validasi input angka dengan range tertentu
  String? _validateAngka(
    String? value, {
    required String label,
    required int min,
    required int max,
  }) {
    if (value == null || value.isEmpty) {
      return '$label tidak boleh kosong.';
    }
    final angka = int.tryParse(value);
    if (angka == null) {
      return '$label harus berupa angka.';
    }
    if (angka <= 0) {
      return '$label tidak boleh nol atau negatif.';
    }
    if (angka < min) {
      return '$label minimal $min (masukkan nilai yang masuk akal).';
    }
    if (angka > max) {
      return '$label maksimal $max (masukkan nilai yang masuk akal).';
    }
    return null;
  }
}