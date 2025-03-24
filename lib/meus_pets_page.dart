import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'pet.dart';
import 'pet_form.dart';
import 'pet_details.dart';

class MeusPetsPage extends StatefulWidget {
  @override
  _MeusPetsPageState createState() => _MeusPetsPageState();
}

class _MeusPetsPageState extends State<MeusPetsPage> {
  final _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pets'),
        backgroundColor: Colors.blue[300],
      ),
      body: FutureBuilder<List<Pet>>(
        future: _databaseHelper.getPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os pets'));
          } else if (snapshot.hasData) {
            final pets = snapshot.data!;
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                return _buildPetCard(pets[index]);
              },
            );
          } else {
            return Center(child: Text('Nenhum pet cadastrado'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PetForm()),
          ).then((_) {
            setState(() {});
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetails(pet: pet)),
        ).then((_) {
          setState(() {});
        });
      },
      onLongPress: () {
        _showDeleteConfirmationDialog(context, pet);
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                color: Colors.grey[300],
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pet.name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Text(pet.species),
                  Text(pet.breed),
                  Text('${pet.age} anos'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir Pet'),
          content: Text('Deseja realmente excluir ${pet.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Excluir'),
              onPressed: () async {
                await _databaseHelper.deletePet(pet.id!);
                Navigator.of(context).pop();
                setState(() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pet excluído com sucesso!')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }
}