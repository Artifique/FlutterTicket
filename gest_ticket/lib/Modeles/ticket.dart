import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  String id;
  String titre;
  String description;
  String priorite;
  String statut;
  DateTime datecreation;
  String categorieId;
  String idCreateur;
  String? idFormateur;
  List<Reponse> reponses;

  Ticket({
    required this.id,
    required this.titre,
    required this.description,
    required this.priorite,
    required this.statut,
    required this.datecreation,
    required this.categorieId,
    required this.idCreateur,
    this.idFormateur,
    this.reponses = const [],
  });

  factory Ticket.fromFirestore(Map<String, dynamic> data, String id) {
    return Ticket(
      id: id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      priorite: data['priorite'] ?? 'Faible',
      statut: data['statut'] ?? 'En attente',
      datecreation: (data['dateCreation'] as Timestamp).toDate(),
      categorieId: data['categorieId'] ?? '',
      idCreateur: data['idCreateur'] ?? '',
      idFormateur: data['idFormateur'],
      reponses: (data['reponses'] as List<dynamic>?)
              ?.map((item) => Reponse.fromFirestore(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'priorite': priorite,
      'statut': statut,
      'dateCreation': datecreation,
      'categorieId': categorieId,
      'idCreateur': idCreateur,
      'idFormateur': idFormateur,
      'reponses': reponses.map((e) => e.toFirestore()).toList(),
    };
  }

  static void fromDocument(QueryDocumentSnapshot<Object?> doc) {}
}

class Reponse {
  String id;
  String contenu;
  DateTime datecreation;
  String idCreateur;

  Reponse({
    required this.id,
    required this.contenu,
    required this.datecreation,
    required this.idCreateur,
  });

  factory Reponse.fromFirestore(Map<String, dynamic> data) {
    return Reponse(
      id: data['id'] ?? '',
      contenu: data['contenu'] ?? '',
      datecreation: (data['dateCreation'] as Timestamp).toDate(),
      idCreateur: data['idCreateur'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'contenu': contenu,
      'dateCreation': datecreation,
      'idCreateur': idCreateur,
    };
  }
}
