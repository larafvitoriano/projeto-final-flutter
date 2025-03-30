import 'package:sqflite/sqflite.dart';
import '../models/pet.dart';
import '../contracts/pet_contract.dart';
import '../helpers/database_helper.dart';

class PetRepository {
  final DatabaseHelper databaseHelper;

  PetRepository(this.databaseHelper);

  Future<int> insertPet(Pet pet) async {
    final db = await databaseHelper.database;
    try {
      return await db.insert(PetContract.petTable, pet.toMap());
    } catch (e) {
      print('Erro ao inserir pet: $e');
      return -1;
    }
  }

  Future<List<Pet>> getPets() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(PetContract.petTable);
    return List.generate(maps.length, (i) => Pet.fromMap(maps[i]));
  }

  Future<int> updatePet(Pet pet) async {
    final db = await databaseHelper.database;
    try {
      return await db.update(
        PetContract.petTable,
        pet.toMap(),
        where: '${PetContract.idColumn} = ?',
        whereArgs: [pet.id],
      );
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      return -1;
    }
  }

  Future<int> deletePet(int id) async {
    final db = await databaseHelper.database;
    try {
      return await db.delete(
        PetContract.petTable,
        where: '${PetContract.idColumn} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao excluir pet: $e');
      return -1;
    }
  }
}