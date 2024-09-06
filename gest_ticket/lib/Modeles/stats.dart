import 'package:cloud_firestore/cloud_firestore.dart';

class Stats {
  final String id;
  final int nbTicketsTotal;
  final int nbTicketsResolu;
  final DateTime date;

  Stats({
    required this.id,
    required this.nbTicketsTotal,
    required this.nbTicketsResolu,
    required this.date,
  });

  // Factory constructor to create Stats from Firestore document
  factory Stats.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Stats(
      id: documentId,
      nbTicketsTotal: data['nbTicketsTotal'],
      nbTicketsResolu: data['nbTicketsResolu'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Method to convert Stats to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'nbTicketsTotal': nbTicketsTotal,
      'nbTicketsResolu': nbTicketsResolu,
      'date': date,
    };
  }
}
