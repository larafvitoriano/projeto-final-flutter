import 'package:flutter/material.dart';
import 'dart:io';
import '../../database/models/pet.dart';
import '.../../pet_form.dart';
import 'package:intl/intl.dart';

class PetProfilePage extends StatefulWidget {
  final Pet pet;

  const PetProfilePage({required this.pet, super.key});

  @override
  _PetProfilePageState createState() => _PetProfilePageState();
}

class _PetProfilePageState extends State<PetProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pet = widget.pet;
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
        title: Text('${_pet.name} - Perfil'),
        backgroundColor: Colors.blue[300],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: 'Informações'),
            Tab(text: 'Detalhes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(_pet),
          _buildDetailsTab(_pet),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedPet = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetForm(pet: _pet, isEditing: true),
            ),
          );
          if (updatedPet != null) {
            setState(() {
              _pet = updatedPet;
            });
          }
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.blue[300],
      ),
    );
  }

  Widget _buildInfoTab(Pet pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundImage: _pet.pictureFile.isNotEmpty
                  ? FileImage(File(_pet.pictureFile))
                  : null,
              backgroundColor: _pet.pictureFile.isNotEmpty
                  ? null
                  : Colors.grey[200],
              child: _pet.pictureFile.isNotEmpty
                  ? null
                  : const Icon(Icons.pets, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Center(child: _buildInfoCard('Nome', _pet.name)),
          Center(child: _buildInfoCard('Espécie', _pet.species)),
          Center(child: _buildInfoCard('Raça', _pet.breed)),
          Center(child: _buildInfoCard('Sexo', _pet.sex)),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Pet pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(child: _buildInfoCard('Idade', _calculateAge(_pet.birthDate))),
          if (_pet.weight != null) Center(child: _buildInfoCard('Peso', _formatWeight(_pet.weight!))),
          if (_pet.allergy != null && _pet.allergy!.isNotEmpty)
            Center(child: _buildInfoCard('Alergia', _pet.allergy!)),
          if (_pet.notes != null && _pet.notes!.isNotEmpty)
            Center(child: _buildInfoCard('Observações', _pet.notes!)),
          Center(child: _buildInfoCard('Data de Nascimento', _pet.birthDate)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateAge(String birthDate) {
    if (birthDate.isEmpty) return 'Idade desconhecida';

    DateTime birth = DateFormat('dd/MM/yyyy').parse(birthDate);
    DateTime today = DateTime.now();

    int years = today.year - birth.year;
    int months = today.month - birth.month;
    int days = today.day - birth.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += (days < 0 ? 11 : 12);
    }

    if (years > 0) {
      return '$years ano(s)';
    } else {
      return '$months mes(es)';
    }
  }

  String _formatWeight(double weight) {
    if (weight >= 1.0) {
      return '${weight.toStringAsFixed(2)} kg';
    } else {
      return '${(weight * 1000).toStringAsFixed(0)} g';
    }
  }
}