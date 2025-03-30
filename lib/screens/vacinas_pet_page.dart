import 'package:flutter/material.dart';
import '../database/models/pet.dart';
import 'vacinas_form.dart';
import '../database/models/vaccine.dart';
import '../database/repositories/vaccine_repository.dart';
import '../database/helpers/database_helper.dart';

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
        future: Future.delayed(Duration.zero, () async { // Adicionando Future.delayed para garantir que o try-catch seja executado no futuro
          try {
            return await _vaccineRepository.getVaccinesForPet(widget.pet.id!);
          } catch (e) {
            print('Erro ao recuperar vacinas: $e');
            throw e; // Relança a exceção para que o FutureBuilder a capture
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
                  return Text('Erro ao exibir vacina'); // ou um widget de erro
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
    return Card(
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
    );
  }
}