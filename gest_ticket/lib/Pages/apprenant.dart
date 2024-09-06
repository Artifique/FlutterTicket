
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprenantScreen extends StatefulWidget {
  const ApprenantScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ApprenantScreenState createState() => _ApprenantScreenState();
}

class _ApprenantScreenState extends State<ApprenantScreen> {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> apprenants = [];
  List<UserModel> filteredApprenants = [];

  @override
  void initState() {
    super.initState();
    _loadApprenants();
  }

  void _loadApprenants() async {
    final QuerySnapshot querySnapshot = await usersCollection.where('role', isEqualTo: 'APPRENANT').get();
    final List<UserModel> users = querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    setState(() {
      apprenants = users;
      filteredApprenants = users;
    });
  }

  void _filterApprenants(String query) {
    final filtered = apprenants.where((apprenant) {
      final nomLower = apprenant.nom.toLowerCase();
      final prenomLower = apprenant.prenom.toLowerCase();
      final searchLower = query.toLowerCase();

      return nomLower.contains(searchLower) || prenomLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredApprenants = filtered;
    });
  }

void _showAddApprenantDialog({UserModel? userToEdit}) {
  final TextEditingController nomController = TextEditingController(text: userToEdit?.nom);
  final TextEditingController prenomController = TextEditingController(text: userToEdit?.prenom);
  final TextEditingController emailController = TextEditingController(text: userToEdit?.email);
  final TextEditingController photoURLController = TextEditingController(text: userToEdit?.photoURL);
  final TextEditingController passwordController = TextEditingController(text: userToEdit?.password ?? 'learnapp');

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ajouter/Modifier un Apprenant',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: photoURLController,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                ),
                obscureText: true,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  try {
  // 1. Create user in FirebaseAuth
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: emailController.text,
    password: passwordController.text,
  );

  String? userId = userCredential.user?.uid;

  if (userId == null) {
    throw Exception("UID is null after user creation.");
  }

  if (kDebugMode) {
    print('FirebaseAuth UID: $userId');
  }

  // 2. Save user information in Firestore with the same UID
  await FirebaseFirestore.instance.collection('users').doc(userId).set({
    'nom': nomController.text,
    'prenom': prenomController.text,
    'email': emailController.text,
    'photoURL': photoURLController.text,
    'role': 'APPRENANT',
    'dateCreation': DateTime.now(),
    'derniereConnexion': DateTime.now(),
  });

  _loadApprenants(); // Refresh the list
  // ignore: use_build_context_synchronously
  Navigator.of(context).pop(); // Close the dialog
} catch (e) {
  if (kDebugMode) {
    print('Erreur lors de l\'ajout de l\'apprenant: $e');
  }
  // ignore: use_build_context_synchronously
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: $e')),
  );
}

                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _deleteApprenant(String id) async {
    await usersCollection.doc(id).delete();
    _loadApprenants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 187, 172, 172).withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Container(
                  height: 150,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      SearchBar(
                        controller: _searchController,
                        hintText: 'Rechercher un apprenant',
                        onChanged: _filterApprenants,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showAddApprenantDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Ajouter'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: 750, // Augmentation de la largeur du tableau
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 12.0,
                    columns: const [
                      DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: filteredApprenants.map((apprenant) {
                      return DataRow(
                        cells: [
                          DataCell(Text(apprenant.nom)),
                          DataCell(Text(apprenant.prenom)),
                          DataCell(Text(apprenant.role)),
                          DataCell(Text(apprenant.email)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showAddApprenantDialog(userToEdit: apprenant),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteApprenant(apprenant.id),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String photoURL;
  final String password;
  final String role;
  final DateTime dateCreation;
  final DateTime derniereConnexion;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.photoURL,
    required this.password,
    required this.role,
    required this.dateCreation,
    required this.derniereConnexion,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> firestore, String id) {
    return UserModel(
      id: id,
      nom: firestore['nom'] ?? '',
      prenom: firestore['prenom'] ?? '',
      email: firestore['email'] ?? '',
      photoURL: firestore['photoURL'] ?? '',
      password: firestore['password'] ?? 'learnapp', // Valeur par défaut
      role: firestore['role'] ?? '',
      dateCreation: (firestore['dateCreation'] as Timestamp).toDate(),
      derniereConnexion: (firestore['derniereConnexion'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'photoURL': photoURL,
      'password': password, // Inclure le mot de passe
      'role': role,
      'dateCreation': dateCreation,
      'derniereConnexion': derniereConnexion,
    };
  }
}
