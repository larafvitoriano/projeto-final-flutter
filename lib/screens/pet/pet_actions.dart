import 'dart:io';

import 'package:flutter/material.dart';
import 'package:projeto_final_flutter/screens/exames/exams_form.dart';
import 'package:projeto_final_flutter/screens/exames/exams_pet_page.dart';
import 'package:projeto_final_flutter/screens/pet/pet_profile.dart';
import '../../database/models/pet.dart';
import '../vacinas/vacinas_pet_page.dart';
import '../medicamentos/medicamentos_pet_page.dart';
import '../evolutions/evolution_page.dart';

class PetActions extends StatelessWidget {
  final Pet pet;

  const PetActions({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações do Pet'),
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildPetImage(),
              const SizedBox(height: 16),
              Text(pet.name, style: TextStyle(fontSize: 24, color: Colors.blue[300])),
              const SizedBox(height: 32),
              Wrap( // Usando Wrap para melhor layout responsivo
                spacing: 16.0, // Espaçamento horizontal entre os cards
                runSpacing: 16.0, // Espaçamento vertical entre as linhas
                alignment: WrapAlignment.center, // Centraliza os cards
                children: <Widget>[
                  _buildCardButton(context, 'Perfil', Icons.pets, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PetProfilePage(pet: pet)),
                    );
                  }),
                  _buildCardButton(context, 'Vacinas', Icons.vaccines, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VacinasPetPage(pet: pet)),
                    );
                  }),
                  _buildCardButton(context, 'Exames', Icons.medical_information, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExamsPetPage(pet: pet)),
                    );
                  }),
                  _buildCardButton(context, 'Medicamentos', Icons.medication, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MedicamentosPetPage(pet: pet)),
                    );
                  }),
                  _buildCardButton(context, 'Evolução', Icons.show_chart, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EvolutionPage(pet: pet)),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150, // Aumentando a largura para melhor visualização
        height: 100, // Aumentando a altura para melhor visualização
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Arredondando mais os cantos
          boxShadow: [ // Adicionando sombra para dar profundidade
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 35, color: Colors.blue[300]), // Aumentando o tamanho do ícone
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500), // Adicionando peso à fonte
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage() {
    if (pet.pictureFile.isNotEmpty) {
      return CircleAvatar(
        radius: 60, // Aumentando o raio da imagem
        backgroundImage: FileImage(File(pet.pictureFile)),
      );
    } else {
      return const CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey,
        child: Icon(Icons.pets, size: 60, color: Colors.white), // Aumentando o tamanho do ícone
      );
    }
  }
}