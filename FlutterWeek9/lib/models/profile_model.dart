// Model data untuk profil pengguna.
// Setiap profil memiliki identitas sendiri dan menyimpan riwayat BMI-nya.

import 'bmi_record_model.dart';

class ProfileModel {
  final String id;         // Unique identifier (timestamp-based)
  final String nama;
  final int usia;
  final String gender;     // 'Laki-laki' atau 'Perempuan'
  final List<BmiRecord> riwayat;

  ProfileModel({
    required this.id,
    required this.nama,
    required this.usia,
    required this.gender,
    List<BmiRecord>? riwayat,
  }) : riwayat = riwayat ?? [];

  // Buat salinan profil dengan field tertentu diubah
  ProfileModel copyWith({
    String? id,
    String? nama,
    int? usia,
    String? gender,
    List<BmiRecord>? riwayat,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      usia: usia ?? this.usia,
      gender: gender ?? this.gender,
      riwayat: riwayat ?? this.riwayat,
    );
  }

  // Konversi ke Map untuk disimpan ke SharedPreferences (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'usia': usia,
      'gender': gender,
      'riwayat': riwayat.map((r) => r.toJson()).toList(),
    };
  }

  // Buat ProfileModel dari Map JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      usia: json['usia'] as int,
      gender: json['gender'] as String,
      riwayat: (json['riwayat'] as List<dynamic>)
          .map((r) => BmiRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}