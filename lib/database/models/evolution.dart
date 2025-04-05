class Evolution {
  int? id;            // ID local (SQLite)
  int petId;          // ID local do pet
  double weight;      // Peso do pet em kg
  String date;      // Data do registro
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
      'date': date,
      'notes': notes,
    };
  }

  factory Evolution.fromMap(Map<String, dynamic> map) {
    return Evolution(
      id: map['id'],
      petId: map['petId'],
      weight: map['weight'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
