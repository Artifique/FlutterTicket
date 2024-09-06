import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id;
  final String idUtilisateur;
  final String message;
  final DateTime dateEnvoi;
  final bool vu;

  Notification({
    required this.id,
    required this.idUtilisateur,
    required this.message,
    required this.dateEnvoi,
    required this.vu,
  });

  // Factory constructor to create a Notification from Firestore document
  factory Notification.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Notification(
      id: documentId,
      idUtilisateur: data['idUtilisateur'],
      message: data['message'],
      dateEnvoi: (data['dateEnvoi'] as Timestamp).toDate(),
      vu: data['vu'],
    );
  }

  // Method to convert Notification to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'idUtilisateur': idUtilisateur,
      'message': message,
      'dateEnvoi': dateEnvoi,
      'vu': vu,
    };
  }
}
