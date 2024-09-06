import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gest_ticket/Modeles/ticket.dart';
import 'package:gest_ticket/Pages/acceuil.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Recherche extends StatefulWidget {
  const Recherche({super.key});

  @override
  State<Recherche> createState() => _RechercheState();
}

class _RechercheState extends State<Recherche> {
  String searchQuery = ''; // Variable pour le texte de recherche
  List<Ticket> tickets = []; // Liste des tickets

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  // Fonction pour récupérer les tickets depuis Firestore
  void fetchTickets() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid; // Récupérer l'ID de l'utilisateur connecté

    if (userId == null) {
      // Si l'utilisateur n'est pas connecté, ne rien faire ou afficher un message d'erreur
      setState(() {
        tickets = [];
      });
      return;
    }

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('tickets')
          .where('idCreateur', isEqualTo: userId) // Filtrer les tickets par ID de l'utilisateur
          .get();

      List<Ticket> loadedTickets = querySnapshot.docs.map((doc) {
        return Ticket.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      if (kDebugMode) {
        print("Tickets fetched: $loadedTickets");
      } // Débogage

      setState(() {
        tickets = loadedTickets;
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching tickets: $e");
      } // Débogage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9), // Couleur de fond de la page
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Recherche',
          ),
        ),
        backgroundColor: const Color(0xFFD9D9D9), // Couleur de fond de l'AppBar
        foregroundColor: Colors.black, // Couleur du texte de l'AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            searchField(),
            const SizedBox(height: 20), // Espacement entre le champ de recherche et la grille
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Nombre de colonnes
                  crossAxisSpacing: 10, // Espacement entre les colonnes
                  mainAxisSpacing: 10, // Espacement entre les lignes
                  childAspectRatio: 0.6, // Ratio pour ajuster la taille des cartes
                ),
                itemCount: filteredTickets().length, // Nombre total de cartes (filtré)
                itemBuilder: (context, index) {
                  return ticketDetails(filteredTickets()[index]); // Affiche chaque carte des détails du ticket
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour filtrer les tickets en fonction du texte de recherche
  List<Ticket> filteredTickets() {
    if (searchQuery.isEmpty) {
      return tickets;
    } else {
      return tickets
          .where((ticket) =>
              ticket.titre.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Fonction pour afficher le champ de recherche
  Widget searchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        hintText: "Recherche",
        prefixIcon: const Icon(
          Icons.search,
          size: 30,
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        contentPadding: const EdgeInsets.all(15),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 255, 255),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  // Fonction pour afficher les détails du ticket avec le titre comme en-tête
  Widget ticketDetails(Ticket ticket) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Acceuil(),
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        height: 80, // Taille ajustée pour la carte
        width: 90, // Taille ajustée pour la carte
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 55, // Taille augmentée pour l'en-tête noir
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                ticket.titre,
                style: const TextStyle(
                  fontSize: 16, // Taille du texte plus grande
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Container(
                // Hauteur ajustée pour la section blanche
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.all(12.0), // Ajout d'un padding pour augmenter la marge
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${ticket.description}', style: const TextStyle(fontSize: 14)), // Texte plus grand
                    const SizedBox(height: 8),
                    Text('Date: ${ticket.datecreation}', style: const TextStyle(fontSize: 14)), // Texte plus grand
                    const SizedBox(height: 8),
                    Text('Priorite: ${ticket.priorite}', style: const TextStyle(fontSize: 14)), // Texte plus grand
                    const SizedBox(height: 8),
                    Text('Statut: ${ticket.statut}', style: const TextStyle(fontSize: 14)), // Texte plus grand
                    const SizedBox(height: 8),
                    Text('Categorie: ${ticket.categorieId}', style: const TextStyle(fontSize: 14)), // Texte plus grand
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
