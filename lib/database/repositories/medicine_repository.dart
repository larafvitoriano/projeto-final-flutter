import 'package:sqflite/sqflite.dart';
import '../models/medicine.dart';
import '../contracts/medicine_contract.dart';
import '../helpers/database_helper.dart';

class MedicineRepository {
  final DatabaseHelper databaseHelper;

  MedicineRepository(this.databaseHelper);

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await databaseHelper.database;
    try {
      return await db.insert(MedicineContract.medicineTable, medicine.toMap());
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
      return await db.update(
        MedicineContract.medicineTable,
        medicine.toMap(),
        where: '${MedicineContract.idColumn} = ?',
        whereArgs: [medicine.id],
      );
    } catch (e) {
      print('Erro ao atualizar medicamento: $e');
      return -1;
    }
  }

  Future<int> deleteMedicine(int id) async {
    final db = await databaseHelper.database;
    try {
      return await db.delete(
        MedicineContract.medicineTable,
        where: '${MedicineContract.idColumn} = ?',
        whereArgs: [id],
      );
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