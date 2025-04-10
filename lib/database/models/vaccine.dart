import '../contracts/vaccine_contract.dart';

class Vaccine {
  int? id;
  int petId;
  String name;
  String date;
  String nextDoseDate;
  String? notes;

  Vaccine({
    this.id,
    required this.petId,
    required this.name,
    required this.date,
    required this.nextDoseDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      VaccineContract.idColumn: id,
      VaccineContract.petIdColumn: petId,
      VaccineContract.nameColumn: name,
      VaccineContract.dateColumn: date,
      VaccineContract.nextDoseDateColumn: nextDoseDate,
      VaccineContract.notesColumn: notes,
    };
  }

  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map[VaccineContract.idColumn],
      petId: map[VaccineContract.petIdColumn],
      name: map[VaccineContract.nameColumn],
      date: map[VaccineContract.dateColumn],
      nextDoseDate: map[VaccineContract.nextDoseDateColumn],
      notes: map[VaccineContract.notesColumn],
    );
  }
}