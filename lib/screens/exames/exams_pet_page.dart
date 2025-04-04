import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../database/models/pet.dart';
import '../../database/models/exam.dart';
import '../../database/repositories/exam_repository.dart';
import '../../database/helpers/database_helper.dart';
import 'exams_form.dart';

class ExamsPetPage extends StatefulWidget {
  final Pet pet;

  const ExamsPetPage({required this.pet, super.key});

  @override
  _ExamsPetPageState createState() => _ExamsPetPageState();
}

class _ExamsPetPageState extends State<ExamsPetPage> {
  late ExamRepository _examRepository;

  @override
  void initState() {
    super.initState();
    _examRepository = ExamRepository(DatabaseHelper());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exames de ${widget.pet.name}'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<Exam>>(
        future: Future.delayed(Duration.zero, () async {
          try {
            return await _examRepository.getExamsForPet(widget.pet.id!);
          } catch (e) {
            print('Erro ao recuperar exames: $e');
            throw e;
          }
        }),
        builder: (context, snapshot) {
          print('Recuperando exames para petId: ${widget.pet.id}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os exames'));
          } else if (snapshot.hasData) {
            print('Exames recuperados: ${snapshot.data}');
            final exams = snapshot.data!;
            return ListView.builder(
              itemCount: exams.length,
              itemBuilder: (context, index) {
                try {
                  return _buildExamCard(exams[index]);
                } catch (e) {
                  print('Erro ao construir card: $e');
                  return const Text('Erro ao exibir exame');
                }
              },
            );
          } else {
            return const Center(child: Text('Nenhum exame cadastrado para este pet'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExamForm(petId: widget.pet.id!)),
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return GestureDetector(
      onTap: () {
        _showExamActionsDialog(context, exam);
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(context, exam);
      },
      child: Card(
        margin: const EdgeInsets.all(8.0),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(Icons.description, size: 40, color: Colors.blue[900]),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      exam.name,
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('Data: ${exam.date}'),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                        'Observações: ${exam.notes?.isNotEmpty == true ? exam.notes : 'Não informado'}',
                      style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showExamActionsDialog(BuildContext context, Exam exam) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ações'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Visualizar PDF'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final directory = await getApplicationDocumentsDirectory();
                    final file = File('${directory.path}/${exam.name}.pdf');
                    await file.writeAsBytes(exam.pdfFile);
                    OpenFile.open(file.path);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Editar Exame'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamForm(petId: widget.pet.id!, exam: exam),
                      ),
                    ).then((_) {
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Exam exam) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir Exame'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja excluir este exame?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () async {
                await _examRepository.deleteExam(exam.id!, widget.pet.id!);
                setState(() {}); // Atualiza a lista após a exclusão
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}