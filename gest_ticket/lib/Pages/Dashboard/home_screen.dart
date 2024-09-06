import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Importation de fl_chart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche fonctionnelle
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Rechercher',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                // Logique de recherche
              },
            ),
            const SizedBox(height: 20),
            // Row pour les indicateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCard('Total Ticket', _getTotalTickets()),
                _buildStatusCard('Tickets Résolus', _getResolvedTickets()),
                _buildStatusCard('Tickets en attente', _getPendingTickets()),
              ],
            ),
            const SizedBox(height: 20),
            // Les graphiques
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildGraphCard('Nombre de Tickets prises en charge ce mois-ci', 'tickets_by_month'),
                  _buildGraphCard('Nombre de Tickets prises en charge cette année', 'tickets_by_year'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Méthode pour obtenir le nombre total de tickets
  Widget _getTotalTickets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Text(
          snapshot.data!.docs.length.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  // Méthode pour obtenir le nombre de tickets résolus
  Widget _getResolvedTickets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('statut', isEqualTo: 'Résolu')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Text(
          snapshot.data!.docs.length.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  // Méthode pour obtenir le nombre de tickets en attente
  Widget _getPendingTickets() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('statut', isEqualTo: 'En attente')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        return Text(
          snapshot.data!.docs.length.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  // Widget pour créer les cartes de statut
  Widget _buildStatusCard(String title, Widget countWidget) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          countWidget,
        ],
      ),
    );
  }

  // Widget pour créer les cartes de graphique
  Widget _buildGraphCard(String title, String type) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildPieChart(type),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire un graphique circulaire
  Widget _buildPieChart(String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        // Vous pouvez filtrer et préparer vos données en fonction du type ici
      
        final data = snapshot.data!.docs;
        final dataMap = {
          'Résolu': data.where((doc) => doc['statut'] == 'Résolu').length.toDouble(),
          'En attente': data.where((doc) => doc['statut'] == 'En attente').length.toDouble(),
          'Autre': data.where((doc) => doc['statut'] != 'Résolu' && doc['statut'] != 'En attente').length.toDouble(),
        };

        return PieChart(
          PieChartData(
            sections: dataMap.entries.map((entry) {
              final color = entry.key == 'Résolu' ? Colors.green :
                            entry.key == 'En attente' ? Colors.yellow :
                            Colors.red;
              return PieChartSectionData(
                value: entry.value,
                title: '${entry.key}: ${entry.value.toInt()}',
                color: color,
                radius: 50,
                titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              );
            }).toList(),
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: 40,
          ),
        );
      },
    );
  }
}
