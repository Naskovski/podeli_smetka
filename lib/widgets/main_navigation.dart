import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:podeli_smetka/screens/home_screen.dart';
import 'package:podeli_smetka/screens/scan_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Define your screens here
  final List<Widget> _mainScreens = [
    const HomeScreen(), // Replace with your home screen widget
    const Center(child: Text('Add Event Screen')), // Placeholder for add event
    const Center(child: Text('Opening camera')) // redirect
  ];

  // Handles tab navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    final User? user = FirebaseAuth.instance.currentUser;

    // If the user is not logged in, navigate to login screen
    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox(); // Empty widget until navigation occurs
    }

    if (_selectedIndex == 2){
      Future.microtask(() {
        Navigator.pushNamed(context, '/scan');
      });
      _selectedIndex = 0;
    }

    return Scaffold(
      body: _mainScreens[_selectedIndex], // Switches the displayed screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple, // Active item color
        unselectedItemColor: Colors.black54, // Inactive item color
        type: BottomNavigationBarType.fixed, // Keeps all labels visible
        backgroundColor: Colors.purple.shade50,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Настани",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Додади",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flip),
            label: "Скенирај",
          ),
        ],
      ),
    );
  }
}
