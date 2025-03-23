import 'package:sqflite/sqflite.dart';
import 'pet.dart';
import 'pet_contract.dart';
import 'package:path/path.dart';

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
      },
    );
  }

  Future<int> insertPet(Pet pet) async {
    final db = await database;
    return db.insert(PetContract.petTable, pet.toMap());
  }

  Future<List<Pet>> getPets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      PetContract.petTable,
    );
    return List.generate(maps.length, (i) {
      return Pet.fromMap(maps[i]);
    });
  }

  Future<int> updatePet(Pet pet) async {
    final db = await database;
    return db.update(
      PetContract.petTable,
      pet.toMap(),
      where: '${PetContract.idColumn} = ?',
      whereArgs: [pet.id],
    );
  }

  Future<int> deletePet(int id) async {
    final db = await database;
    return db.delete(
      PetContract.petTable,
      where: '${PetContract.idColumn} = ?',
      whereArgs: [id],
    );
  }
}
