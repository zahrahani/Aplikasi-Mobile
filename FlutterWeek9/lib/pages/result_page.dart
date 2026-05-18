// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bmi_record_model.dart';
import '../models/profile_model.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/bmi_speedometer.dart';

class ResultPage extends StatefulWidget {
  final ProfileModel profil;
  final BmiRecord record;

  const ResultPage({
    super.key,
    required this.profil,
    required this.record,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late BmiResult _hasilBmi;

  @override
  void initState() {
    super.initState();

    _hasilBmi = BmiUtils.getHasilBmi(
      bmi: widget.record.bmi,
      usia: widget.profil.usia,
      gender: widget.profil.gender,
    );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hasil BMI'),
        backgroundColor: AppColors.background,
        leading: const BackButton(),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainCard(),
              const SizedBox(height: 16),
              _buildDetailCard(),
              const SizedBox(height: 16),
              _buildRekomendasiCard(),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hitung Ulang'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: _hasilBmi.warna.withOpacity(0.15),
                child: Text(
                  widget.profil.nama[0].toUpperCase(),
                  style: TextStyle(
                    color: _hasilBmi.warna,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.profil.nama,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          BmiSpeedometer(
            bmi: widget.record.bmi,
            bmiColor: _hasilBmi.warna,
            usia: widget.profil.usia,
            gender: widget.profil.gender,
          ),
          
          const SizedBox(height: 8),

          // Badge kategori: filled solid, teks putih
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: _hasilBmi.warna,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _hasilBmi.kategori,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            _hasilBmi.deskripsi,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          if (_hasilBmi.percentileInfo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.child_care,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    _hasilBmi.percentileInfo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Pengukuran',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Berat Badan',
                  value: '${widget.record.berat.toStringAsFixed(0)} kg',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.height,
                  label: 'Tinggi Badan',
                  value: '${widget.record.tinggi.toStringAsFixed(0)} cm',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal Ukur',
                  value: DateFormat('dd MMM y', 'id_ID').format(widget.record.tanggal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRekomendasiCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rekomendasi Gaya Hidup',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Informasi umum, bukan saran medis.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),

          // List rekomendasi: bullet titik biasa
          ...(_hasilBmi.rekomendasi.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bullet titik
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }
}