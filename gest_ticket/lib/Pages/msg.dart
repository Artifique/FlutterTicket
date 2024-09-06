import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatefulWidget {
  final String conversationId;
  final String receiverId; // Ajout de l'identifiant du destinataire

  const MessagePage({
    required this.conversationId,
    required this.receiverId, // Initialisation de l'identifiant du destinataire
    super.key,
  });

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();
  late Stream<QuerySnapshot> messagesStream;

  @override
  void initState() {
    super.initState();
    messagesStream = FirebaseFirestore.instance
        .collection('conversations')
        .doc(widget.conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> _sendMessage() async {
    final String messageText = _controller.text.trim();
    if (messageText.isNotEmpty) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          // Ajouter le message
          await FirebaseFirestore.instance
              .collection('conversations')
              .doc(widget.conversationId)
              .collection('messages')
              .add({
            'text': messageText,
            'sender': currentUser.uid,
            'receiver': widget.receiverId, // Ajout de l'identifiant du destinataire
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Créer ou mettre à jour le document de la conversation
          await FirebaseFirestore.instance
              .collection('conversations')
              .doc(widget.conversationId)
              .set({
            'lastMessage': messageText,
            'lastTimestamp': FieldValue.serverTimestamp(),
            'senderId': currentUser.uid,
            'receiverId': widget.receiverId, // Ajout de l'identifiant du destinataire
          }, SetOptions(merge: true)); // Utilisez merge: true pour mettre à jour sans écraser

          _controller.clear();
        } catch (e) {
          print('Erreur lors de l\'envoi du message: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun message.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    final isCurrentUser = message['sender'] == FirebaseAuth.instance.currentUser?.uid;
                    return ListTile(
                      title: Align(
                        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Écrire un message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
