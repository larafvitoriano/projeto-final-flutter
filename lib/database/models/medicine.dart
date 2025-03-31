class Medicine {
  int? id;
  int petId;
  String name;
  double dosage;
  String unit;
  String administration;
  String frequency;
  String startDate;
  String? endDate;
  String? notes;

  Medicine({
    this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.unit,
    required this.administration,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'name': name,
      'dosage': dosage,
      'unit': unit,
      'administration': administration,
      'frequency': frequency,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      petId: map['petId'],
      name: map['name'],
      dosage: map['dosage'],
      unit: map['unit'],
      administration: map['administration'],
      frequency: map['frequency'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      notes: map['notes'],
    );
  }
}