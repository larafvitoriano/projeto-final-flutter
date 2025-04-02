import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';
import '../contracts/medicine_contract.dart';
import '../helpers/database_helper.dart';
import '../../services/sync_service.dart';

class MedicineRepository {
  final DatabaseHelper databaseHelper;

  MedicineRepository(this.databaseHelper);

  final SyncService syncService = SyncService();

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await databaseHelper.database;
    try {
      int localId = await db.insert(MedicineContract.medicineTable, medicine.toMap());
      medicine.id = localId;
      await syncService.syncNewMedicine(medicine, localId);
      return localId;
    } catch (e) {
      print('Erro ao inserir medicamento: $e');
      return -1;
    }
  }

  Future<List<Medicine>> getMedicines() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(MedicineContract.medicineTable);
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.update(
        MedicineContract.medicineTable,
        medicine.toMap(),
        where: '${MedicineContract.idColumn} = ?',
        whereArgs: [medicine.id],
      );
      await syncService.syncUpdateMedicine(medicine);
      return result;
    } catch (e) {
      print('Erro ao atualizar medicamento: $e');
      return -1;
    }
  }

  Future<int> deleteMedicine(int id) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.delete(
        MedicineContract.medicineTable,
        where: '${MedicineContract.idColumn} = ?',
        whereArgs: [id],
      );
      await syncService.syncDeleteMedicine(id);
      return result;
    } catch (e) {
      print('Erro ao excluir medicamento: $e');
      return -1;
    }
  }

  Future<List<Medicine>> getMedicinesByPetId(int petId) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      MedicineContract.medicineTable,
      where: '${MedicineContract.petIdColumn} = ?',
      whereArgs: [petId],
    );
    return List.generate(maps.length, (i) => Medicine.fromMap(maps[i]));
  }
}
