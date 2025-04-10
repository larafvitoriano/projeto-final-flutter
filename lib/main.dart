import 'package:flutter/material.dart';
import 'package:projeto_final_flutter/screens/calendar_screen.dart';
import 'screens/pet/meus_pets_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'database/helpers/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuidaPet',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[300],
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[300],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue[300]!, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIconColor: Colors.blue[300],
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue[300],
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return snapshot.hasData ? const MyHomePage() : const LoginPage();
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CuidaPet',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await DatabaseHelper().clearDatabase();
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[300]),
              child: const Text(
                'Menu',
                style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.blue[300]), // Ícone azul
              title: const Text('Início'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.pets, color: Colors.blue[300]), // Ícone azul
              title: const Text('Meus Pets'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MeusPetsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_month, color: Colors.blue[300]), // Ícone azul
              title: const Text('Calendário'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.blue[300]), // Ícone azul
              title: const Text('Sair'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
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
              const SizedBox(height: 16.0),
              const Text('Seja bem-vindo(a). O que deseja fazer?', style: TextStyle(fontSize: 18.0)),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _buildCardButton(context, 'Meus Pets', Icons.pets, MeusPetsPage()),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildCardButton(context, 'Calendário', Icons.calendar_month, CalendarScreen()),
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Card(
        elevation: 4.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40.0, color: Colors.blue[300]),
              const SizedBox(height: 8.0),
              Text(
                title,
                style: const TextStyle(fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}