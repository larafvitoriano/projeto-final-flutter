import 'package:flutter/material.dart';
import 'meus_pets_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text('CuidaPet', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[300]),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.green[500]),
              title: Text('Início'),
              onTap: () {
                Navigator.pop(context);
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
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.pets, size: 100.0, color: Colors.blue[300]),
              SizedBox(height: 16.0),
              Text('Olá, usuário(a)!', style: TextStyle(fontSize: 18.0)),
              Text('Seja bem-vindo. O que deseja fazer?', style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 20.0),
              Padding( // Adicionado um Padding para margem horizontal
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _buildCardButton(context, 'Meus Pets', Icons.pets, MeusPetsPage()),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: _buildCardButton(context, 'Configurações', Icons.settings, MeusPetsPage()), // Substitua MeusPetsPage pela página de configurações
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardButton(BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        } else {
          print('Configurações pressionado');
        }
      },
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40.0, color: Colors.blue[300]),
              SizedBox(height: 8.0),
              Text(title, style: TextStyle(fontSize: 16.0), textAlign: TextAlign.center,),
            ],
          ),
        ),
      ),
    );
  }
}