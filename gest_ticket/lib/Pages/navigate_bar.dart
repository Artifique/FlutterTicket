import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gest_ticket/Pages/acceuil.dart';
import 'package:gest_ticket/Pages/chat_screen.dart';
import 'package:gest_ticket/Pages/profile.dart';
import 'package:gest_ticket/Pages/recherche.dart';
import 'package:gest_ticket/Pages/formateur.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavbar> {
  int selectedIndex = 0;
  late Future<String> userRoleFuture;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    userRoleFuture = _getUserRole();
  }

  Future<String> _getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc.data()?['role'] ?? 'APPR';
    }
    return 'APPR';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: userRoleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Erreur de chargement du rôle')),
          );
        }

        final role = snapshot.data;
        pages = role == 'FORMATEUR'
            ? [
                const Formateur(),
                const Recherche(),
                ChatScreen(), // Affichage pour les formateurs
                const Profile()
              ]
            : [
                const Acceuil(),
                const Recherche(),
                ChatScreen(), // Affichage pour les apprenants
                const Profile()
              ];

        return Scaffold(
          body: pages[selectedIndex],
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 8), // Espacement vertical
            decoration: const BoxDecoration(
              color: Colors.white, // Couleur de fond de la barre de navigation
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              iconSize: 28, // Taille des icônes
              selectedItemColor: Colors.white, // Couleur de l'icône sélectionnée
              unselectedItemColor: Colors.grey, // Couleur des icônes non sélectionnées
              showSelectedLabels: false, // Pas de label sous les icônes
              showUnselectedLabels: false, // Pas de label sous les icônes
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.home, 'Home', 0),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.edit_document, 'Search', 1),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.message, 'Chat', 2),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: _buildIcon(Icons.person, 'Profile', 3),
                  label: '',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIcon(IconData iconData, String label, int index) {
    bool isSelected = selectedIndex == index;
    return Container(
      padding: const EdgeInsets.all(8), // Réduit le padding
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2C3E50) : Colors.transparent,
        borderRadius: BorderRadius.circular(16), // Réduit le rayon du bord
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: isSelected ? 30 : 24, // Ajuste la taille des icônes
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
