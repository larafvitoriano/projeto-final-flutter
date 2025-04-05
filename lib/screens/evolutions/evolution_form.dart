import 'package:flutter/material.dart';
import '../../database/models/evolution.dart';
import '../../database/models/pet.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/repositories/evolution_repository.dart';
import 'package:intl/intl.dart';

class EvolutionForm extends StatefulWidget {
  final Pet pet;
  final Evolution? evolution;

  const EvolutionForm({Key? key, required this.pet, this.evolution})
      : super(key: key);

  @override
  _EvolutionFormState createState() => _EvolutionFormState();
}

class _EvolutionFormState extends State<EvolutionForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  late EvolutionRepository _evolutionRepository;

  @override
  void initState() {
    super.initState();
    _evolutionRepository = EvolutionRepository(DatabaseHelper());
    if (widget.evolution != null) {
      _weightController.text = widget.evolution!.weight.toString();
      _notesController.text = widget.evolution!.notes ?? '';
      _dateController.text = widget.evolution!.date;
    }
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

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
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
        title: Text(
          widget.evolution == null ? 'Novo Registro' : 'Editar Registro',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[300],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Peso (kg)',
                      prefixIcon: const Icon(
                        Icons.monitor_weight,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o peso';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Peso inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Observações',
                      prefixIcon: const Icon(Icons.notes, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue[300]!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateFormField(
                          controller: _dateController,
                          labelText: 'Data',
                          icon: Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: Text(
                      widget.evolution == null ? 'Salvar' : 'Atualizar',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        prefixIcon: Icon(icon, color: Colors.blue[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      validator: _validateDate,
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(_weightController.text);
      final evolution = Evolution(
        id: widget.evolution?.id,
        petId: widget.pet.id!,
        weight: weight,
        date: _dateController.text, // Data do controller
        notes: _notesController.text,
      );

      try {
        if (widget.evolution == null) {
          await _evolutionRepository.insertEvolution(evolution);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro salvo com sucesso!')),
          );
        } else {
          await _evolutionRepository.updateEvolution(evolution);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro atualizado com sucesso!')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o registro: $e')),
        );
      }
    }
  }
}