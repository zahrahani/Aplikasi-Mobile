// Model data untuk satu entri riwayat pengukuran BMI.
// Disimpan di dalam riwayat setiap profil.

class BmiRecord {
  final DateTime tanggal;
  final double berat;    // kg
  final double tinggi;   // cm
  final double bmi;

  BmiRecord({
    required this.tanggal,
    required this.berat,
    required this.tinggi,
    required this.bmi,
  });

  // Konversi ke Map JSON
  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String(),
      'berat': berat,
      'tinggi': tinggi,
      'bmi': bmi,
    };
  }

  // Buat BmiRecord dari Map JSON
  factory BmiRecord.fromJson(Map<String, dynamic> json) {
    return BmiRecord(
      tanggal: DateTime.parse(json['tanggal'] as String),
      berat: (json['berat'] as num).toDouble(),
      tinggi: (json['tinggi'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
    );
  }
}