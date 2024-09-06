import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
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
          nomController.text = userData!['nom'] ?? '';
          prenomController.text = userData!['prenom'] ?? '';
          emailController.text = userData!['email'] ?? '';
          passwordController.text = userData!['password'] ?? '';
        }
      });
    }
  }

  // Fonction pour déconnecter l'utilisateur
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacementNamed('/'); // Remplacez '/login' par votre route de connexion

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut(); // Appelle la fonction de déconnexion
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFD9D9D9),
      body: Center(
        child: userData == null 
            ? const CircularProgressIndicator() // Affiche un chargement pendant que les données sont récupérées
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData!['photoURL'] != null 
                        ? NetworkImage(userData!['photoURL']) 
                        : const AssetImage('images/billet.png') as ImageProvider,
                  ),
                  const SizedBox(height: 50),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    width: 350,
                    child: Column(
                      children: [
                        buildProfileField('Nom', nomController),
                        const SizedBox(height: 15),
                        buildProfileField('Prénom', prenomController),
                        const SizedBox(height: 20),
                        buildProfileField('Email', emailController, enabled: false),
                        const SizedBox(height: 20),
                        buildProfileField('Mot de passe', passwordController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () {
                            // Logique de modification des informations utilisateur
                            updateUserData();
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Center(child: Text('Modifier')),
                              Positioned(
                                right: -10,
                                bottom: -10,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.arrow_forward,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Widget pour créer un champ de texte de profil
  Widget buildProfileField(String label, TextEditingController controller, {bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(enabled ? Icons.edit : Icons.email),
          labelText: label,
          contentPadding: const EdgeInsets.all(16),
        ),
        onChanged: (newValue) {
          setState(() {
            userData![label.toLowerCase()] = newValue;
          });
        },
      ),
    );
  }

  // Fonction pour mettre à jour les informations de l'utilisateur dans Firestore
  Future<void> updateUserData() async {
    if (user != null && userData != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'nom': nomController.text,
        'prenom': prenomController.text,
        'email': emailController.text,
        'password': passwordController.text,
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour avec succès!')),
      );
    }
  }
}
