import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gest_ticket/Modeles/categorie.dart';
import 'package:gest_ticket/Modeles/ticket.dart';

Future<User?> getCurrentUser() async {
  return FirebaseAuth.instance.currentUser;
}

Future<List<Categorie>> getCategories() async {
  final snapshot = await FirebaseFirestore.instance.collection('categories').get();
  return snapshot.docs.map((doc) => Categorie.fromFirestore(doc.data(), doc.id)).toList();
}

Future<void> addTicket(Ticket ticket) async {
  final ticketCollection = FirebaseFirestore.instance.collection('tickets');
  await ticketCollection.add(ticket.toFirestore());
}

Stream<List<Ticket>> getTickets() {
  return FirebaseFirestore.instance
      .collection('tickets')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Ticket.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  });
}
