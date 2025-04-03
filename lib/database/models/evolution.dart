class Evolution {
  int? id;            // ID local (SQLite)
  int petId;          // ID local do pet
  double weight;      // Peso do pet em kg
  DateTime date;      // Data do registro
  String? notes;      // Observações opcionais

  Evolution({
    this.id,
    required this.petId,
    required this.weight,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'weight': weight,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Evolution.fromMap(Map<String, dynamic> map) {
    return Evolution(
      id: map['id'],
      petId: map['petId'],
      weight: map['weight'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}
