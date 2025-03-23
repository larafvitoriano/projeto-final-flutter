import 'package:flutter/material.dart';
import 'meus_pets_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text(
          'CuidaPet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue[300],
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.green[500]),
              title: Text('Início'),
              onTap: () {
                Navigator.pop(context);
                // Lógica da página inicial
              },
            ),
            ListTile(
              leading: Icon(Icons.pets, color: Colors.green[500]),
              title: Text('Meus Pets'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeusPetsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green[500]),
              title: Text('Configurações'),
              onTap: () {
                Navigator.pop(context);
                // Lógica da página de configurações
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Icon(
          Icons.pets,
          size: 100.0,
          color: Colors.blue[300],
        ),
      ),
    );
  }
}