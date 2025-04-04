import 'package:flutter/material.dart';
import '../../database/models/pet.dart';
import '.../../pet_form.dart';

class PetProfilePage extends StatelessWidget {
  final Pet pet;

  const PetProfilePage({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${pet.name} - Perfil'),
        backgroundColor: Colors.blue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/ed.jpg'),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nome', pet.name),
            _buildInfoRow('Espécie', pet.species),
            _buildInfoRow('Raça', pet.breed),
            _buildInfoRow('Sexo', pet.sex),
            _buildInfoRow('Idade', '${pet.age} anos'),
            if (pet.weight != null) _buildInfoRow('Peso', '${pet.weight} kg'),
            if (pet.allergy != null && pet.allergy!.isNotEmpty) _buildInfoRow('Alergia', pet.allergy!),
            if (pet.observations != null && pet.observations!.isNotEmpty) _buildInfoRow('Observações', pet.observations!),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetForm(pet: pet, isEditing: true), // Passa o pet existente para edição
            ),
          );
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.blue[300],
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