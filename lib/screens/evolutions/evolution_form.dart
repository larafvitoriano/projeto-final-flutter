import 'package:flutter/material.dart';
import '../../database/models/evolution.dart';
import '../../database/models/pet.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/repositories/evolution_repository.dart';

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
        title: Text(widget.evolution == null ? 'Novo Registro' : 'Editar Registro'),
        backgroundColor: Colors.blue[300],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
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
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Data: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Selecionar Data'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.evolution == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
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
