import 'package:flutter/material.dart';
import 'pet.dart';

class PetDetails extends StatelessWidget {
  final Pet pet;

  PetDetails({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        backgroundColor: Colors.blue[300],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          Expanded(
            flex: 3, // Aumenta o flex para ocupar mais espaço
            child: Card(
              elevation: 4.0,
              margin: EdgeInsets.all(16.0), // Adiciona margem ao card
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Nome: ${pet.name}', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8.0),
                    Text('Espécie: ${pet.species}'),
                    SizedBox(height: 8.0),
                    Text('Raça: ${pet.breed}'),
                    SizedBox(height: 8.0),
                    Text('Idade: ${pet.age} anos'),
                    SizedBox(height: 8.0),
                    // Adicione mais informações detalhadas aqui
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}