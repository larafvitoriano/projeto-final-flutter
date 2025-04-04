import 'package:flutter/material.dart';
import '../../database/models/pet.dart';
import 'vacinas_form.dart';
import '../../database/models/vaccine.dart';
import '../../database/repositories/vaccine_repository.dart';
import '../../database/helpers/database_helper.dart';

class VacinasPetPage extends StatefulWidget {
  final Pet pet;

  const VacinasPetPage({required this.pet, super.key});

  @override
  _VacinasPetPageState createState() => _VacinasPetPageState();
}

class _VacinasPetPageState extends State<VacinasPetPage> {
  late VaccineRepository _vaccineRepository;

  @override
  void initState() {
    super.initState();
    _vaccineRepository = VaccineRepository(DatabaseHelper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vacinas de ${widget.pet.name}'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<Vaccine>>(
        future: Future.delayed(Duration.zero, () async {
          try {
            return await _vaccineRepository.getVaccinesForPet(widget.pet.id!);
          } catch (e) {
            print('Erro ao recuperar vacinas: $e');
            throw e;
          }
        }),
        builder: (context, snapshot) {
          print('Recuperando vacinas para petId: ${widget.pet.id}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar as vacinas'));
          } else if (snapshot.hasData) {
            print('Vacinas recuperadas: ${snapshot.data}');
            final vaccines = snapshot.data!;
            return ListView.builder(
              itemCount: vaccines.length,
              itemBuilder: (context, index) {
                try {
                  return _buildVaccineCard(vaccines[index]);
                } catch (e) {
                  print('Erro ao construir card: $e');
                  return const Text('Erro ao exibir vacina');
                }
              },
            );
          } else {
            return const Center(child: Text('Nenhuma vacina cadastrada para este pet'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VacinasForm(pet: widget.pet)),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVaccineCard(Vaccine vaccine) {
    return GestureDetector( // Envolve o Card com GestureDetector
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VacinasForm(pet: widget.pet, vaccine: vaccine), // Passa a vacina para edição
          ),
        ).then((_) {
          setState(() {});
        });
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(context, vaccine);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.local_hospital, size: 40, color: Colors.blue[900]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      vaccine.name,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Data: ${vaccine.date}'),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.next_plan, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Próxima Dose: ${vaccine.nextDoseDate}'),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Vaccine vaccine) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Vacina'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja excluir esta vacina?'),
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
                await _vaccineRepository.deleteVaccine(vaccine.id!, widget.pet.id!);
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