import 'package:cloud_firestore/cloud_firestore.dart';

class Reponse {
  final String idUtilisateur;
  final String message;
  final DateTime date;

  Reponse({
    required this.idUtilisateur,
    required this.message,
    required this.date,
  });

  // Factory constructor to create a Reponse from Firestore
  factory Reponse.fromFirestore(Map<String, dynamic> data) {
    return Reponse(
      idUtilisateur: data['idUtilisateur'],
      message: data['message'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Method to convert Reponse to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'idUtilisateur': idUtilisateur,
      'message': message,
      'date': date,
    };
  }
}
