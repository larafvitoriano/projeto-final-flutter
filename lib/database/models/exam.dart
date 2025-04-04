import '../contracts/exam_contract.dart';

class Exam {
  int? id;
  int petId;
  String name;
  String date;
  List<int> pdfFile;
  String? notes;

  Exam({
    this.id,
    required this.petId,
    required this.name,
    required this.date,
    required this.pdfFile,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      ExamContract.idColumn: id,
      ExamContract.petIdColumn: petId,
      ExamContract.nameColumn: name,
      ExamContract.dateColumn: date,
      ExamContract.pdfFileColumn: pdfFile,
      ExamContract.notesColumn: notes,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map[ExamContract.idColumn],
      petId: map[ExamContract.petIdColumn],
      name: map[ExamContract.nameColumn],
      date: map[ExamContract.dateColumn],
      pdfFile: map[ExamContract.pdfFileColumn],
      notes: map[ExamContract.notesColumn],
    );
  }
}