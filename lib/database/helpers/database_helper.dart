import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../contracts/pet_contract.dart';
import '../contracts/vaccine_contract.dart';
import '../contracts/medicine_contract.dart';

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
              " ${PetContract.nameColumn} TEXT, "
              " ${PetContract.speciesColumn} TEXT, "
              " ${PetContract.breedColumn} TEXT, "
              " ${PetContract.ageColumn} INTEGER)",
        );
        await db.execute(
          "CREATE TABLE ${VaccineContract.vaccineTable}(${VaccineContract.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT, "
              " ${VaccineContract.petIdColumn} INTEGER, "
              " ${VaccineContract.nameColumn} TEXT, "
              " ${VaccineContract.dateColumn} TEXT, "
              " ${VaccineContract.nextDoseDateColumn} TEXT, "
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
      },
    );
  }
}