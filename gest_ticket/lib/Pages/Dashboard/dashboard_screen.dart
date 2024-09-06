import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gest_ticket/Pages/Dashboard/admin_screen.dart';
import 'package:gest_ticket/Pages/Dashboard/apprenant_screen.dart';
import 'package:gest_ticket/Pages/Dashboard/formateur_screen.dart';
import 'package:gest_ticket/Pages/Dashboard/home_screen.dart';
import 'package:gest_ticket/Pages/Dashboard/profile_screen.dart';
import 'package:gest_ticket/Pages/Dashboard/ticket_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    ApprenantScreen(),
    FormateurScreen(),
    AdminScreen(),
    TicketScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login screen or show a message if needed
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      // Handle errors if needed
      if (kDebugMode) {
        print("Erreur de déconnexion : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (MediaQuery.of(context).size.width <= 770)
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            const SizedBox(width: 8),
            Text('Dashboard'),
          ],
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
      ),
      drawer: MediaQuery.of(context).size.width <= 770
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2C3E50),
                    ),
                    child: Container(
                      child: Image.asset(
                        'images/logo.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                  ),
                  _drawerItem(Icons.home, 'Accueil', 0),
                  _drawerItem(Icons.school, 'Apprenant', 1),
                  _drawerItem(Icons.person, 'Formateur', 2),
                  _drawerItem(Icons.person, 'Admin', 3),
                  _drawerItem(Icons.assignment, 'Tickets', 4),
                  _drawerItem(Icons.person, 'Profil', 5),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Déconnexion'),
                    onTap: _signOut,
                  ),
                ],
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 770;

          return Row(
            children: [
              if (isWideScreen)
                NavigationRail(
                  backgroundColor: const Color(0xFF2C3E50),
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.selected,
                  destinations: [
                    _navigationRailDestination(Icons.home, 'Accueil', 0),
                    _navigationRailDestination(Icons.school, 'Apprenant', 1),
                    _navigationRailDestination(Icons.person, 'Formateur', 2),
                    _navigationRailDestination(Icons.person, 'Admin', 3),
                    _navigationRailDestination(Icons.assignment, 'Tickets', 4),
                    _navigationRailDestination(Icons.person, 'Profil', 5),
                  ],
                  trailing: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: _signOut,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.logout, color: Color.fromARGB(255, 196, 109, 109)),
                              SizedBox(width: 8),
                              Text('Déconnexion'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _selectedIndex == index,
      onTap: () {
        Navigator.pop(context);
        _onItemTapped(index);
      },
    );
  }

  NavigationRailDestination _navigationRailDestination(IconData icon, String label, int index) {
    return NavigationRailDestination(
      icon: Icon(icon, color: Colors.white),
      selectedIcon: Icon(icon),
      label: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
