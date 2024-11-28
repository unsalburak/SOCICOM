import 'package:flutter/material.dart';

class BottomNavigator extends StatelessWidget {
  final int currentIndex;

  const BottomNavigator({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    // Yönlendirme mantığı
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home'); // Ana Sayfa
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/customerPlaceList'); // İşletmeler
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/friends'); // Arkadaşlar
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile'); // Profil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.orangeAccent,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Ana Sayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.business),
          label: 'İşletmeler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Arkadaşlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}
