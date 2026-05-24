enum SortOption { idAsc, idDesc, nameAsc, nameDesc }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.idAsc:
        return 'ID: Terkecil';
      case SortOption.idDesc:
        return 'ID: Terbesar';
      case SortOption.nameAsc:
        return 'Nama: A → Z';
      case SortOption.nameDesc:
        return 'Nama: Z → A';
    }
  }
}