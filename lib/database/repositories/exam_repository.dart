import 'package:sqflite/sqflite.dart';
import '../contracts/exam_contract.dart';
import '../helpers/database_helper.dart';
import '../../services/sync_service.dart';
import '../models/exam.dart';

class ExamRepository {
  final DatabaseHelper databaseHelper;

  ExamRepository(this.databaseHelper);

  final SyncService syncService = SyncService();

  Future<int> insertExam(Exam exam) async {
    final db = await databaseHelper.database;
    try {
      int localId = await db.insert(ExamContract.examsTable, exam.toMap());
      exam.id = localId;
      await syncService.syncNewExam(exam, localId);
      return localId;
    } catch (e) {
      print('Erro ao inserir exame: $e');
      return -1;
    }
  }

  Future<List<Exam>> getExamsForPet(int petId) async {
    final db = await databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        ExamContract.examsTable,
        where: '${ExamContract.petIdColumn} = ?',
        whereArgs: [petId],
      );
      return List.generate(maps.length, (i) => Exam.fromMap(maps[i]));
    } catch (e) {
      print('Erro ao consultar exames do pet: $e');
      return [];
    }
  }

  Future<Exam?> getExamById(int id) async {
    final db = await databaseHelper.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query(
        ExamContract.examsTable,
        where: '${ExamContract.idColumn} = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Exam.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print('Erro ao consultar exame por ID: $e');
      return null;
    }
  }

  Future<int> updateExam(Exam exam) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.update(
        ExamContract.examsTable,
        exam.toMap(),
        where: '${ExamContract.idColumn} = ?',
        whereArgs: [exam.id],
      );
      await syncService.syncUpdateExam(exam);
      return result;
    } catch (e) {
      print('Erro ao atualizar exame: $e');
      return -1;
    }
  }

  Future<int> deleteExam(int id, int petId) async {
    final db = await databaseHelper.database;
    try {
      int result = await db.delete(
        ExamContract.examsTable,
        where: '${ExamContract.idColumn} = ? AND ${ExamContract.petIdColumn} = ?',
        whereArgs: [id, petId],
      );
      await syncService.syncDeleteExam(petId, id);
      return result;
    } catch (e) {
      print('Erro ao excluir exame: $e');
      return -1;
    }
  }
}