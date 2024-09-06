import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gest_ticket/Modeles/categorie.dart';
import 'package:gest_ticket/Modeles/ticket.dart';
import 'package:gest_ticket/Pages/firestore_service.dart';

class Acceuil extends StatefulWidget {
  const Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  String searchQuery = '';
  String selectedCategory = '';
  String username = '';
  String titre = '';
  String description = '';
  late Future<List<Categorie>> categoriesFuture;
  late Future<User?> currentUserFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = getCategories();
    currentUserFuture = getCurrentUser();
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(ticketId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du ticket: $e');
      // Vous pouvez afficher une erreur à l'utilisateur ici
    }
  }

  Future<void> updateTicket(Ticket updatedTicket) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(updatedTicket.id).update({
        'titre': updatedTicket.titre,
        'description': updatedTicket.description,
        'priorite': updatedTicket.priorite,
        'statut': updatedTicket.statut,
        'datecreation': updatedTicket.datecreation,
        'categorieId': updatedTicket.categorieId,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour du ticket: $e');
      // Vous pouvez afficher une erreur à l'utilisateur ici
    }
  }

  void _showEditTicketDialog(Ticket ticket) {
    TextEditingController titreController = TextEditingController(text: ticket.titre);
    TextEditingController descriptionController = TextEditingController(text: ticket.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            height: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Modifier un Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: titreController,
                  decoration: const InputDecoration(
                    hintText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<Categorie>>(
                  future: categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Pas de catégories disponibles.');
                    }

                    final categories = snapshot.data!;
                    return DropdownButton<String>(
                      value: selectedCategory.isEmpty ? ticket.categorieId : selectedCategory,
                      hint: Text('Choisir une catégorie'),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: categories.map((categorie) {
                        return DropdownMenuItem<String>(
                          value: categorie.id,
                          child: Text(categorie.nom),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final updatedTicket = Ticket(
                      id: ticket.id,
                      titre: titreController.text,
                      description: descriptionController.text,
                      priorite: ticket.priorite,
                      statut: ticket.statut,
                      datecreation: ticket.datecreation,
                      categorieId: selectedCategory.isEmpty ? ticket.categorieId : selectedCategory,
                      idCreateur: ticket.idCreateur,
                      reponses: ticket.reponses,
                    );

                    await updateTicket(updatedTicket);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2edbfa)),
                  child: const Text('Soumettre', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(String ticketId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation de suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce ticket ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await deleteTicket(ticketId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ticket supprimé')),
                );
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTicketDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 400,
            height: 350,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ajouter un Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      titre = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<Categorie>>(
                  future: categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('Pas de catégories disponibles.');
                    }

                    final categories = snapshot.data!;
                    return DropdownButton<String>(
                      value: selectedCategory.isEmpty ? null : selectedCategory,
                      hint: Text('Choisir une catégorie'),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: categories.map((categorie) {
                        return DropdownMenuItem<String>(
                          value: categorie.id,
                          child: Text(categorie.nom),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final user = await currentUserFuture;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Utilisateur non authentifié')),
                      );
                      return;
                    }

                    final ticket = Ticket(
                      id: '', // Vous pouvez laisser vide ou générer un ID
                      titre: titre,
                      description: description,
                      priorite: 'Faible',
                      statut: 'En attente',
                      datecreation: DateTime.now(),
                      categorieId: selectedCategory,
                      idCreateur: user.uid,
                      reponses: [],
                    );

                    await addTicket(ticket);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2edbfa)),
                  child: const Text('Soumettre', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        color: const Color(0xFFD9D9D9),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('images/logo.png', width: 100, height: 100),
                FutureBuilder<User?>(
                  future: currentUserFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Chargement...');
                    } else if (snapshot.hasError) {
                      return Text('Erreur: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('Utilisateur non connecté');
                    }

                    username = snapshot.data!.displayName ?? 'Utilisateur';
                    return Text(
                      "Bienvenue, $username",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                const Icon(Icons.notifications, size: 30),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Rechercher',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _showAddTicketDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2edbfa),
                    minimumSize: const Size(150, 50),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      Text(
                        'Ajouter',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Categorie>>(
              future: categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Pas de catégories disponibles.');
                }

                return catTicket(snapshot.data!);
              },
            ),
            Expanded(
              child: StreamBuilder<List<Ticket>>(
                stream: getTickets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun ticket disponible.'));
                  }

                  final tickets = snapshot.data!;
                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Dismissible(
                        key: Key(ticket.id),
                        background: Container(
                          color: Colors.red,
                          child:  Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 36.0,
                     //       padding: EdgeInsets.only(left: 20),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmation de suppression'),
                                content: const Text('Êtes-vous sûr de vouloir supprimer ce ticket ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          await deleteTicket(ticket.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ticket supprimé')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            title: Text(ticket.titre, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(ticket.description),
                            trailing: SizedBox(
                              width: 60,
                              child: Image.asset('images/billet.png'),
                            ),
                            isThreeLine: true,
                            onTap: () {
                              // Action lorsque l'utilisateur tape sur un ticket
                              _showEditTicketDialog(ticket);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget catTicket(List<Categorie> categories) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Catégorie de ticket",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: categories.map((category) {
              return Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedCategory = category.id;
                    });
                  },
                  style: ElevatedButton.styleFrom(
              //      primary: selectedCategory == category.id ? const Color(0xFF2edbfa) : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    category.nom,
                    style: TextStyle(
                      color: selectedCategory == category.id ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
