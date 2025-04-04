import 'package:flutter/material.dart';
import '../../database/models/pet.dart';
import '../../database/repositories/pet_repository.dart';
import '../../database/helpers/database_helper.dart';

class PetForm extends StatefulWidget {
  final Pet? pet; // Pet opcional para edição
  final bool isEditing;

  const PetForm({this.pet, this.isEditing = false, super.key});

  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergyController = TextEditingController();
  final _observationsController = TextEditingController();

  late PetRepository _petRepository;
  int _currentStep = 0; // Etapa atual
  String _sex = 'Macho'; // Valor padrão

  @override
  void initState() {
    super.initState();
    _petRepository = PetRepository(DatabaseHelper());
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _speciesController.text = widget.pet!.species;
      _breedController.text = widget.pet!.breed;
      _sex = widget.pet!.sex ?? 'Macho'; // Define o sexo existente ou padrão
      _ageController.text = widget.pet!.age.toString();
      _weightController.text = widget.pet!.weight?.toString() ?? '';
      _allergyController.text = widget.pet!.allergy ?? '';
      _observationsController.text = widget.pet!.observations ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _allergyController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Pet' : 'Cadastrar Pet'),
        backgroundColor: Colors.blue[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: _buildStep(_currentStep),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (_currentStep > 0)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                child: const Text('Anterior'),
              ),
            ElevatedButton(
              onPressed: () async {
                if (_currentStep < 1) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  if (_formKey.currentState!.validate()) {
                    final pet = Pet(
                      id: widget.isEditing ? widget.pet?.id : null,
                      name: _nameController.text,
                      species: _speciesController.text,
                      breed: _breedController.text,
                      sex: _sex,
                      age: int.parse(_ageController.text),
                      weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
                      allergy: _allergyController.text,
                      observations: _observationsController.text,
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
                    Navigator.pop(context, pet);
                  }
                }
              },
              child: Text(_currentStep < 1 ? 'Próximo' : (widget.isEditing ? 'Atualizar' : 'Cadastrar')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildAdditionalInfoStep();
      default:
        return Container();
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
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
          _buildSexRadioButtons(),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildTextFormField(
            controller: _ageController,
            labelText: 'Idade',
            icon: Icons.calendar_today,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12.0),
          _buildTextFormField(
            controller: _weightController,
            labelText: 'Peso',
            icon: Icons.balance,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12.0),
          _buildTextFormField(
            controller: _allergyController,
            labelText: 'Alergia',
            icon: Icons.warning,
          ),
          const SizedBox(height: 12.0),
          _buildTextFormField(
            controller: _observationsController,
            labelText: 'Observações',
            icon: Icons.description,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
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
      maxLines: maxLines ?? 1,
      validator: (value) {
        if (value == null || value.isEmpty && labelText != 'Alergia' && labelText != 'Observações' && labelText != 'Peso') {
          return 'Por favor, insira $labelText do pet';
        }
        return null;
      },
    );
  }

  Widget _buildSexRadioButtons() {
    return Row(
      children: <Widget>[
        const Text('Sexo: '),
        Radio<String>(
          value: 'Macho',
          groupValue: _sex,
          onChanged: (String? value) {
            setState(() {
              _sex = value!;
            });
          },
        ),
        const Text('Macho'),
        Radio<String>(
          value: 'Fêmea',
          groupValue: _sex,
          onChanged: (String? value) {
            setState(() {
              _sex = value!;
            });
          },
        ),
        const Text('Fêmea'),
      ],
    );
  }
}
