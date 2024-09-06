import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gest_ticket/Pages/msg.dart'; // Assurez-vous que ce chemin est correct

class ChatScreen extends StatelessWidget {
  Stream<List<Map<String, dynamic>>> getConversations() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
              'conversationId': doc.id,
              'senderId': doc.data()['senderId'],
              'lastMessage': doc.data()['lastMessage'],
              'lastTimestamp': doc.data()['lastTimestamp'],
            })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversations"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Action de recherche
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Action du bouton "Nouveau Chat" ou autre
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Nouveau Chat"),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune conversation trouvée.'));
                }

                final conversations = snapshot.data!;

                return ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ListTile(
                      title: Text('Conversation avec ${conversation['nom']}'),
                      subtitle: Text(conversation['lastMessage']),
                      trailing: Text(conversation['lastTimestamp']
                          .toDate()
                          .toLocal()
                          .toString()
                          .split(' ')[1]), // Affiche l'heure du dernier message
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagePage(
                              conversationId: conversation['conversationId'],
                              receiverId: conversation['senderId'],
                            ),
                          ),
                        );
                      },
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
}
