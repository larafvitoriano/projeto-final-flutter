import 'package:sqflite/sqflite.dart';
import '../models/vaccine.dart';
import '../contracts/vaccine_contract.dart';
import '../helpers/database_helper.dart';

class VaccineRepository {
  final DatabaseHelper databaseHelper;

  VaccineRepository(this.databaseHelper);

  Future<int> insertVaccine(Vaccine vaccine) async {
    final db = await databaseHelper.database;
    try {
      return await db.insert(VaccineContract.vaccineTable, vaccine.toMap());
    } catch (e) {
      print('Erro ao inserir vacina: $e');
      return -1;
    }
  }

  Future<List<Vaccine>> getVaccinesForPet(int petId) async {
    final db = await DatabaseHelper().database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        VaccineContract.vaccineTable,
        where: '${VaccineContract.petIdColumn} = ?',
        whereArgs: [petId],
      );
      return List.generate(maps.length, (i) => Vaccine.fromMap(maps[i]));
    } catch (e) {
      print('Erro ao consultar vacinas: $e');
      return []; // Retorna uma lista vazia em caso de erro.
    }
  }

  Future<int> updateVaccine(Vaccine vaccine) async {
    final db = await databaseHelper.database;
    try {
      return await db.update(
        VaccineContract.vaccineTable,
        vaccine.toMap(),
        where: '${VaccineContract.idColumn} = ?',
        whereArgs: [vaccine.id],
      );
    } catch (e) {
      print('Erro ao atualizar vacina: $e');
      return -1;
    }
  }

  Future<int> deleteVaccine(int id) async {
    final db = await databaseHelper.database;
    try {
      return await db.delete(
        VaccineContract.vaccineTable,
        where: '${VaccineContract.idColumn} = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao excluir vacina: $e');
      return -1;
    }
  }
}