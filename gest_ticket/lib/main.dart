import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gest_ticket/Pages/acceuil.dart';
import 'package:gest_ticket/Pages/chat_screen.dart';
import 'package:gest_ticket/Pages/discussion_page.dart';
import 'package:gest_ticket/Pages/formateur.dart';
import 'package:gest_ticket/Pages/login.dart';



import 'package:gest_ticket/Pages/navigate_bar.dart';
import 'firebase_options.dart';
//import 'package:gest_ticket/Pages/acceuil.dart';
// Importez d'autres pages si nécessaire

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Définissez la route initiale
      routes: {
      //  '/': (context) => const FormDetail(titre: '', date: '', categorie: '', statut: '',), // Route pour la page de connexion
        '/': (context) => const Login(), // Route pour la page de connexion
        '/home': (context) => const BottomNavbar(), // Route pour la page d'accueil
      //  '/ticket': (context) => const Acceuil(), // Route pour la page d'accueil
        // Ajoutez d'autres routes ici si nécessaire
      },
    );
  }
}
