// Widget card untuk menampilkan satu profil di halaman profile switcher.
// Mendukung mode aktif/tidak aktif, edit, dan hapus.

import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profil;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProfileCard({
    super.key,
    required this.profil,
    required this.isActive,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar dengan inisial nama
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  profil.nama.isNotEmpty
                      ? profil.nama[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info profil
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profil.nama,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${profil.usia} tahun • ${profil.gender} • '
                    '${profil.riwayat.length} pengukuran',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol aksi
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Profil'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
              child: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}