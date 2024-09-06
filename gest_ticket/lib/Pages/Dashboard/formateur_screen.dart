import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gest_ticket/Pages/Dashboard/apprenant_screen.dart';

class FormateurScreen extends StatefulWidget {
  const FormateurScreen({super.key});

  @override
  State<FormateurScreen> createState() => _FormateurScreenState();
}

class _FormateurScreenState extends State<FormateurScreen> {
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> formateurs = [];
  List<UserModel> filteredFormateurs = [];

  @override
  void initState() {
    super.initState();
    _loadFormateurs();
  }

  void _loadFormateurs() async {
    final QuerySnapshot querySnapshot = await usersCollection.where('role', isEqualTo: 'FORMATEUR').get();
    final List<UserModel> users = querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();

    setState(() {
      formateurs = users;
      filteredFormateurs = users;
    });
  }

  void _filterFormateurs(String query) {
    final filtered = formateurs.where((formateur) {
      final nomLower = formateur.nom.toLowerCase();
      final prenomLower = formateur.prenom.toLowerCase();
      final searchLower = query.toLowerCase();

      return nomLower.contains(searchLower) || prenomLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredFormateurs = filtered;
    });
  }

  void _showAddFormateurDialog({UserModel? userToEdit}) {
    final TextEditingController nomController = TextEditingController(text: userToEdit?.nom);
    final TextEditingController prenomController = TextEditingController(text: userToEdit?.prenom);
    final TextEditingController emailController = TextEditingController(text: userToEdit?.email);
    final TextEditingController photoURLController = TextEditingController(text: userToEdit?.photoURL);
    final TextEditingController passwordController = TextEditingController(text: userToEdit?.password ?? 'learnapp');
    final DateTime? dateCreation = userToEdit?.dateCreation;
    final DateTime? derniereConnexion = userToEdit?.derniereConnexion;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.45,
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajouter/Modifier un Formateur',
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
                // Remove the role dropdown to make it unchangeable
                if (userToEdit != null) ...[
                  Text('Rôle: ${userToEdit.role}'),
                  const SizedBox(height: 12),
                ],
                if (dateCreation != null) ...[
                  Text('Date de Création: ${dateCreation.toString()}'),
                  const SizedBox(height: 12),
                ],
                if (derniereConnexion != null) ...[
                  Text('Dernière Connexion: ${derniereConnexion.toString()}'),
                  const SizedBox(height: 12),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (kDebugMode) {
                          print('Selected Role: FORMATEUR');
                        }
                        try {
                          String userId;

                          if (userToEdit != null) {
                            // Mise à jour de l'utilisateur dans Firestore
                            await usersCollection.doc(userToEdit.id).update({
                              'nom': nomController.text,
                              'prenom': prenomController.text,
                              'email': emailController.text,
                              'photoURL': photoURLController.text,
                              'password': passwordController.text,
                              'dateCreation': dateCreation,
                              'derniereConnexion': derniereConnexion,
                            });

                            // Mise à jour dans Firebase Authentication si l'email ou le mot de passe a changé
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && (user.email != emailController.text || passwordController.text != 'learnapp')) {
                              if (user.email != emailController.text) {
                                // ignore: deprecated_member_use
                                await user.updateEmail(emailController.text);
                              }
                              if (passwordController.text != 'learnapp') {
                                await user.updatePassword(passwordController.text);
                              }
                            }
                            userId = userToEdit.id; // Utiliser l'ID existant
                          } else {
                            // Création d'un nouvel utilisateur dans Firebase Auth
                            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );
                            userId = userCredential.user!.uid; // Obtenir l'ID de l'utilisateur nouvellement créé

                            // Ajout du nouvel utilisateur dans Firestore
                            await usersCollection.doc(userId).set({
                              'nom': nomController.text,
                              'prenom': prenomController.text,
                              'email': emailController.text,
                              'photoURL': photoURLController.text,
                              'role': 'FORMATEUR',
                              'password': passwordController.text,
                              'dateCreation': DateTime.now(),
                              'derniereConnexion': DateTime.now(),
                            });
                          }

                          _loadFormateurs();
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        } catch (e) {
                          // Affichage d'un message d'erreur
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: $e'),
                            ),
                          );
                        }
                      },
                      child: Text(userToEdit != null ? 'Modifier' : 'Ajouter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteFormateur(String id) async {
    await usersCollection.doc(id).delete();
    _loadFormateurs();
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Rechercher un formateur',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                suffixIcon: Icon(Icons.search),
                              ),
                              onChanged: _filterFormateurs,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showAddFormateurDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth, // Utiliser la largeur disponible
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 12.0,
                        columns: const [
                          DataColumn(label: Text('Nom', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Prénom', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredFormateurs.map((formateur) {
                          return DataRow(cells: [
                            DataCell(Text(formateur.nom)),
                            DataCell(Text(formateur.prenom)),
                            DataCell(Text(formateur.role)),
                            DataCell(Text(formateur.email)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showAddFormateurDialog(userToEdit: formateur),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _deleteFormateur(formateur.id),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
