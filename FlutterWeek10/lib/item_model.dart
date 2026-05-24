class ItemModel {
  final int id;
  final String name;
  final String description;

  ItemModel({
    required this.id,
    required this.name,
    required this.description,
  });

  // Konversi ke Map untuk disimpan ke SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  // Konversi dari Map ke ItemModel
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }

  // CopyWith untuk edit item
  ItemModel copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}