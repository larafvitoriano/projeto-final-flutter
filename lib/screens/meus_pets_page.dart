import 'package:flutter/material.dart';
import '../database/helpers/database_helper.dart';
import '../database/models/pet.dart';
import '../database/repositories/pet_repository.dart';
import 'pet_form.dart';
import 'pet_details.dart';

class MeusPetsPage extends StatefulWidget {
  @override
  _MeusPetsPageState createState() => _MeusPetsPageState();
}

class _MeusPetsPageState extends State<MeusPetsPage> {
  late PetRepository _petRepository;

  @override
  void initState() {
    super.initState();
    _petRepository = PetRepository(DatabaseHelper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<Pet>>(
        future: _petRepository.getPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os pets'));
          } else if (snapshot.hasData) {
            final pets = snapshot.data!;
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                return _buildPetCard(pets[index]);
              },
            );
          } else {
            return const Center(child: Text('Nenhum pet cadastrado'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PetForm()),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetails(pet: pet)),
        ).then((_) {
          setState(() {});
        });
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(context, pet);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                color: Colors.grey[300],
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pet.name,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Text(pet.species),
                  Text(pet.breed),
                  Text('${pet.age} anos'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Pet'),
          content: Text('Deseja realmente excluir ${pet.name}?'),
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
                await _petRepository.deletePet(pet.id!);
                Navigator.of(context).pop();
                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pet excluído com sucesso!')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}