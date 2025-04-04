import 'package:flutter/material.dart';
import 'dart:io';
import '../../database/models/pet.dart';
import '.../../pet_form.dart';

class PetProfilePage extends StatefulWidget {
  final Pet pet;

  const PetProfilePage({required this.pet, super.key});

  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name} - Perfil'),
        backgroundColor: Colors.blue[300],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Informações'),
            Tab(text: 'Detalhes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(widget.pet),
          _buildDetailsTab(widget.pet),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PetForm(pet: widget.pet, isEditing: true),
            ),
          );
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.blue[300],
      ),
    );
  }

  Widget _buildInfoTab(Pet pet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 100,
            backgroundImage: pet.pictureFile.isNotEmpty
                ? FileImage(File(pet.pictureFile))
                : null,
            backgroundColor: pet.pictureFile.isNotEmpty
                ? null
                : Colors.grey[200],
            child: pet.pictureFile.isNotEmpty
                ? null
                : const Icon(Icons.pets, size: 80, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Nome', pet.name),
          _buildInfoRow('Espécie', pet.species),
          _buildInfoRow('Raça', pet.breed),
          _buildInfoRow('Sexo', pet.sex),
          _buildInfoRow('Data de Nascimento', pet.birthDate),
          _buildInfoRow('Idade', '${pet.age}'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Pet pet) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (pet.weight != null) _buildInfoRow('Peso', '${pet.weight}'),
          if (pet.allergy != null && pet.allergy!.isNotEmpty)
            _buildInfoRow('Alergia', pet.allergy!),
          if (pet.notes != null && pet.notes!.isNotEmpty)
            _buildInfoRow('Observações', pet.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}