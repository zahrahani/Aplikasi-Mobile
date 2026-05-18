// Berisi semua logika kalkulasi BMI, kategorisasi, warna, dan rekomendasi.
// Dipisah dari UI agar mudah diuji dan diubah.

import 'package:flutter/material.dart';
import '../theme.dart';

class BmiResult {
  final double bmi;
  final String kategori;
  final Color warna;
  final String deskripsi;
  final List<String> rekomendasi;
  final String percentileInfo;

  const BmiResult({
    required this.bmi,
    required this.kategori,
    required this.warna,
    required this.deskripsi,
    required this.rekomendasi,
    required this.percentileInfo,
  });
}

class BmiUtils {
  BmiUtils._();

  /// Hitung nilai BMI dari berat (kg) dan tinggi (cm)
  static double hitungBmi(double berat, double tinggi) {
    final tinggiMeter = tinggi / 100;
    return berat / (tinggiMeter * tinggiMeter);
  }

  /// Hasil BMI lengkap beserta kategori, warna, dan rekomendasi
  static BmiResult getHasilBmi({
    required double bmi,
    required int usia,
    required String gender,
  }) {
    if (usia >= 2 && usia <= 18) {
      return _getHasilBmiAnakRemaja(bmi: bmi, usia: usia, gender: gender);
    }
    return _getHasilBmiDewasa(bmi: bmi);
  }

  static BmiResult _getHasilBmiDewasa({required double bmi}) {
    if (bmi < 18.5) {
      return BmiResult(
        bmi: bmi,
        kategori: 'Underweight',
        warna: AppColors.bmiUnderweight,
        deskripsi: 'Berat badan kamu di bawah rentang ideal.',
        rekomendasi: [
          'Tingkatkan asupan kalori dengan makanan bergizi seperti kacang, alpukat, dan protein hewani.',
          'Konsumsi makanan kecil lebih sering, 5–6 kali sehari.',
          'Lakukan latihan kekuatan ringan untuk membangun massa otot.',
          'Pastikan tidur 7–9 jam per malam untuk mendukung pemulihan tubuh.',
          'Konsultasikan pola makan kamu dengan ahli gizi untuk panduan yang lebih personal.',
        ],
        percentileInfo: '',
      );
    } else if (bmi < 25.0) {
      return BmiResult(
        bmi: bmi,
        kategori: 'Normal Weight',
        warna: AppColors.bmiNormal,
        deskripsi: 'Berat badan kamu berada di rentang ideal. Pertahankan!',
        rekomendasi: [
          'Pertahankan pola makan seimbang dengan banyak sayur, buah, dan protein.',
          'Lakukan aktivitas fisik minimal 150 menit per minggu.',
          'Minum air putih minimal 8 gelas per hari untuk hidrasi optimal.',
          'Jaga kualitas tidur 7–9 jam per malam.',
          'Lakukan pemeriksaan kesehatan rutin setidaknya sekali setahun.',
        ],
        percentileInfo: '',
      );
    } else if (bmi < 30.0) {
      return BmiResult(
        bmi: bmi,
        kategori: 'Overweight',
        warna: AppColors.bmiOverweight,
        deskripsi: 'Berat badan kamu sedikit di atas rentang ideal.',
        rekomendasi: [
          'Kurangi asupan makanan olahan, gula tambahan, dan lemak jenuh.',
          'Tingkatkan konsumsi sayuran, buah, dan serat makanan.',
          'Mulai dengan olahraga ringan seperti jalan kaki 30 menit sehari.',
          'Hindari makan larut malam dan perhatikan porsi makan.',
          'Minum air putih sebelum makan untuk membantu mengurangi nafsu makan.',
        ],
        percentileInfo: '',
      );
    } else if (bmi < 35.0) {
      return BmiResult(
        bmi: bmi,
        kategori: 'Obesity Class 1',
        warna: AppColors.bmiObesity1,
        deskripsi: 'Berat badan kamu masuk kategori obesitas tingkat pertama.',
        rekomendasi: [
          'Kurangi asupan kalori secara bertahap dengan panduan ahli gizi.',
          'Pilih olahraga berintensitas rendah-sedang seperti berenang atau bersepeda.',
          'Batasi konsumsi minuman manis, alkohol, dan makanan cepat saji.',
          'Pantau berat badan secara berkala setiap minggu.',
          'Dianjurkan untuk berkonsultasi dengan tenaga kesehatan mengenai program penurunan berat badan.',
        ],
        percentileInfo: '',
      );
    } else if (bmi < 40.0) {
      return BmiResult(
        bmi: bmi,
        kategori: 'Obesity Class 2',
        warna: AppColors.bmiObesity2,
        deskripsi: 'Berat badan kamu masuk kategori obesitas tingkat kedua.',
        rekomendasi: [
          'Segera buat rencana penurunan berat badan bersama tenaga medis.',
          'Mulai perubahan pola makan secara konsisten dan terstruktur.',
          'Pilih aktivitas fisik yang aman untuk kondisi tubuh saat ini.',
          'Pantau tekanan darah dan gula darah secara rutin.',
          'Dukungan komunitas atau konseling dapat sangat membantu proses ini.',
        ],
        percentileInfo: '',
      );
    } else {
      return BmiResult(
        bmi: bmi,
        kategori: 'Obesity Class 3',
        warna: AppColors.bmiObesity3,
        deskripsi: 'Berat badan kamu masuk kategori obesitas tingkat ketiga.',
        rekomendasi: [
          'Sangat disarankan untuk segera berkonsultasi dengan dokter atau spesialis gizi.',
          'Intervensi medis mungkin diperlukan untuk mendukung penurunan berat badan.',
          'Fokus pada perubahan gaya hidup jangka panjang, bukan diet instan.',
          'Aktivitas fisik ringan tetap dianjurkan sesuai kemampuan tubuh.',
          'Dukungan keluarga dan lingkungan sangat berperan dalam proses ini.',
        ],
        percentileInfo: '',
      );
    }
  }

  static BmiResult _getHasilBmiAnakRemaja({
    required double bmi,
    required int usia,
    required String gender,
  }) {
    final double batasBawah = _getBatasNormalBawah(usia, gender);
    final double batasAtas = _getBatasNormalAtas(usia, gender);

    String kategori;
    Color warna;
    String deskripsi;
    String percentileInfo;

    if (bmi < batasBawah - 2) {
      kategori = 'Underweight';
      warna = AppColors.bmiUnderweight;
      deskripsi = 'Berat badan di bawah rentang ideal untuk usia $usia tahun.';
      percentileInfo = 'Estimasi: Persentil ke-5 atau lebih rendah';
    } else if (bmi < batasBawah) {
      kategori = 'Sedikit Kurus';
      warna = AppColors.bmiUnderweight.withOpacity(0.7);
      deskripsi = 'Berat badan sedikit di bawah ideal untuk usia $usia tahun.';
      percentileInfo = 'Estimasi: Persentil ke-5 hingga ke-15';
    } else if (bmi <= batasAtas) {
      kategori = 'Normal Weight';
      warna = AppColors.bmiNormal;
      deskripsi = 'Berat badan berada di rentang ideal untuk usia $usia tahun.';
      percentileInfo = 'Estimasi: Persentil ke-15 hingga ke-85';
    } else if (bmi <= batasAtas + 3) {
      kategori = 'Overweight';
      warna = AppColors.bmiOverweight;
      deskripsi = 'Berat badan sedikit di atas ideal untuk usia $usia tahun.';
      percentileInfo = 'Estimasi: Persentil ke-85 hingga ke-95';
    } else {
      kategori = 'Obesity';
      warna = AppColors.bmiObesity1;
      deskripsi = 'Berat badan melebihi rentang ideal untuk usia $usia tahun.';
      percentileInfo = 'Estimasi: Di atas persentil ke-95';
    }

    return BmiResult(
      bmi: bmi,
      kategori: kategori,
      warna: warna,
      deskripsi: deskripsi,
      rekomendasi: _getRekomendasiAnak(kategori),
      percentileInfo: percentileInfo,
    );
  }

  static double _getBatasNormalBawah(int usia, String gender) {
    final bool lakiLaki = gender == 'Laki-laki';
    if (usia <= 5)  return lakiLaki ? 14.0 : 13.8;
    if (usia <= 8)  return lakiLaki ? 13.5 : 13.2;
    if (usia <= 10) return lakiLaki ? 14.0 : 13.8;
    if (usia <= 12) return lakiLaki ? 14.5 : 14.8;
    if (usia <= 14) return lakiLaki ? 15.5 : 16.0;
    if (usia <= 16) return lakiLaki ? 16.5 : 17.0;
    return lakiLaki ? 17.5 : 17.5;
  }

  static double _getBatasNormalAtas(int usia, String gender) {
    final bool lakiLaki = gender == 'Laki-laki';
    if (usia <= 5)  return lakiLaki ? 17.0 : 17.2;
    if (usia <= 8)  return lakiLaki ? 17.5 : 17.8;
    if (usia <= 10) return lakiLaki ? 19.0 : 19.5;
    if (usia <= 12) return lakiLaki ? 20.5 : 21.0;
    if (usia <= 14) return lakiLaki ? 22.0 : 22.5;
    if (usia <= 16) return lakiLaki ? 23.5 : 23.5;
    return lakiLaki ? 24.5 : 24.0;
  }

  static List<String> _getRekomendasiAnak(String kategori) {
    switch (kategori) {
      case 'Underweight':
      case 'Sedikit Kurus':
        return [
          'Pastikan anak mendapatkan asupan kalori cukup dari makanan bergizi.',
          'Berikan makanan kecil bergizi di antara waktu makan utama.',
          'Dorong aktivitas fisik yang menyenangkan untuk membangun otot.',
          'Pantau pertumbuhan anak secara rutin bersama dokter anak.',
          'Konsultasikan dengan dokter jika berat badan tidak bertambah.',
        ];
      case 'Normal Weight':
        return [
          'Pertahankan pola makan seimbang dengan gizi lengkap setiap hari.',
          'Dorong anak untuk aktif bermain minimal 60 menit per hari.',
          'Batasi waktu layar dan ajak lebih banyak beraktivitas di luar.',
          'Pastikan tidur cukup: 9–11 jam untuk anak, 8–10 jam untuk remaja.',
          'Jaga hidrasi dengan minum air putih, bukan minuman manis.',
        ];
      default:
        return [
          'Kurangi konsumsi makanan cepat saji, camilan manis, dan minuman soda.',
          'Tingkatkan aktivitas fisik secara bertahap dan menyenangkan.',
          'Libatkan seluruh keluarga dalam gaya hidup sehat.',
          'Batasi waktu layar (TV, gadget) maksimal 2 jam per hari.',
          'Konsultasikan dengan dokter anak untuk panduan yang tepat.',
        ];
    }
  }

  // SPEEDOMETER POSITION

  /// Posisi jarum speedometer (0.0 – 1.0).

  /// Untuk dewasa (usia < 2 atau usia > 18): breakpoint tetap sesuai WHO.
  /// Untuk anak-remaja (usia 2–18): breakpoint dihitung dinamis berdasarkan
  /// batas normal bawah/atas usia & gender, sehingga posisi Normal selalu
  /// menempati tengah arc dan zona lain proporsional.
  static double getSpeedometerPosition(
    double bmi, {
    int usia = 0,
    String gender = '',
  }) {
    if (usia >= 2 && usia <= 18) {
      return _getPositionAnak(bmi, usia, gender);
    }
    return _getPositionDewasa(bmi);
  }

  /// Posisi jarum untuk DEWASA.
  /// Range BMI acuan: 10 – 50 (40 poin), dibagi 6 zona.
  ///
  /// Zona & stops (sama dengan gradient dewasa):
  ///   Underweight : 10.0 – 18.5  → pos 0.000 – 0.2125
  ///   Normal      : 18.5 – 25.0  → pos 0.2125 – 0.375
  ///   Overweight  : 25.0 – 30.0  → pos 0.375  – 0.500
  ///   Obesity 1   : 30.0 – 35.0  → pos 0.500  – 0.625
  ///   Obesity 2   : 35.0 – 40.0  → pos 0.625  – 0.750
  ///   Obesity 3   : 40.0 – 50.0  → pos 0.750  – 1.000
  static double _getPositionDewasa(double bmi) {
    const List<double> bmiBreaks = [10.0, 18.5, 25.0, 30.0, 35.0, 40.0, 50.0];
    const List<double> posBreaks = [0.0, 0.2125, 0.375, 0.500, 0.625, 0.750, 1.0];
    return _interpolate(bmi, bmiBreaks, posBreaks);
  }

  /// Posisi jarum untuk ANAK-REMAJA.
  ///
  /// Arc dibagi 5 zona dengan lebar pos yang tetap:
  ///   Underweight    : pos 0.00 – 0.15
  ///   Sedikit Kurus  : pos 0.15 – 0.30
  ///   Normal         : pos 0.30 – 0.70   ← zona terlebar (zona sehat)
  ///   Overweight     : pos 0.70 – 0.85
  ///   Obesity        : pos 0.85 – 1.00
  ///
  /// BMI break per zona dihitung dari batas normal usia & gender:
  ///   batasBawah         = batas bawah Normal
  ///   batasBawah - 2     = batas bawah "Sedikit Kurus"
  ///   batasAtas          = batas atas Normal
  ///   batasAtas + 3      = batas atas Overweight / mulai Obesity
  ///
  /// Ujung bawah (BMI 10) dan ujung atas (BMI ekstrem) dikunci ke pos 0 & 1.
  static double _getPositionAnak(double bmi, int usia, String gender) {
    final double batasBawah  = _getBatasNormalBawah(usia, gender);
    final double batasAtas   = _getBatasNormalAtas(usia, gender);

    // BMI breakpoints per zona
    final List<double> bmiBreaks = [
      10.0,                 // ujung kiri arc
      batasBawah - 2,       // mulai Sedikit Kurus
      batasBawah,           // mulai Normal
      batasAtas,            // mulai Overweight
      batasAtas + 3,        // mulai Obesity
      batasAtas + 13,       // ujung kanan arc (clamped ke 1.0)
    ];

    // Pos breakpoints — selalu tetap agar zona Normal selalu di tengah
    const List<double> posBreaks = [0.00, 0.15, 0.30, 0.70, 0.85, 1.00,];

    return _interpolate(bmi, bmiBreaks, posBreaks);
  }

  /// Interpolasi linier antara breakpoints.
  static double _interpolate(
    double value,
    List<double> breaks,
    List<double> positions,
  ) {
    assert(breaks.length == positions.length);
    if (value <= breaks.first) return positions.first;
    if (value >= breaks.last)  return positions.last;

    for (int i = 0; i < breaks.length - 1; i++) {
      if (value <= breaks[i + 1]) {
        final t = (value - breaks[i]) / (breaks[i + 1] - breaks[i]);
        return positions[i] + t * (positions[i + 1] - positions[i]);
      }
    }
    return positions.last;
  }

  /// Gradient color stops untuk speedometer ANAK (5 zona).
  static const List<Color> gradientColorsAnak = [
    AppColors.bmiUnderweight,
    AppColors.bmiUnderweight,
    AppColors.bmiNormal,
    AppColors.bmiNormal,
    AppColors.bmiOverweight,
    AppColors.bmiObesity1,
  ];

  static const List<double> gradientStopsAnak = [0.00, 0.15, 0.30, 0.70, 0.85, 1.00,];

  /// Gradient color stops untuk speedometer DEWASA (6 zona) — tidak berubah.
  static const List<Color> gradientColorsDewasa = [
    AppColors.bmiUnderweight,
    AppColors.bmiNormal,
    AppColors.bmiOverweight,
    AppColors.bmiObesity1,
    AppColors.bmiObesity2,
    AppColors.bmiObesity3,
  ];

  static const List<double> gradientStopsDewasa = [0.0, 0.2125, 0.375, 0.500, 0.625, 0.750,];
}