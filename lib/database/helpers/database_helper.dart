import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../contracts/exam_contract.dart';
import '../contracts/pet_contract.dart';
import '../contracts/vaccine_contract.dart';
import '../contracts/medicine_contract.dart';
import '../contracts/evolution_contract.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(PetContract.petTable);
    await db.delete(VaccineContract.vaccineTable);
    await db.delete(MedicineContract.medicineTable);
    await db.delete(EvolutionContract.evolutionTable);
    await db.delete(ExamContract.examsTable);
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, "pets.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newerVersion) async {
        await db.execute(
          "CREATE TABLE ${PetContract.petTable}(${PetContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT, "
              " ${PetContract.pictureFileColumn} BLOB, "
              " ${PetContract.nameColumn} TEXT, "
              " ${PetContract.speciesColumn} TEXT, "
              " ${PetContract.breedColumn} TEXT, "
              " ${PetContract.sexColumn} TEXT, "
              " ${PetContract.birthDateColumn} TEXT, "
              " ${PetContract.ageColumn} INTEGER, "
              " ${PetContract.weightColumn} REAL, "
              " ${PetContract.allergyColumn} TEXT, "
              " ${PetContract.notesColumn} TEXT)",
        );
        await db.execute(
          "CREATE TABLE ${VaccineContract.vaccineTable}(${VaccineContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT, "
              " ${VaccineContract.petIdColumn} INTEGER, "
              " ${VaccineContract.nameColumn} TEXT, "
              " ${VaccineContract.dateColumn} TEXT, "
              " ${VaccineContract.nextDoseDateColumn} TEXT, "
              " ${VaccineContract.notesColumn} TEXT, "
              " FOREIGN KEY (${VaccineContract.petIdColumn}) REFERENCES ${PetContract.petTable}(${PetContract.idColumn}))",
        );
        await db.execute(
          "CREATE TABLE ${MedicineContract.medicineTable}(${MedicineContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT, "
              " ${MedicineContract.petIdColumn} INTEGER, "
              " ${MedicineContract.nameColumn} TEXT, "
              " ${MedicineContract.dosageColumn} REAL, "
              " ${MedicineContract.unitColumn} TEXT, "
              " ${MedicineContract.administrationColumn} TEXT, "
              " ${MedicineContract.frequencyColumn} TEXT, "
              " ${MedicineContract.startDateColumn} TEXT, "
              " ${MedicineContract.endDateColumn} TEXT, "
              " ${MedicineContract.notesColumn} TEXT, "
              " FOREIGN KEY (${MedicineContract.petIdColumn}) REFERENCES ${PetContract.petTable}(${PetContract.idColumn}))",
        );
        await db.execute(
            "CREATE TABLE ${EvolutionContract.evolutionTable}("
                " ${EvolutionContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT, "
                " ${EvolutionContract.petIdColumn} INTEGER, "
                " ${EvolutionContract.weightColumn} REAL, "
                " ${EvolutionContract.dateColumn} TEXT, "
                " ${EvolutionContract.notesColumn} TEXT, "
                " FOREIGN KEY (${EvolutionContract.petIdColumn}) REFERENCES ${PetContract.petTable}(${PetContract.idColumn}))"
        );
        await db.execute(
          "CREATE TABLE ${ExamContract.examsTable}(${ExamContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT, "
              " ${ExamContract.petIdColumn} INTEGER, "
              " ${ExamContract.nameColumn} TEXT, "
              " ${ExamContract.dateColumn} TEXT, "
              " ${ExamContract.pdfFileColumn} BLOB, "
              " ${ExamContract.notesColumn} TEXT, "
              " FOREIGN KEY (${ExamContract.petIdColumn}) REFERENCES ${PetContract.petTable}(${PetContract.idColumn}))",
        );
      },
    );
  }
}