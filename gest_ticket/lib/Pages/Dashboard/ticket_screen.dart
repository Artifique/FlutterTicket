import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Ticket {
  final String id;
  final String titre;
  final String description;
  final String priorite;
  final String statut;
  final DateTime datecreation;
  final String categorieId;
  final String idCreateur;
  final String? idFormateur;
  final List<String> reponses;

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
    required this.reponses,
  });

  factory Ticket.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Ticket(
      id: doc.id,
      titre: data['titre'] ?? '',
      description: data['description'] ?? '',
      priorite: data['priorite'] ?? 'Faible',
      statut: data['statut'] ?? 'En attente',
      datecreation: (data['datecreation'] as Timestamp).toDate(),
      categorieId: data['categorieId'] ?? '',
      idCreateur: data['idCreateur'] ?? '',
      idFormateur: data['idFormateur'],
      reponses: List<String>.from(data['reponses'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'description': description,
      'priorite': priorite,
      'statut': statut,
      'datecreation': datecreation,
      'categorieId': categorieId,
      'idCreateur': idCreateur,
      'idFormateur': idFormateur,
      'reponses': reponses,
    };
  }
}

class Categorie {
  final String id;
  final String nom;

  Categorie({required this.id, required this.nom});

  factory Categorie.fromFirestore(Map<String, dynamic> data, String id) {
    return Categorie(
      id: id,
      nom: data['nom'] ?? '',
    );
  }
}

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<Ticket> _tickets = [];
  List<Categorie> _categories = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _loadTickets();
    _loadCategories();
  }

  Future<void> _loadTickets() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('idCreateur', isEqualTo: user?.uid)
        .get();
    setState(() {
      _tickets = snapshot.docs.map((doc) => Ticket.fromFirestore(doc)).toList();
    });
  }

  Future<void> _loadCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      _categories = snapshot.docs.map((doc) => Categorie.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  void _addTicket() async {
    showDialog(
      context: context,
      builder: (context) => TicketDialog(categories: _categories),
    ).then((_) => _loadTickets());
  }

  void _editTicket(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => TicketDialog(
        categories: _categories,
        existingTicket: ticket,
      ),
    ).then((_) => _loadTickets());
  }

  void _deleteTicket(String ticketId) async {
    await FirebaseFirestore.instance.collection('tickets').doc(ticketId).delete();
    _loadTickets();
  }

  void _addCategory() async {
    showDialog(
      context: context,
      builder: (context) => const CategoryDialog(),
    ).then((_) => _loadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: TextField(
          
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Rechercher...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {
              _searchText = value;
            });
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: _addCategory,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTicket,
          ),
        ],
      ),
      body: ListView(
        children: _tickets.where((ticket) {
          return ticket.titre.toLowerCase().contains(_searchText.toLowerCase());
        }).map((ticket) {
          return Card(
            child: ListTile(
              title: Text(ticket.titre),
              subtitle: Text(ticket.description),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editTicket(ticket),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTicket(ticket.id),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TicketDialog extends StatefulWidget {
  final List<Categorie> categories;
  final Ticket? existingTicket;

  const TicketDialog({super.key, required this.categories, this.existingTicket});

  @override
  // ignore: library_private_types_in_public_api
  _TicketDialogState createState() => _TicketDialogState();
}

class _TicketDialogState extends State<TicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priorite = 'Faible';
  String _statut = 'En attente';
  String? _categorieId;

  @override
  void initState() {
    super.initState();
    if (widget.existingTicket != null) {
      _titreController.text = widget.existingTicket!.titre;
      _descriptionController.text = widget.existingTicket!.description;
      _priorite = widget.existingTicket!.priorite;
      _statut = widget.existingTicket!.statut;
      _categorieId = widget.existingTicket!.categorieId;
    } else if (widget.categories.isNotEmpty) {
      _categorieId = widget.categories.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTicket == null ? 'Ajouter un Ticket' : 'Modifier un Ticket'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titreController,
              decoration: const InputDecoration(labelText: 'Titre'),
              validator: (value) => value!.isEmpty ? 'Veuillez entrer un titre' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value!.isEmpty ? 'Veuillez entrer une description' : null,
            ),
            DropdownButtonFormField<String>(
              value: _priorite,
              items: ['Élevée', 'Moyenne', 'Faible'].map((priorite) {
                return DropdownMenuItem(
                  value: priorite,
                  child: Text(priorite),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _priorite = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Priorité'),
            ),
            DropdownButtonFormField<String>(
              value: _statut,
              items: ['En cours', 'En attente', 'Résolu'].map((statut) {
                return DropdownMenuItem(
                  value: statut,
                  child: Text(statut),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _statut = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Statut'),
            ),
            if (widget.categories.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _categorieId,
                items: widget.categories.map((categorie) {
                  return DropdownMenuItem(
                    value: categorie.id,
                    child: Text(categorie.nom),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categorieId = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Catégorie'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final ticket = Ticket(
                id: widget.existingTicket?.id ?? '',
                titre: _titreController.text,
                description: _descriptionController.text,
                priorite: _priorite,
                statut: _statut,
                datecreation: widget.existingTicket != null ? widget.existingTicket!.datecreation : DateTime.now(),
                categorieId: _categorieId!,
                idCreateur: widget.existingTicket?.idCreateur ?? FirebaseAuth.instance.currentUser!.uid,
                idFormateur: widget.existingTicket?.idFormateur,
                reponses: widget.existingTicket?.reponses ?? [],
              );

              if (widget.existingTicket != null) {
                FirebaseFirestore.instance
                    .collection('tickets')
                    .doc(ticket.id)
                    .update(ticket.toFirestore());
              } else {
                FirebaseFirestore.instance
                    .collection('tickets')
                    .add(ticket.toFirestore());
              }

              Navigator.of(context).pop();
            }
          },
          child: Text(widget.existingTicket == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class CategoryDialog extends StatefulWidget {
  const CategoryDialog({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryDialogState createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter une Catégorie'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nomController,
          decoration: const InputDecoration(labelText: 'Nom de la catégorie'),
          validator: (value) => value!.isEmpty ? 'Veuillez entrer un nom' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final nom = _nomController.text;
              final docRef = FirebaseFirestore.instance.collection('categories').doc();

              await docRef.set({'nom': nom});

              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    super.dispose();
  }
}
