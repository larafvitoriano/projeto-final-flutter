import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../contracts/pet_contract.dart';
import '../contracts/vaccine_contract.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
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
      },
    );
  }
}