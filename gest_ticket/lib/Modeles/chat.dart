import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final List<Message> messages;

  Chat({
    required this.id,
    required this.participants,
    required this.messages,
  });

  // Factory constructor to create a Chat from Firestore document
  factory Chat.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Chat(
      id: documentId,
      participants: List<String>.from(data['participants']),
      messages: (data['messages'] as List<dynamic>)
          .map((item) => Message.fromFirestore(item))
          .toList(),
    );
  }

  // Method to convert Chat to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'messages': messages.map((message) => message.toFirestore()).toList(),
    };
  }
}

class Message {
  final String idUtilisateur;
  final String message;
  final DateTime date;

  Message({
    required this.idUtilisateur,
    required this.message,
    required this.date,
  });

  // Factory constructor to create a Message from Firestore
  factory Message.fromFirestore(Map<String, dynamic> data) {
    return Message(
      idUtilisateur: data['idUtilisateur'],
      message: data['message'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Method to convert Message to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'idUtilisateur': idUtilisateur,
      'message': message,
      'date': date,
    };
  }
}
