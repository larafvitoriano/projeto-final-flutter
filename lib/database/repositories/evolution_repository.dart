import 'package:sqflite/sqflite.dart';
import '../models/evolution.dart';
import '../contracts/evolution_contract.dart';
import '../helpers/database_helper.dart';
import '../../services/sync_service.dart';

class EvolutionRepository {
  final DatabaseHelper databaseHelper;
  final SyncService syncService = SyncService();

  EvolutionRepository(this.databaseHelper);

  Future<int> insertEvolution(Evolution evolution) async {
    final db = await databaseHelper.database;
    try {
      int localId = await db.insert(EvolutionContract.evolutionTable, evolution.toMap());
      evolution.id = localId;
      await SyncService().syncNewEvolution(evolution, localId);
      return localId;
    } catch (e) {
      print('Erro ao inserir evolução: $e');
      return -1;
    }
  }

  Future<List<Evolution>> getEvolutionsByPetId(int petId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      EvolutionContract.evolutionTable,
      where: '${EvolutionContract.petIdColumn} = ?',
      whereArgs: [petId],
      orderBy: EvolutionContract.dateColumn + " ASC", // ordenar por data ascendente
    );
    return maps.map((map) => Evolution.fromMap(map)).toList();
  }

  Future<int> updateEvolution(Evolution evolution) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.update(
        EvolutionContract.evolutionTable,
        evolution.toMap(),
        where: '${EvolutionContract.idColumn} = ?',
        whereArgs: [evolution.id],
      );
      await SyncService().syncUpdateEvolution(evolution);
      return result;
    } catch (e) {
      print('Erro ao atualizar evolução: $e');
      return -1;
    }
  }

  Future<int> deleteEvolution(int id, int petId) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.delete(
        EvolutionContract.evolutionTable,
        where: '${EvolutionContract.idColumn} = ?',
        whereArgs: [id],
      );
      await SyncService().syncDeleteEvolution(petId, id);
      return result;
    } catch (e) {
      print('Erro ao excluir evolução: $e');
      return -1;
    }
  }
}
