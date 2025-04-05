import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/models/exam.dart';
import '../database/models/pet.dart';
import '../database/models/vaccine.dart';
import '../database/models/medicine.dart';
import '../database/models/evolution.dart';
import '../database/repositories/exam_repository.dart';
import '../database/repositories/pet_repository.dart';
import '../database/repositories/vaccine_repository.dart';
import '../database/repositories/medicine_repository.dart';
import '../database/repositories/evolution_repository.dart';
import '../database/helpers/database_helper.dart';

class SyncService {
  // Singleton: cria uma única instância
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // --- PET ---
  Future<void> syncNewPet(Pet pet, int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(localId.toString()) // Usa o ID fixo (localId)
        .set({
          'localId': localId,
          'pictureFile': pet.pictureFile,
          'name': pet.name,
          'species': pet.species,
          'breed': pet.breed,
          'sex': pet.sex,
          'birthDate': pet.birthDate,
          'age': pet.age,
          'weight': pet.weight,
          'allergy': pet.allergy,
          'notes': pet.notes,
        }, SetOptions(merge: true));
  }

  Future<void> syncUpdatePet(Pet pet) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || pet.id == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .where('localId', isEqualTo: pet.id)
            .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(docId)
          .update({
            'pictureFile': pet.pictureFile,
            'name': pet.name,
            'species': pet.species,
            'breed': pet.breed,
            'sex': pet.sex,
            'birthDate': pet.birthDate,
            'age': pet.age,
            'weight': pet.weight,
            'allergy': pet.allergy,
            'notes': pet.notes,
          });
    }
  }

  Future<void> syncDeletePet(int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot petSnapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .where('localId', isEqualTo: localId)
            .get();
    for (var petDoc in petSnapshot.docs) {
      // Excluir vacinas (já existente) ...
      QuerySnapshot vaccineSnapshot =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id)
              .collection('vaccines')
              .get();
      for (var vDoc in vaccineSnapshot.docs) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petDoc.id)
            .collection('vaccines')
            .doc(vDoc.id)
            .delete();
      }

      // Excluir medicamentos
      QuerySnapshot medicineSnapshot =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id)
              .collection('medicines')
              .get();
      for (var mDoc in medicineSnapshot.docs) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petDoc.id)
            .collection('medicines')
            .doc(mDoc.id)
            .delete();
      }

      // Excluir exames
      QuerySnapshot examsSnapshot =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id)
              .collection('exams')
              .get();
      for (var eDoc in examsSnapshot.docs) {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petDoc.id)
            .collection('exams')
            .doc(eDoc.id)
            .delete();
      }

      // Excluir o pet
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petDoc.id)
          .delete();
    }
  }

  // --- VACCINE ---
  Future<void> syncNewVaccine(Vaccine vaccine, int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(vaccine.petId.toString()) // O petId usado como doc do pet
        .collection('vaccines')
        .doc(localId.toString()) // Usa o ID fixo da vacina
        .set({
          'localId': localId,
          'name': vaccine.name,
          'date': vaccine.date,
          'nextDoseDate': vaccine.nextDoseDate,
          'notes': vaccine.notes,
        }, SetOptions(merge: true));
  }

  Future<void> syncUpdateVaccine(Vaccine vaccine) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || vaccine.id == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(vaccine.petId.toString())
            .collection('vaccines')
            .where('localId', isEqualTo: vaccine.id)
            .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(vaccine.petId.toString())
          .collection('vaccines')
          .doc(docId)
          .update({
            'name': vaccine.name,
            'date': vaccine.date,
            'nextDoseDate': vaccine.nextDoseDate,
            'notes': vaccine.notes,
          });
    }
  }

  Future<void> syncDeleteVaccine(int petLocalId, int vaccineLocalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petLocalId.toString())
            .collection('vaccines')
            .where('localId', isEqualTo: vaccineLocalId)
            .get();
    for (var doc in snapshot.docs) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petLocalId.toString())
          .collection('vaccines')
          .doc(doc.id)
          .delete();
    }
  }

  // --- MEDICINE ---
  Future<void> syncNewMedicine(Medicine medicine, int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(medicine.petId.toString()) // O documento do pet
        .collection('medicines')
        .doc(localId.toString()) // Define o ID fixo para o medicamento
        .set({
          'localId': localId,
          'petId': medicine.petId,
          'name': medicine.name,
          'dosage': medicine.dosage,
          'unit': medicine.unit,
          'administration': medicine.administration,
          'frequency': medicine.frequency,
          'startDate': medicine.startDate,
          'endDate': medicine.endDate,
          'notes': medicine.notes,
        }, SetOptions(merge: true));
  }

  Future<void> syncUpdateMedicine(Medicine medicine) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || medicine.id == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('medicines')
            .where('localId', isEqualTo: medicine.id)
            .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(medicine.petId.toString())
          .collection('medicines')
          .doc(docId)
          .update({
            'petId': medicine.petId,
            'name': medicine.name,
            'dosage': medicine.dosage,
            'unit': medicine.unit,
            'administration': medicine.administration,
            'frequency': medicine.frequency,
            'startDate': medicine.startDate,
            'endDate': medicine.endDate,
            'notes': medicine.notes,
          });
    }
  }

  Future<void> syncDeleteMedicine(int petLocalId, int medicineLocalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petLocalId.toString())
            .collection('medicines')
            .where('localId', isEqualTo: medicineLocalId)
            .get();
    for (var doc in snapshot.docs) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petLocalId.toString())
          .collection('medicines')
          .doc(doc.id)
          .delete();
    }
  }

  // --- EVOLUTIONS ---
  // Sincroniza a criação de um registro de evolução para um pet
  Future<void> syncNewEvolution(Evolution evolution, int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(
          evolution.petId.toString(),
        ) // O documento do pet (usando o ID local do pet convertido para string)
        .collection('evolutions')
        .doc(
          localId.toString(),
        ) // Usa o localId do registro de evolução como ID fixo
        .set({
          'localId': localId,
          'petId': evolution.petId,
          'weight': evolution.weight,
          'date': evolution.date,
          'notes': evolution.notes,
        }, SetOptions(merge: true));
  }

  // Atualiza um registro de evolução já existente
  Future<void> syncUpdateEvolution(Evolution evolution) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || evolution.id == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(evolution.petId.toString())
            .collection('evolutions')
            .where('localId', isEqualTo: evolution.id)
            .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(evolution.petId.toString())
          .collection('evolutions')
          .doc(docId)
          .update({
            'weight': evolution.weight,
            'date': evolution.date,
            'notes': evolution.notes,
          });
    }
  }

  // Exclui um registro de evolução
  Future<void> syncDeleteEvolution(int petLocalId, int evolutionLocalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petLocalId.toString())
            .collection('evolutions')
            .where('localId', isEqualTo: evolutionLocalId)
            .get();
    for (var doc in snapshot.docs) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petLocalId.toString())
          .collection('evolutions')
          .doc(doc.id)
          .delete();
    }
  }

  // --- EXAMS ---
  Future<void> syncNewExam(Exam exam, int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(exam.petId.toString())
        .collection('exams')
        .doc(localId.toString())
        .set({
          'localId': localId,
          'petId': exam.petId,
          'name': exam.name,
          'date': exam.date,
          'pdfFile': exam.pdfFile,
          'notes': exam.notes,
        }, SetOptions(merge: true));
  }

  Future<void> syncUpdateExam(Exam exam) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || exam.id == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(exam.petId.toString())
            .collection('exams')
            .where('localId', isEqualTo: exam.id)
            .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(exam.petId.toString())
          .collection('exams')
          .doc(docId)
          .update({
            'name': exam.name,
            'date': exam.date,
            'pdfFile': exam.pdfFile,
            'notes': exam.notes,
          });
    }
  }

  Future<void> syncDeleteExam(int petLocalId, int examLocalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .doc(petLocalId.toString())
            .collection('exams')
            .where('localId', isEqualTo: examLocalId)
            .get();
    for (var doc in snapshot.docs) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petLocalId.toString())
          .collection('exams')
          .doc(doc.id)
          .delete();
    }
  }

  Future<void> downloadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Limpa os dados locais antes de sincronizar os novos
    await DatabaseHelper().clearDatabase();

    // Instancia os repositórios para inserção local
    final petRepository = PetRepository(DatabaseHelper());
    final vaccineRepository = VaccineRepository(DatabaseHelper());
    final medicineRepository = MedicineRepository(DatabaseHelper());
    final evolutionRepository = EvolutionRepository(DatabaseHelper());
    final examRepository = ExamRepository(DatabaseHelper());

    // Primeiro, baixa os pets do Firestore
    final petSnapshots =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('pets')
            .get();

    for (var petDoc in petSnapshots.docs) {
      final data = petDoc.data();
      Pet pet = Pet(
        id: data['localId'],
        pictureFile: data['pictureFile'],
        name: data['name'],
        species: data['species'],
        breed: data['breed'],
        sex: data['sex'],
        birthDate: data['birthDate'],
        age: data['age'],
        weight: data['weight'],
        allergy: data['allergy'],
        notes: data['notes'],
      );
      await petRepository.insertPet(pet);

      // Vacinas
      final vaccineSnapshots =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id) // aqui, petDoc é definido no loop
              .collection('vaccines')
              .get();
      for (var vDoc in vaccineSnapshots.docs) {
        final vData = vDoc.data();
        Vaccine vaccine = Vaccine(
          id: vData['localId'],
          petId: pet.id!, // usa o id local do pet
          name: vData['name'],
          date: vData['date'],
          nextDoseDate: vData['nextDoseDate'],
          notes: vData['notes'],
        );
        await vaccineRepository.insertVaccine(vaccine);
      }

      // Medicamentos
      final medicineSnapshots =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id) // petDoc é definido no loop
              .collection('medicines')
              .get();
      for (var mDoc in medicineSnapshots.docs) {
        final mData = mDoc.data();
        Medicine medicine = Medicine(
          id: mData['localId'],
          petId: mData['petId'],
          name: mData['name'],
          dosage: mData['dosage'],
          unit: mData['unit'],
          administration: mData['administration'],
          frequency: mData['frequency'],
          startDate: mData['startDate'],
          endDate: mData['endDate'],
          notes: mData['notes'],
        );
        await medicineRepository.insertMedicine(medicine);
      }
      final evolutionSnapshots =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id) // petDoc definido no loop
              .collection('evolutions')
              .get();
      for (var evoDoc in evolutionSnapshots.docs) {
        final evoData = evoDoc.data();
        Evolution evolution = Evolution(
          id: evoData['localId'], // campo salvo no Firestore
          petId: evoData['petId'],
          weight: evoData['weight'],
          date: evoData['date'],
          notes: evoData['notes'],
        );
        await evolutionRepository.insertEvolution(evolution);
      }

      //Exams
      final examSnapshots =
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('pets')
              .doc(petDoc.id)
              .collection('exams')
              .get();
      for (var exDoc in examSnapshots.docs) {
        final exData = exDoc.data();
        Exam exam = Exam(
          id: exData['localId'],
          petId: exData['petId'],
          name: exData['name'],
          date: exData['date'],
          pdfFile: List<int>.from(exData['pdfFile']),
          notes: exData['notes'],
        );
        await examRepository.insertExam(exam);
      }
    }
  }
}
