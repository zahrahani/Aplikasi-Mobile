import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'item_model.dart';
import 'sort_option.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  List<ItemModel> _items = [];
  bool _isLoading = true;

  SortOption _sortOption = SortOption.idAsc;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Lifecycle 
  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Storage
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? itemsString = prefs.getString('items_list');

    setState(() {
      if (itemsString != null) {
        List<dynamic> itemsMap = json.decode(itemsString);
        _items = itemsMap.map((item) => ItemModel.fromMap(item)).toList();
      }
      _isLoading = false;
      });
    }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> itemsMap =
        _items.map((item) => item.toMap()).toList();
    await prefs.setString('items_list', json.encode(itemsMap));
  }

  // Computed list (search + sort)
  List<ItemModel> get _filteredAndSortedItems {
    List<ItemModel> result = _items.where((item) {
      final q = _searchQuery;
      return item.name.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.id.toString().contains(q);
    }).toList();

    switch (_sortOption) {
      case SortOption.idAsc:
        result.sort((a, b) => a.id.compareTo(b.id));
        break;
      case SortOption.idDesc:
        result.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.nameAsc:
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        result.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
    }

    return result;
  }

  // CRUD 
  int _generateId() => DateTime.now().millisecondsSinceEpoch;

  Future<void> _addItem(String name, String description) async {
    final newItem = ItemModel(
      id: _generateId(),
      name: name.trim(),
      description: description.trim(),
    );

    setState(() => _items.add(newItem));
    await _saveData();

    if (!mounted) return;
    _showSnackBar('Item berhasil ditambahkan', isSuccess: true);
  }

  Future<void> _editItem(ItemModel item, String name, String description) async {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index == -1) return;

    setState(() {
      _items[index] = item.copyWith(
        name: name.trim(),
        description: description.trim(),
      );
    });
    await _saveData();

    if (!mounted) return;
    _showSnackBar('Item berhasil diperbarui', isSuccess: true);
  }

  Future<void> _deleteItem(int id) async {
    setState(() => _items.removeWhere((item) => item.id == id));
    await _saveData();

    if (!mounted) return;
    _showSnackBar('Item berhasil dihapus', isSuccess: false, isDelete: true);
  }

  // Snackbar helper 
  void _showSnackBar(String message,
      {required bool isSuccess, bool isDelete = false}) {
    Color bgColor;
    IconData icon;

    if (isDelete) {
      bgColor = AppColors.warning;
      icon = Icons.delete_outline;
    } else if (isSuccess) {
      bgColor = AppColors.success;
      icon = Icons.check_circle_outline;
    } else {
      bgColor = AppColors.error;
      icon = Icons.error_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dialogs 
  void _showAddEditDialog({ItemModel? editItem}) {
    final isEdit = editItem != null;

    showDialog(
      context: context,
      builder: (ctx) => _AddEditDialog(
        editItem: editItem,
        isEdit: isEdit,
        onSubmit: (name, desc) async {
          if (isEdit) {
            await _editItem(editItem, name, desc);
          } else {
            await _addItem(name, desc);
          }
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.dark2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Hapus Item?',
            style: TextStyle(
                color: AppColors.yellow1, fontWeight: FontWeight.bold),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.yellow2, height: 1.5),
              children: [
                const TextSpan(text: 'Item '),
                TextSpan(
                  text: '"${item.name}"',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.yellow1),
                ),
                const TextSpan(text: ' akan dihapus secara permanen.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.yellow1)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _deleteItem(item.id);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          backgroundColor: AppColors.dark2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Urutkan berdasarkan',
            style: TextStyle(
                color: AppColors.yellow1, fontWeight: FontWeight.bold),
          ),
          children: SortOption.values.map((opt) {
            final isSelected = _sortOption == opt;
            return SimpleDialogOption(
              onPressed: () {
                setState(() => _sortOption = opt);
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? AppColors.yellow1
                        : AppColors.yellow1.withValues(alpha: 0.4),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    opt.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.yellow1
                          : AppColors.yellow2,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Build 
  @override
  Widget build(BuildContext context) {
    final displayItems = _filteredAndSortedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Urutkan',
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppColors.yellow2),
              decoration: InputDecoration(
                hintText: 'Cari nama, deskripsi, atau ID',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.yellow1),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.yellow1),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),

          // Info bar
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${displayItems.length} item',
                    style: TextStyle(
                        color: AppColors.yellow1.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'Urut: ${_sortOption.label}',
                    style: TextStyle(
                        color: AppColors.yellow1.withValues(alpha: 0.7),
                        fontSize: 12),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 4),

          // Body
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : displayItems.isEmpty
                    ? _buildEmptyState()
                    : _buildList(displayItems),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'Tambah Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.yellow1,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: TextStyle(
                color: AppColors.yellow1.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    final isSearching = _searchQuery.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.inbox_outlined,
              size: 72,
              color: AppColors.yellow1.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Tidak ada hasil untuk\n"$_searchQuery"'
                  : 'Belum ada item',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.yellow1,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Coba kata kunci lain.'
                  : 'Tekan tombol + untuk menambahkan item baru.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.yellow1.withValues(alpha: 0.6), fontSize: 13),
            ),
            if (isSearching) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.clear,
                    color: AppColors.yellow1, size: 16),
                label: const Text('Bersihkan pencarian',
                    style: TextStyle(color: AppColors.yellow1)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // List
  Widget _buildList(List<ItemModel> items) {
    return ListView.builder(
      padding: const EdgeInsets.only(
          left: 16, right: 16, bottom: 90, top: 4),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.yellow1,
              child: Text(
                item.name[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.dark1,
                    fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellow1),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.description,
                    style: TextStyle(
                        color: AppColors.yellow2.withValues(alpha: 0.8))),
                const SizedBox(height: 4),
                Text(
                  'ID: ${item.id}',
                  style: TextStyle(
                      color: AppColors.yellow1.withValues(alpha: 0.5),
                      fontSize: 11),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.yellow1),
                  tooltip: 'Edit',
                  onPressed: () => _showAddEditDialog(editItem: item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                  tooltip: 'Hapus',
                  onPressed: () => _showDeleteConfirmDialog(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dialg tambah/edit
class _AddEditDialog extends StatefulWidget {
  final ItemModel? editItem;
  final bool isEdit;
  final Future<void> Function(String name, String desc) onSubmit;
 
  const _AddEditDialog({
    required this.editItem,
    required this.isEdit,
    required this.onSubmit,
  });
 
  @override
  State<_AddEditDialog> createState() => _AddEditDialogState();
}
 
class _AddEditDialogState extends State<_AddEditDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();
 
  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.editItem?.name ?? '');
    _descController =
        TextEditingController(text: widget.editItem?.description ?? '');
  }
 
  @override
  void dispose() {
    // dispose aman di sini karena dipanggil saat widget benar-benar unmount
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.dark2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.isEdit ? 'Edit Item' : 'Tambah Item Baru',
        style: const TextStyle(
            color: AppColors.yellow1, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.yellow2),
              decoration: const InputDecoration(labelText: 'Nama Item'),
              maxLength: 50,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                if (v.trim().length < 2) return 'Nama minimal 2 karakter';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              style: const TextStyle(color: AppColors.yellow2),
              decoration: const InputDecoration(labelText: 'Deskripsi'),
              maxLength: 100,
              maxLines: 2,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                if (v.trim().length < 3) {
                  return 'Deskripsi minimal 3 karakter';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal',
              style: TextStyle(color: AppColors.yellow1)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.yellow1,
            foregroundColor: AppColors.dark1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final name = _nameController.text;
            final desc = _descController.text;
            Navigator.pop(context); // tutup dialog dulu, baru await
            await widget.onSubmit(name, desc);
          },
          child: Text(widget.isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}