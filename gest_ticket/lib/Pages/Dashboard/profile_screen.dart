import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user; // Stocke l'utilisateur actuel
  Map<String, dynamic>? userData; // Stocke les informations de l'utilisateur
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fonction pour récupérer les informations de l'utilisateur connecté
  Future<void> fetchUserData() async {
    user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user!.uid).get();
      setState(() {
        userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
          // Remplir les contrôleurs avec les données de l'utilisateur
          nomController.text = userData!['nom'] ?? '';
          prenomController.text = userData!['prenom'] ?? '';
          emailController.text = userData!['email'] ?? '';
          passwordController.text = userData!['password'] ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF2C3E50),
      ),
      body: Center(
        child: userData == null
            ? const CircularProgressIndicator() // Affiche un chargement pendant que les données sont récupérées
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData!['photoURL'] != null
                          ? NetworkImage(userData!['photoURL'])
                          : const AssetImage('images/billet.png') as ImageProvider,
                    ),
                    const SizedBox(height: 20),
                    buildProfileField('Nom', nomController),
                    const SizedBox(height: 15),
                    buildProfileField('Prénom', prenomController),
                    const SizedBox(height: 15),
                    buildProfileField('Email', emailController, enabled: false),
                    const SizedBox(height: 15),
                    buildProfileField('Mot de passe', passwordController),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 300, // Réduire la largeur du bouton
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: updateUserData,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Modifier'),
                              SizedBox(width: 8),
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Widget pour créer un champ de texte de profil
  Widget buildProfileField(String label, TextEditingController controller, {bool enabled = true}) {
    return Center(
      child: SizedBox(
        width: 300, // Réduire la largeur des champs input
        child: TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(), // Ajouter une bordure visible
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    );
  }

  // Fonction pour mettre à jour les informations de l'utilisateur dans Firestore
  Future<void> updateUserData() async {
    if (user != null) {
      // Mettre à jour les données de l'utilisateur
      await _firestore.collection('users').doc(user!.uid).update({
        'nom': nomController.text,
        'prenom': prenomController.text,
        'password': passwordController.text,
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès!')),
      );
    }
  }
}
