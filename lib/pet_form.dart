import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'pet.dart';

class PetForm extends StatefulWidget {
  final Pet? pet; // Pet opcional para edição

  PetForm({this.pet});

  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  final _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) { // Se um pet for fornecido, preenche os campos
      _nameController.text = widget.pet!.name;
      _speciesController.text = widget.pet!.species;
      _breedController.text = widget.pet!.breed;
      _ageController.text = widget.pet!.age.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pet == null ? 'Cadastrar Pet' : 'Editar Pet'), // Título dinâmico
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
              SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _speciesController,
                labelText: 'Espécie',
                icon: Icons.category,
              ),
              SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _breedController,
                labelText: 'Raça',
                icon: Icons.pets,
              ),
              SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _ageController,
                labelText: 'Idade',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final pet = Pet(
                      id: widget.pet?.id, // Mantém o ID se for edição
                      name: _nameController.text,
                      species: _speciesController.text,
                      breed: _breedController.text,
                      age: int.parse(_ageController.text),
                    );
                    if (widget.pet == null) {
                      await _databaseHelper.insertPet(pet);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pet cadastrado com sucesso!')),
                      );
                    } else {
                      await _databaseHelper.updatePet(pet);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pet atualizado com sucesso!')),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.pet == null ? 'Cadastrar' : 'Atualizar'), // Texto dinâmico
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
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
          return 'Por favor, insira $labelText.toLowerCase() do pet';
        }
        return null;
      },
    );
  }
}