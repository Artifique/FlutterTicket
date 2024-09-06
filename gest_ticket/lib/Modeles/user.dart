import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String role;
  final String email;
  final String nom;
  final String prenom;
  final String photoURL;
  final DateTime dateCreation;
  final DateTime derniereConnexion;
  final String password; // Nouveau champ

  User({
    required this.id,
    required this.role,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.photoURL,
    required this.dateCreation,
    required this.derniereConnexion,
    this.password = 'learnapp', // Valeur par défaut
  });

  // Factory constructor to create a User from a Firestore document
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      role: data['role'],
      email: data['email'],
      nom: data['nom'],
      prenom: data['prenom'],
      photoURL: data['photoURL'],
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      derniereConnexion: (data['derniereConnexion'] as Timestamp).toDate(),
      password: data['password'] ?? 'learnapp', // Valeur par défaut si non trouvée
    );
  }

  // Method to convert User to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'email': email,
      'nom': nom,
      'prenom': prenom,
      'photoURL': photoURL,
      'dateCreation': dateCreation,
      'derniereConnexion': derniereConnexion,
      'password': password, // Inclure le mot de passe
    };
  }
}
