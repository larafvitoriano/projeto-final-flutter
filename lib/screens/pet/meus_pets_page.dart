import 'dart:io';

import 'package:flutter/material.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/models/pet.dart';
import '../../database/repositories/pet_repository.dart';
import 'pet_form.dart';
import 'pet_actions.dart';

class MeusPetsPage extends StatefulWidget {
  @override
  _MeusPetsPageState createState() => _MeusPetsPageState();
}

class _MeusPetsPageState extends State<MeusPetsPage> {
  late PetRepository _petRepository;
  late Future<List<Pet>> _petsFuture; // Armazena o Future

  @override
  void initState() {
    super.initState();
    _petRepository = PetRepository(DatabaseHelper());
    _petsFuture = _petRepository.getPets();
  }

  // Função para atualizar o Future
  void _refreshPets() {
    setState(() {
      _petsFuture = _petRepository.getPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Pets'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<Pet>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os pets'));
          } else if (snapshot.hasData) {
            final pets = snapshot.data!;
            if (pets.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Nenhum pet cadastrado. Clique no botão para cadastrar um pet.',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  return _buildPetCard(pets[index]);
                },
              );
            }
          } else {
            return const Center(child: Text('Erro ao carregar os pets'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PetForm()),
          ).then((_) {
            _refreshPets();
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
          MaterialPageRoute(builder: (context) => PetActions(pet: pet)),
        ).then((_) {
          _refreshPets();
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
              _buildPetImage(pet),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pet.name,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Text(pet.species),
                  Text(pet.sex),
                  Text(pet.breed),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(Pet pet) {
    if (pet.pictureFile.isNotEmpty) {
      return Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(File(pet.pictureFile)),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[300],
        ),
        child: const Icon(Icons.pets, size: 40, color: Colors.white),
      );
    }
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
                _refreshPets();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pet excluído com sucesso!')),
                  );
              },
            ),
          ],
        );
      },
    );
  }
}