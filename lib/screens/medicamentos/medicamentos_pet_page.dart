import 'package:flutter/material.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/models/medicine.dart';
import '../../database/models/pet.dart';
import '../../database/repositories/medicine_repository.dart';
import 'medicamentos_form.dart';

class MedicamentosPetPage extends StatefulWidget {
  final Pet pet;

  const MedicamentosPetPage({required this.pet, super.key});

  @override
  _MedicamentosPetPageState createState() => _MedicamentosPetPageState();
}

class _MedicamentosPetPageState extends State<MedicamentosPetPage> {
  late MedicineRepository _medicineRepository;

  @override
  void initState() {
    super.initState();
    _medicineRepository = MedicineRepository(DatabaseHelper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicamentos de ${widget.pet.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[300],
        elevation: 2,
      ),
      body: FutureBuilder<List<Medicine>>(
        future: _medicineRepository.getMedicinesByPetId(widget.pet.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os medicamentos'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final medicines = snapshot.data!;
            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return _buildMedicineCard(medicines[index]);
              },
            );
          } else {
            return const Center(child: Text('Nenhum medicamento cadastrado para este pet'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MedicamentosForm(pet: widget.pet)),
          ).then((_) {
            setState(() {});
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicamentosForm(pet: widget.pet, medicine: medicine),
          ),
        ).then((_) {
          setState(() {});
        });
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(context, medicine);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                medicine.name,
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.medical_services, color: Colors.grey, size: 18),
                  const SizedBox(width: 5),
                  Text('Dosagem: ${medicine.dosage} ${medicine.unit}'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                  const SizedBox(width: 5),
                  Text('Início: ${medicine.startDate}'),
                ],
              ),
              if (medicine.endDate != null)
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
                    const SizedBox(width: 5),
                    Text('Término: ${medicine.endDate}'),
                  ],
                ),
              if (medicine.notes != null)
                Row(
                  children: [
                    const Icon(Icons.notes, color: Colors.grey, size: 18),
                    const SizedBox(width: 5),
                    Text('Notas: ${medicine.notes}'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Medicine medicine) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Medicamento', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja excluir este medicamento?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _medicineRepository.deleteMedicine(medicine.id!, medicine.petId);
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}