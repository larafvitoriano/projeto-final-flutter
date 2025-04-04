import 'package:flutter/material.dart';
import '../../database/models/evolution.dart';
import '../../database/models/pet.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/repositories/evolution_repository.dart';
import 'package:intl/intl.dart';

class EvolutionForm extends StatefulWidget {
  final Pet pet;
  final Evolution? evolution;

  const EvolutionForm({Key? key, required this.pet, this.evolution}) : super(key: key);

  @override
  _EvolutionFormState createState() => _EvolutionFormState();
}

class _EvolutionFormState extends State<EvolutionForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  late EvolutionRepository _evolutionRepository;

  @override
  void initState() {
    super.initState();
    _evolutionRepository = EvolutionRepository(DatabaseHelper());
    if (widget.evolution != null) {
      _weightController.text = widget.evolution!.weight.toString();
      _notesController.text = widget.evolution!.notes ?? '';
      _selectedDate = widget.evolution!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evolution == null ? 'Novo Registro' : 'Editar Registro', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[300],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                      prefixIcon: const Icon(Icons.monitor_weight, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue[300]!), borderRadius: BorderRadius.circular(8.0)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue[300]!), borderRadius: BorderRadius.circular(8.0)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _pickDate,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[300]),
                        child: const Text('Selecionar Data', style: TextStyle(color: Colors.white)),
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
                    child: Text(widget.evolution == null ? 'Salvar' : 'Atualizar', style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      double weight = double.parse(_weightController.text);
      final evolution = Evolution(
        id: widget.evolution?.id,
        petId: widget.pet.id!,
        weight: weight,
        date: _selectedDate,
        notes: _notesController.text,
      );

      if (widget.evolution == null) {
        await _evolutionRepository.insertEvolution(evolution);
      } else {
        await _evolutionRepository.updateEvolution(evolution);
      }
      Navigator.pop(context);
    }
  }
}