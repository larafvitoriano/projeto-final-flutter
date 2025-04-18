import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/models/pet.dart';
import '../../database/repositories/pet_repository.dart';
import '../../database/helpers/database_helper.dart';

class PetForm extends StatefulWidget {
  final Pet? pet;
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
  final _birthDateController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergyController = TextEditingController();
  final _notesController = TextEditingController();
  File? _image;

  late PetRepository _petRepository;
  int _currentStep = 0;
  String _sex = 'Macho';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _petRepository = PetRepository(DatabaseHelper());
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _speciesController.text = widget.pet!.species;
      _breedController.text = widget.pet!.breed;
      _sex = widget.pet!.sex ?? 'Macho';
      _birthDateController.text = widget.pet!.birthDate;
      _weightController.text = widget.pet!.weight?.toString() ?? '';
      _allergyController.text = widget.pet!.allergy ?? '';
      _notesController.text = widget.pet!.notes ?? '';
      if (widget.pet!.pictureFile.isNotEmpty) {
        _image = File(widget.pet!.pictureFile);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _birthDateController.dispose();
    _weightController.dispose();
    _allergyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma data';
    }
    final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Formato de data inválido (dd/MM/yyyy)';
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      controller.text = formattedDate;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Pet' : 'Cadastrar Pet', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[300],
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: _buildStep(_currentStep),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            if (_currentStep > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 16.0), // Aumenta o padding vertical
                  ),
                  child: const Text('Anterior'),
                ),
              ),
            const SizedBox(width: 16.0), // Espaço entre os botões
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentStep < 1) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                      final pet = Pet(
                        id: widget.isEditing ? widget.pet?.id : null,
                        pictureFile: _image?.path ?? '',
                        name: _nameController.text,
                        species: _speciesController.text,
                        breed: _breedController.text,
                        sex: _sex,
                        birthDate: _birthDateController.text,
                        weight: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : null,
                        allergy: _allergyController.text,
                        notes: _notesController.text,
                      );

                      try {
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
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                        Navigator.of(context).pop();
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 16.0), // Aumenta o padding vertical
                ),
                child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : Text(_currentStep < 1 ? 'Próximo' : (widget.isEditing ? 'Atualizar' : 'Cadastrar')),
              ),
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
          _buildImageStep(),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _nameController, labelText: 'Nome', icon: Icons.pets),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _speciesController, labelText: 'Espécie', icon: Icons.category),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _breedController, labelText: 'Raça', icon: Icons.pets),
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
          _buildDateFormField(controller: _birthDateController, labelText: 'Data de Nascimento', icon: Icons.calendar_today),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _weightController, labelText: 'Peso', icon: Icons.balance, keyboardType: TextInputType.number),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _allergyController, labelText: 'Alergia', icon: Icons.warning),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _notesController, labelText: 'Observações', icon: Icons.description, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildTextFormField({required TextEditingController controller, required String labelText, required IconData icon, TextInputType? keyboardType, int? maxLines}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue[300]!), borderRadius: BorderRadius.circular(8.0)),
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

  Widget _buildImageStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: _image != null ? Image.file(_image!, fit: BoxFit.cover) : const Center(child: Text('Toque para adicionar uma imagem')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSexRadioButtons() {
    return Row(
      children: <Widget>[
        const Text('Sexo: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Radio<String>(value: 'Macho', groupValue: _sex, onChanged: (String? value) { setState(() { _sex = value!; }); }, activeColor: Colors.blue[300]),
        const Text('Macho'),
        Radio<String>(value: 'Fêmea', groupValue: _sex, onChanged: (String? value) { setState(() { _sex = value!; }); }, activeColor: Colors.blue[300]),
        const Text('Fêmea'),
      ],
    );
  }

  Widget _buildDateFormField({required TextEditingController controller, required String labelText, required IconData icon}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue[300]!), borderRadius: BorderRadius.circular(8.0)),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      validator: _validateDate,
    );
  }
}