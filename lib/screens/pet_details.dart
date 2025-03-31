import 'package:flutter/material.dart';
import '../database/models/pet.dart';
import 'vacinas_pet_page.dart';
import 'medicamentos_pet_page.dart';

class PetDetails extends StatelessWidget {
  final Pet pet;

  const PetDetails({required this.pet, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/ed.jpg'),
              ),
              const SizedBox(height: 16),
              Text(pet.name, style: const TextStyle(fontSize: 24, color: Colors.black)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildCardButton(context, 'Perfil', Icons.pets, () {}),
                  _buildCardButton(context, 'Vacinas', Icons.calendar_today, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VacinasPetPage(pet: pet)),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildCardButton(context, 'Medicamentos', Icons.medical_information_rounded, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MedicamentosPetPage(pet: pet)),
                    );
                  }),
                  _buildCardButton(context, 'Evolução do Pet', Icons.description, () {}),
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
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 30, color: Colors.blue[900]),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}