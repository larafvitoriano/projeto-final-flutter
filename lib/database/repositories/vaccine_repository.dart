import 'package:sqflite/sqflite.dart';
import '../models/vaccine.dart';
import '../contracts/vaccine_contract.dart';
import '../helpers/database_helper.dart';
import '../../services/sync_service.dart';

class VaccineRepository {
  final DatabaseHelper databaseHelper;

  VaccineRepository(this.databaseHelper);

  final SyncService syncService = SyncService();

  Future<int> insertVaccine(Vaccine vaccine) async {
    final db = await databaseHelper.database;
    try {
      int localId = await db.insert(VaccineContract.vaccineTable, vaccine.toMap());
      vaccine.id = localId;
      await syncService.syncNewVaccine(vaccine, localId);
      return localId;
    } catch (e) {
      print('Erro ao inserir vacina: $e');
      return -1;
    }
  }

  Future<List<Vaccine>> getVaccinesForPet(int petId) async {
    final db = await databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        VaccineContract.vaccineTable,
        where: 'petId = ?',
        whereArgs: [petId],
      );
      return List.generate(maps.length, (i) => Vaccine.fromMap(maps[i]));
    } catch (e) {
      print('Erro ao consultar vacinas: $e');
      return [];
    }
  }

  Future<int> updateVaccine(Vaccine vaccine) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.update(
        VaccineContract.vaccineTable,
        vaccine.toMap(),
        where: '${VaccineContract.idColumn} = ?',
        whereArgs: [vaccine.id],
      );
      await syncService.syncUpdateVaccine(vaccine);
      return result;
    } catch (e) {
      print('Erro ao atualizar vacina: $e');
      return -1;
    }
  }

  Future<int> deleteVaccine(int id, int petId) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.delete(
        VaccineContract.vaccineTable,
        where: '${VaccineContract.idColumn} = ?',
        whereArgs: [id],
      );
      await syncService.syncDeleteVaccine(petId, id);
      return result;
    } catch (e) {
      print('Erro ao excluir vacina: $e');
      return -1;
    }
  }
}
