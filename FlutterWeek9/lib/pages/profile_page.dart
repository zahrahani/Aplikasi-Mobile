// Halaman manajemen profil: list profil, switcher, tambah/edit/hapus, dan riwayat BMI beserta line chart per profil.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../theme.dart';
import '../utils/bmi_utils.dart';
import '../widgets/bmi_chart.dart';
import '../widgets/profile_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = ProfileService();
  List<ProfileModel> _profiles = [];
  String? _activeProfileId;
  bool _isLoading = true;

  // Profil yang sedang dibuka detail riwayatnya
  ProfileModel? _selectedProfil;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profiles = await _profileService.getProfiles();
    final activeId = await _profileService.getActiveProfileId();
    setState(() {
      _profiles = profiles;
      _activeProfileId = activeId;
      // Default: buka riwayat profil aktif
      if (_selectedProfil == null && profiles.isNotEmpty) {
        _selectedProfil = profiles.firstWhere(
          (p) => p.id == activeId,
          orElse: () => profiles.first,
        );
      }
      _isLoading = false;
    });
  }

  // Set profil aktif
  Future<void> _setAktif(String id) async {
    await _profileService.setActiveProfileId(id);
    setState(() {
      _activeProfileId = id;
      _selectedProfil = _profiles.firstWhere((p) => p.id == id);
    });
  }

  // Buka dialog tambah atau edit profil
  Future<void> _bukaFormProfil({ProfileModel? profil}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FormProfilSheet(
        profil: profil,
        onSimpan: (profilBaru) async {
          if (profil == null) {
            await _profileService.tambahProfil(profilBaru);
          } else {
            await _profileService.updateProfil(profilBaru);
          }
          await _loadData();
        },
      ),
    );
  }

  // Konfirmasi hapus profil
  Future<void> _hapusProfil(ProfileModel profil) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Profil?'),
        content: Text(
          'Profil "${profil.nama}" dan seluruh riwayat BMI-nya akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _profileService.hapusProfil(profil.id);
      if (_selectedProfil?.id == profil.id) {
        setState(() => _selectedProfil = null);
      }
      await _loadData();
    }
  }

  // Konfirmasi hapus semua riwayat profil tertentu
  Future<void> _hapusRiwayat(ProfileModel profil) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Semua Riwayat?'),
        content: Text(
          'Semua riwayat BMI "${profil.nama}" akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _profileService.hapusSemuaRiwayat(profil.id);
      await _loadData();
      // Update _selectedProfil dengan data terbaru
      setState(() {
        _selectedProfil = _profiles.firstWhere(
          (p) => p.id == profil.id,
          orElse: () => profil,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Kelola Profil'),
        actions: [
          // Tombol tambah profil baru
          IconButton(
            onPressed: () => _bukaFormProfil(),
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Tambah Profil',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Daftar Profil 
                      _buildSectionLabel('Profil Tersimpan'),
                      const SizedBox(height: 12),
                      ..._profiles.map((profil) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ProfileCard(
                              profil: profil,
                              isActive: profil.id == _activeProfileId,
                              onTap: () => _setAktif(profil.id),
                              onEdit: () => _bukaFormProfil(profil: profil),
                              onDelete: () => _hapusProfil(profil),
                            ),
                          )),

                      const SizedBox(height: 28),

                      // Section: Riwayat Profil Terpilih
                      if (_selectedProfil != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildSectionLabel(
                                'Riwayat: ${_selectedProfil!.nama}',
                              ),
                            ),
                            if (_selectedProfil!.riwayat.isNotEmpty)
                              TextButton(
                                onPressed: () =>
                                    _hapusRiwayat(_selectedProfil!),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Hapus Semua',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Chart
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Perkembangan BMI',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              BmiChart(riwayat: _selectedProfil!.riwayat),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List riwayat
                        if (_selectedProfil!.riwayat.isEmpty)
                          _buildEmptyRiwayat()
                        else
                          ..._selectedProfil!.riwayat.reversed.map((record) {
                            final hasil = BmiUtils.getHasilBmi(
                              bmi: record.bmi,
                              usia: _selectedProfil!.usia,
                              gender: _selectedProfil!.gender,
                            );
                            return _buildRiwayatItem(record, hasil);
                          }),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  // Satu baris item riwayat BMI
  Widget _buildRiwayatItem(dynamic record, BmiResult hasil) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Indikator warna kategori
          Container(
            width: 4,
            height: 36,
            decoration: BoxDecoration(
              color: hasil.warna,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy', 'id').format(record.tanggal),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.berat.toStringAsFixed(0)} kg • '
                  '${record.tinggi.toStringAsFixed(0)} cm',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                hasil.kategori,
                style: TextStyle(
                  fontSize: 11,
                  color: hasil.warna,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            'Belum ada profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan profil untuk mulai\nmenggunakan kalkulator BMI.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _bukaFormProfil(),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Profil'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRiwayat() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          'Belum ada riwayat pengukuran.\nHitung BMI di halaman utama.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// Bottom Sheet Form Tambah / Edit Profil 
class _FormProfilSheet extends StatefulWidget {
  final ProfileModel? profil; // null = tambah baru
  final Future<void> Function(ProfileModel) onSimpan;

  const _FormProfilSheet({this.profil, required this.onSimpan});

  @override
  State<_FormProfilSheet> createState() => _FormProfilSheetState();
}

class _FormProfilSheetState extends State<_FormProfilSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _usiaController;
  late String _gender;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.profil?.nama ?? '');
    _usiaController =
        TextEditingController(text: widget.profil?.usia.toString() ?? '');
    _gender = widget.profil?.gender ?? 'Laki-laki';
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usiaController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final profilBaru = ProfileModel(
      id: widget.profil?.id ?? ProfileService.generateId(),
      nama: _namaController.text.trim(),
      usia: int.parse(_usiaController.text),
      gender: _gender,
      riwayat: widget.profil?.riwayat ?? [],
    );

    await widget.onSimpan(profilBaru);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        // Tambah padding saat keyboard muncul
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              widget.profil == null ? 'Tambah Profil Baru' : 'Edit Profil',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Nama
            TextFormField(
              controller: _namaController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong.';
                }
                if (value.trim().length < 2) {
                  return 'Nama minimal 2 karakter.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Usia
            TextFormField(
              controller: _usiaController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Usia',
                suffixText: 'tahun',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Usia tidak boleh kosong.';
                }
                final usia = int.tryParse(value);
                if (usia == null || usia < 1 || usia > 120) {
                  return 'Usia harus antara 1 – 120 tahun.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Gender
            const Text(
              'Jenis Kelamin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Laki-laki', 'Perempuan'].map((g) {
                final isSelected = _gender == g;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _gender = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: EdgeInsets.only(
                        right: g == 'Laki-laki' ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          g,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Tombol simpan
            ElevatedButton(
              onPressed: _isSaving ? null : _simpan,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan Profil'),
            ),
          ],
        ),
      ),
    );
  }
}