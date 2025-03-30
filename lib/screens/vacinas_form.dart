import 'package:flutter/material.dart';
import '../database/models/vaccine.dart';
import 'package:intl/intl.dart';
import '../database/models/pet.dart';
import '../database/repositories/vaccine_repository.dart';
import '../database/helpers/database_helper.dart';

class VacinasForm extends StatefulWidget {
  final Pet pet;

  const VacinasForm({required this.pet, super.key});

  @override
  _VacinasFormState createState() => _VacinasFormState();
}

class _VacinasFormState extends State<VacinasForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _nextDoseDateController = TextEditingController();

  late VaccineRepository _vaccineRepository;

  @override
  void initState() {
    super.initState();
    _vaccineRepository = VaccineRepository(DatabaseHelper());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _nextDoseDateController.dispose();
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
      locale: const Locale('pt', 'BR'), // Configura o locale para português do Brasil
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
        title: const Text('Cadastrar Vacina'),
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
                labelText: 'Nome da Vacina',
                icon: Icons.local_hospital,
              ),
              const SizedBox(height: 12.0),
              _buildDateFormField(
                controller: _dateController,
                labelText: 'Data da Vacinação',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12.0),
              _buildDateFormField(
                controller: _nextDoseDateController,
                labelText: 'Próxima Dose',
                icon: Icons.next_plan,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final vaccine = Vaccine(
                      petId: widget.pet.id!,
                      name: _nameController.text,
                      date: _dateController.text,
                      nextDoseDate: _nextDoseDateController.text,
                    );
                    await _vaccineRepository.insertVaccine(vaccine);
                    print(
                      'Vacina inserida com sucesso para petId: ${widget.pet.id}',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vacina cadastrada com sucesso'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Cadastrar Vacina'),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      keyboardType: keyboardType,
      validator:
      validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira $labelText';
            }
            return null;
          },
    );
  }

  Widget _buildDateFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      validator: _validateDate,
    );
  }
}