import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:podeli_smetka/screens/home_screen.dart';
import 'package:podeli_smetka/screens/new_event_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _mainScreens = [
    const HomeScreen(),
    const NewEventScreen(),
    const Center(child: Text('Opening camera')) // redirect
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const SizedBox();
    }

    if (_selectedIndex == 2){
      Future.microtask(() {
        Navigator.pushNamed(context, '/scan');
      });
      _selectedIndex = 0;
    }

    return Scaffold(
      body: _mainScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
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
