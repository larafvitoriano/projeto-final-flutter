import 'package:flutter/material.dart';

class MeusPetsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pets'),
        backgroundColor: Colors.blue[300], // Fundo azul no AppBar
      ),
      body: ListView(
        children: <Widget>[
          _buildPetCard('Rex', 'Cachorro'),
          _buildPetCard('Mimi', 'Gato'),
          // Adicione mais pets aqui
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para adicionar um novo pet
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetCard(String nome, String tipo) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Container(
              width: 80.0,
              height: 80.0,
              color: Colors.grey[300], // Fundo cinza para representar a imagem
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  nome,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                Text(tipo),
              ],
            ),
          ],
        ),
      ),
    );
  }
}