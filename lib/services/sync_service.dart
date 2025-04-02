import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/models/pet.dart';
import '../database/models/vaccine.dart';
import '../database/models/medicine.dart';
import '../database/repositories/pet_repository.dart';
import '../database/repositories/vaccine_repository.dart';
import '../database/repositories/medicine_repository.dart';
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
    await firestore.collection('users').doc(user.uid).collection('pets').add({
      'localId': localId,
      'name': pet.name,
      'species': pet.species,
      'breed': pet.breed,
      'age': pet.age,
    });
  }

  Future<void> syncUpdatePet(Pet pet) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || pet.id == null) return;
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .where('localId', isEqualTo: pet.id)
        .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await firestore.collection('users').doc(user.uid).collection('pets').doc(docId).update({
        'name': pet.name,
        'species': pet.species,
        'breed': pet.breed,
        'age': pet.age,
      });
    }
  }

  Future<void> syncDeletePet(int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .where('localId', isEqualTo: localId)
        .get();
    for (var doc in snapshot.docs) {
      await firestore.collection('users').doc(user.uid).collection('pets').doc(doc.id).delete();
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
        .doc(vaccine.petId.toString())
        .collection('vaccines')
        .add({
      'localId': localId,
      'name': vaccine.name,
      'date': vaccine.date,
      'nextDoseDate': vaccine.nextDoseDate,
    });
  }

  Future<void> syncUpdateVaccine(Vaccine vaccine) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || vaccine.id == null) return;
    QuerySnapshot snapshot = await firestore
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
      });
    }
  }

  Future<void> syncDeleteVaccine(int petLocalId, int vaccineLocalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot = await firestore
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
    await firestore.collection('users').doc(user.uid).collection('medicines').add({
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
    });
  }

  Future<void> syncUpdateMedicine(Medicine medicine) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || medicine.id == null) return;
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .where('localId', isEqualTo: medicine.id)
        .get();
    if (snapshot.docs.isNotEmpty) {
      String docId = snapshot.docs.first.id;
      await firestore.collection('users').doc(user.uid).collection('medicines').doc(docId).update({
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

  Future<void> syncDeleteMedicine(int localId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .where('localId', isEqualTo: localId)
        .get();
    for (var doc in snapshot.docs) {
      await firestore.collection('users').doc(user.uid).collection('medicines').doc(doc.id).delete();
    }
  }
  Future<void> downloadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Instancia os repositórios para inserção local
    final petRepository = PetRepository(DatabaseHelper());
    final vaccineRepository = VaccineRepository(DatabaseHelper());
    final medicineRepository = MedicineRepository(DatabaseHelper());

    // Primeiro, baixa os pets do Firestore
    final petSnapshots = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .get();

    for (var petDoc in petSnapshots.docs) {
      final data = petDoc.data();
      // Cria um objeto Pet (aqui, assumindo que 'localId' foi salvo no Firestore)
      Pet pet = Pet(
        id: data['localId'],
        name: data['name'],
        species: data['species'],
        breed: data['breed'],
        age: data['age'],
      );
      // Insere o pet no SQLite (se necessário, implemente verificação para evitar duplicatas)
      await petRepository.insertPet(pet);

      // Para cada pet, baixa as vacinas (supondo que cada vacina está em uma subcoleção "vaccines" no documento do pet)
      final vaccineSnapshots = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petDoc.id)
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
        );
        await vaccineRepository.insertVaccine(vaccine);
      }
    }

    // Baixa os medicamentos do Firestore (supondo que estão na coleção "medicines" no nível do usuário)
    final medicineSnapshots = await firestore
        .collection('users')
        .doc(user.uid)
        .collection('medicines')
        .get();
    for (var medDoc in medicineSnapshots.docs) {
      final mData = medDoc.data();
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
  }
}

