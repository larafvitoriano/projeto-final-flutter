import 'package:flutter/material.dart';
import 'pet.dart';

class PetDetails extends StatelessWidget {
  final Pet pet;

  PetDetails({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nome do Pet'),
        backgroundColor: Colors.blue[300],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/ed.jpg'),
              ),
              SizedBox(height: 16),
              Text('Zeca', style: TextStyle(fontSize: 24, color: Colors.black)),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildCardButton(context, 'Perfil', Icons.pets, () {}),
                  _buildCardButton(context, 'Carteira de \nVacinação', Icons.calendar_today, () {}),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _buildCardButton(context, 'Medicamentos', Icons.medical_information_rounded, () {}),
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
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blue[900]),
            ),
          ],
        ),
      ),
    );
  }
}