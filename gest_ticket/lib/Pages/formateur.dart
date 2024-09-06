import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gest_ticket/Modeles/ticket.dart' as ticket_models;
import 'package:gest_ticket/Pages/msg.dart';

class Formateur extends StatefulWidget {
  const Formateur({Key? key}) : super(key: key);

  @override
  _FormateurState createState() => _FormateurState();
}

class _FormateurState extends State<Formateur> {
  String username = '';
  late Future<User?> currentUserFuture;
  late Stream<QuerySnapshot> ticketsStream;

  @override
  void initState() {
    super.initState();
    currentUserFuture = getCurrentUser();
    ticketsStream = FirebaseFirestore.instance.collection('tickets').snapshots();
  }

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      await FirebaseFirestore.instance.collection('tickets').doc(ticketId).delete();
    } catch (e) {
      print('Erreur lors de la suppression du ticket: $e');
    }
  }

  Future<void> _createOrUpdateConversation(String formateurId, String apprenantId) async {
    final conversationId = '$formateurId$apprenantId';
    final conversationRef = FirebaseFirestore.instance.collection('conversations').doc(conversationId);

    final conversationDoc = await conversationRef.get();

    if (!conversationDoc.exists) {
      await conversationRef.set({
        'formateurId': formateurId,
        'apprenantId': apprenantId,
        'lastMessage': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showReponseDialog(ticket_models.Ticket ticket) {
    final TextEditingController responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Répondre au ticket: ${ticket.titre}'),
          content: TextField(
            controller: responseController,
            decoration: InputDecoration(labelText: 'Votre réponse'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  print('Utilisateur non connecté');
                  return;
                }

                final reponse = ticket_models.Reponse(
                  id: FirebaseFirestore.instance.collection('tickets').doc().id, // Génération automatique de l'ID
                  contenu: responseController.text,
                  datecreation: DateTime.now(),
                  idCreateur: currentUser.uid,
                );

                try {
                  await FirebaseFirestore.instance.collection('tickets').doc(ticket.id).update({
                    'reponses': FieldValue.arrayUnion([reponse.toFirestore()]),
                    'idFormateur': currentUser.uid, // Ajout de l'ID du formateur
                    'statut': 'Résolu', // Mise à jour du statut
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Erreur lors de l\'ajout de la réponse: $e');
                }
              },
              child: const Text('Envoyer'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMessagePage(ticket_models.Ticket ticket) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('Utilisateur non connecté');
      return;
    }

    final formateurId = currentUser.uid;
    final apprenantId = ticket.idCreateur;

    if (apprenantId.isEmpty) {
      print('ID de l\'apprenant est vide');
      return;
    }

    final conversationId = '$formateurId$apprenantId';

    // Création ou mise à jour de la conversation
    await _createOrUpdateConversation(formateurId, apprenantId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          conversationId: conversationId,
          receiverId: apprenantId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formateur - Tickets'),
        actions: [
          FutureBuilder<User?>(
            future: currentUserFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (!snapshot.hasData) {
                return const Text('Non connecté');
              } else {
                username = snapshot.data?.displayName ?? 'Formateur';
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Bienvenue, $username'),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildTicketSummary(),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ticketsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun ticket trouvé.'));
                }

                final tickets = snapshot.data!.docs.map((doc) {
                  return ticket_models.Ticket.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text(ticket.titre),
                        subtitle: Text(ticket.description),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'Prendre en charge':
                                _showReponseDialog(ticket);
                                break;
                              case 'Supprimer':
                                deleteTicket(ticket.id);
                                break;
                              case 'Discussion':
                                _navigateToMessagePage(ticket);
                                break;
                            }
                          },
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem(value: 'Prendre en charge', child: Text('Prendre en charge')),
                              const PopupMenuItem(value: 'Discussion', child: Text('Discussion')),
                              const PopupMenuItem(value: 'Supprimer', child: Text('Supprimer')),
                            ];
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
    );
  }

  Widget _buildTicketSummary() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (!snapshot.hasData) {
          return const Text('Erreur lors de la récupération des tickets.');
        }

        final totalTickets = snapshot.data!.docs.length;
        final waitingTickets = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['statut'] == 'En attente').length;
        final inProgressTickets = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['statut'] == 'En cours').length;
        final resolvedTickets = snapshot.data!.docs.where((doc) => (doc.data() as Map<String, dynamic>)['statut'] == 'Résolu').length;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryCard('En attente', waitingTickets, Colors.orange),
            _buildSummaryCard('En cours', inProgressTickets, Colors.blue),
            _buildSummaryCard('Résolu', resolvedTickets, Colors.green),
            _buildSummaryCard('Total', totalTickets, Colors.grey),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 5),
            Text('$count', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
