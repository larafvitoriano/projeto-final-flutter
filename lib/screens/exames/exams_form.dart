import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/helpers/database_helper.dart';
import '../../database/models/exam.dart';
import '../../database/repositories/exam_repository.dart';

class ExamForm extends StatefulWidget {
  final int petId;
  final Exam? exam;

  ExamForm({required this.petId, this.exam});

  @override
  _ExamFormState createState() => _ExamFormState();
}

class _ExamFormState extends State<ExamForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  File? _arquivoPdf;
  final _notesController = TextEditingController();

  ExamRepository? repository;

  @override
  void initState() {
    super.initState();
    repository = ExamRepository(DatabaseHelper());
    if (widget.exam != null) {
      _nomeController.text = widget.exam!.name;
      _dataController.text = widget.exam!.date;
      // Para editar o PDF, você pode precisar de uma lógica adicional para lidar com o arquivo existente.
      _notesController.text = widget.exam!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
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

  Future<void> _selecionarArquivoPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _arquivoPdf = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exam == null ? 'Novo Exame' : 'Editar Exame')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildTextFormField(
                controller: _nomeController,
                labelText: 'Nome do Exame',
                icon: Icons.description,
              ),
              const SizedBox(height: 12.0),
              _buildDateFormField(
                controller: _dataController,
                labelText: 'Data',
                icon: Icons.calendar_today,
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(
                onPressed: _selecionarArquivoPdf,
                child: Text('Selecionar PDF'),
              ),
              const SizedBox(height: 12.0),
              _buildTextFormField(
                controller: _notesController,
                labelText: 'Observações',
                icon: Icons.notes,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                validator: null,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final bytes = _arquivoPdf != null ? await _arquivoPdf!.readAsBytes() : widget.exam?.pdfFile;
                    if (bytes == null) return;
                    final exam = Exam(
                      id: widget.exam?.id,
                      petId: widget.petId,
                      name: _nomeController.text,
                      date: _dataController.text,
                      pdfFile: bytes,
                      notes: _notesController.text,
                    );
                    if (widget.exam == null) {
                      await repository!.insertExam(exam);
                    } else {
                      await repository!.updateExam(exam);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.exam == null ? 'Salvar Exame' : 'Atualizar Exame'),
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
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira $labelText';
        }
        return null;
      },
      maxLines: maxLines,
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