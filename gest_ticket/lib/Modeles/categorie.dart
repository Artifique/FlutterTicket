class Categorie {
  String id;
  String nom;

  Categorie({
    required this.id,
    required this.nom,
  });

  factory Categorie.fromFirestore(Map<String, dynamic> data, String id) {
    return Categorie(
      id: id,
      nom: data['nom'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
    };
  }
}
