import 'package:flutter/material.dart';
import '../database/models/pet.dart';
import '../database/repositories/pet_repository.dart';
import '../database/helpers/database_helper.dart';

class PetForm extends StatefulWidget {
  final Pet? pet; // Pet opcional para edição

  const PetForm({this.pet, super.key});

  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  late PetRepository _petRepository;

  @override
  void initState() {
    super.initState();
    _petRepository = PetRepository(DatabaseHelper());
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _speciesController.text = widget.pet!.species;
      _breedController.text = widget.pet!.breed;
      _ageController.text = widget.pet!.age.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Cadastrar Pet' : 'Editar Pet'),
        backgroundColor: Colors.blue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Nome',
                icon: Icons.pets,
              ),
              const SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _speciesController,
                labelText: 'Espécie',
                icon: Icons.category,
              ),
              const SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _breedController,
                labelText: 'Raça',
                icon: Icons.pets,
              ),
              const SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _ageController,
                labelText: 'Idade',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final pet = Pet(
                      id: widget.pet?.id,
                      name: _nameController.text,
                      species: _speciesController.text,
                      breed: _breedController.text,
                      age: int.parse(_ageController.text),
                    );
                    if (widget.pet == null) {
                      await _petRepository.insertPet(pet);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pet cadastrado com sucesso!')),
                      );
                    } else {
                      await _petRepository.updatePet(pet);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pet atualizado com sucesso!')),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.pet == null ? 'Cadastrar' : 'Atualizar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira $labelText do pet';
        }
        return null;
      },
    );
  }
}