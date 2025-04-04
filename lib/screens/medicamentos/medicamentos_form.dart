import 'package:flutter/material.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/models/medicine.dart';
import '../../database/models/pet.dart';
import 'package:intl/intl.dart';
import '../../database/repositories/medicine_repository.dart';

class MedicamentosForm extends StatefulWidget {
  final Pet pet;
  final Medicine? medicine;

  const MedicamentosForm({required this.pet, this.medicine, super.key});

  @override
  _MedicamentosFormState createState() => _MedicamentosFormState();
}

class _MedicamentosFormState extends State<MedicamentosForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  String? _selectedUnit;
  final _unitController = TextEditingController();
  final _administrationController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _notesController = TextEditingController();

  late MedicineRepository _medicineRepository;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _medicineRepository = MedicineRepository(DatabaseHelper());
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _dosageController.text = widget.medicine!.dosage.toString();
      _unitController.text = widget.medicine!.unit;
      _administrationController.text = widget.medicine!.administration;
      _frequencyController.text = widget.medicine!.frequency;
      _startDateController.text = widget.medicine!.startDate;
      _endDateController.text = widget.medicine?.endDate ?? '';
      _notesController.text = widget.medicine?.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _unitController.dispose();
    _administrationController.dispose();
    _frequencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Cadastrar Medicamento' : 'Editar Medicamento', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Anterior'),
                ),
              ),
            const SizedBox(width: 16.0),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentStep < 1) {
                    setState(() {
                      _currentStep++;
                    });
                  } else {
                    if (_formKey.currentState!.validate()) {
                      final medicine = Medicine(
                        id: widget.medicine?.id,
                        petId: widget.pet.id!,
                        name: _nameController.text,
                        dosage: double.parse(_dosageController.text),
                        unit: _unitController.text,
                        administration: _administrationController.text,
                        frequency: _frequencyController.text,
                        startDate: _startDateController.text,
                        endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
                        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                      );
                      if (widget.medicine == null) {
                        await _medicineRepository.insertMedicine(medicine);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medicamento cadastrado com sucesso!')),
                        );
                      } else {
                        await _medicineRepository.updateMedicine(medicine);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medicamento atualizado com sucesso!')),
                        );
                      }
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_currentStep < 1 ? 'Próximo' : (widget.medicine == null ? 'Cadastrar' : 'Atualizar')),
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
          _buildTextFormField(controller: _nameController, labelText: 'Nome', icon: Icons.medical_services),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded( // Adicionado Expanded aqui
                child: _buildTextFormField(
                  controller: _dosageController,
                  labelText: 'Dosagem',
                  icon: Icons.format_list_numbered,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded( // Adicionado Expanded aqui
                child: _buildUnitDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _administrationController, labelText: 'Via de Administração', icon: Icons.healing),
          // ... (outros campos)
        ],
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Flexible(
      flex: 1, // Simula o comportamento do Expanded
      child: DropdownButtonFormField<String>(
        isExpanded: true, // Adicionado isExpanded aqui
        value: _selectedUnit,
        items: <String>['mg', 'ml', 'cápsulas', 'comprimidos', 'gotas']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedUnit = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'Unidade',
          hintText: "Selecione a unidade",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue[300]!), borderRadius: BorderRadius.circular(8.0)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecione a unidade.';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAdditionalInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildTextFormField(controller: _frequencyController, labelText: 'Frequência', icon: Icons.timelapse),
          const SizedBox(height: 12.0),
          _buildDateFormField(controller: _startDateController, labelText: 'Data de Início', icon: Icons.calendar_today),
          const SizedBox(height: 12.0),
          _buildDateFormField(controller: _endDateController, labelText: 'Data de Término', icon: Icons.calendar_today),
          const SizedBox(height: 12.0),
          _buildTextFormField(controller: _notesController, labelText: 'Observações', icon: Icons.note, maxLines: 3),
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
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira $labelText.';
        }
        return null;
      },
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