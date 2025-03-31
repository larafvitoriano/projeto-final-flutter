import 'package:flutter/material.dart';

import '../database/helpers/database_helper.dart';
import '../database/models/medicine.dart';
import '../database/models/pet.dart';
import '../database/repositories/medicine_repository.dart';
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
        title: Text('Medicamentos de ${widget.pet.name}'),
        backgroundColor: Colors.orange[300],
      ),
      body: FutureBuilder<List<Medicine>>(
        future: Future.delayed(Duration.zero, () async {
          try {
            return await _medicineRepository.getMedicinesByPetId(widget.pet.id!);
          } catch (e) {
            print('Erro ao recuperar medicamentos: $e');
            throw e;
          }
        }),
        builder: (context, snapshot) {
          print('Recuperando medicamentos para petId: ${widget.pet.id}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os medicamentos'));
          } else if (snapshot.hasData) {
            print('Medicamentos recuperados: ${snapshot.data}');
            final medicines = snapshot.data!;
            return ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                try {
                  return _buildMedicineCard(medicines[index]);
                } catch (e) {
                  print('Erro ao construir card: $e');
                  return const Text('Erro ao exibir medicamento');
                }
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
        child: const Icon(Icons.add),
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
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                medicine.name,
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text('Dosagem: ${medicine.dosage} ${medicine.unit}'),
              Text('Frequência: ${medicine.frequency}'),
              Text('Via de Administração: ${medicine.administration}'),
              Text('Data de Início: ${medicine.startDate}'),
              if (medicine.endDate != null) Text('Data de Término: ${medicine.endDate}'),
              if (medicine.notes != null) Text('Notas: ${medicine.notes}'),
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
          title: const Text('Excluir Medicamento'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja excluir este medicamento?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async {
                await _medicineRepository.deleteMedicine(medicine.id!);
                setState(() {}); // Atualiza a lista após a exclusão
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}