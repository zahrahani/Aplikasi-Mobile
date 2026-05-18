// Service layer untuk menyimpan, membaca, dan mengelola data profil dengan menggunakan SharedPreferences sebagai penyimpanan lokal.
// Semua operasi async menggunakan Future.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../models/bmi_record_model.dart';

class ProfileService {
  // Key untuk SharedPreferences
  static const String _profilesKey = 'profiles';
  static const String _activeProfileIdKey = 'active_profile_id';

  // Profil 

  /// Ambil semua profil yang tersimpan
  Future<List<ProfileModel>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profilesKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((json) => ProfileModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Simpan seluruh list profil (menggantikan data lama)
  Future<void> _saveProfiles(List<ProfileModel> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await prefs.setString(_profilesKey, jsonString);
  }

  /// Tambah profil baru
  Future<void> tambahProfil(ProfileModel profil) async {
    final profiles = await getProfiles();
    profiles.add(profil);
    await _saveProfiles(profiles);

    // Jika ini profil pertama, jadikan aktif
    if (profiles.length == 1) {
      await setActiveProfileId(profil.id);
    }
  }

  /// Update profil yang sudah ada (berdasarkan id)
  Future<void> updateProfil(ProfileModel profilBaru) async {
    final profiles = await getProfiles();
    final index = profiles.indexWhere((p) => p.id == profilBaru.id);
    if (index != -1) {
      profiles[index] = profilBaru;
      await _saveProfiles(profiles);
    }
  }

  /// Hapus profil berdasarkan id
  Future<void> hapusProfil(String id) async {
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _saveProfiles(profiles);

    // Jika profil yang dihapus adalah yang aktif, ganti ke yang pertama
    final activeId = await getActiveProfileId();
    if (activeId == id) {
      if (profiles.isNotEmpty) {
        await setActiveProfileId(profiles.first.id);
      } else {
        await _clearActiveProfileId();
      }
    }
  }

  // Profil Aktif

  /// Dapatkan id profil yang sedang aktif
  Future<String?> getActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileIdKey);
  }

  /// Set profil aktif
  Future<void> setActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileIdKey, id);
  }

  /// Hapus data profil aktif
  Future<void> _clearActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeProfileIdKey);
  }

  /// Dapatkan profil aktif (objek lengkap)
  Future<ProfileModel?> getActiveProfil() async {
    final activeId = await getActiveProfileId();
    if (activeId == null) return null;

    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((p) => p.id == activeId);
    } catch (_) {
      return null;
    }
  }

  // Riwayat BMI

  /// Tambahkan entri BMI baru ke riwayat profil tertentu
  Future<void> tambahRiwayat(String profileId, BmiRecord record) async {
    final profiles = await getProfiles();
    final index = profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return;

    final riwayatBaru = [...profiles[index].riwayat, record];
    profiles[index] = profiles[index].copyWith(riwayat: riwayatBaru);
    await _saveProfiles(profiles);
  }

  /// Hapus semua riwayat dari profil tertentu
  Future<void> hapusSemuaRiwayat(String profileId) async {
    final profiles = await getProfiles();
    final index = profiles.indexWhere((p) => p.id == profileId);
    if (index == -1) return;

    profiles[index] = profiles[index].copyWith(riwayat: []);
    await _saveProfiles(profiles);
  }

  // Helper

  /// Buat ID unik berbasis waktu
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}