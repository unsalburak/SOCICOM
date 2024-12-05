import 'package:flutter/material.dart';
import 'package:socicom/screens/customer/CustomerMainPage.dart';
import 'package:socicom/screens/customer/CustomerPlaceList.dart';
import 'package:socicom/screens/customer/CustomerProfileScreen.dart';
import 'package:socicom/screens/customer/FriendList.dart';

class BottomNavigator extends StatelessWidget {
  final int currentIndex;
  final Map<String, dynamic>? userData;
  final String userId; // userId parametresi eklendi

  const BottomNavigator({
    super.key,
    required this.currentIndex,
    this.userData,
    required this.userId, // userId'yi zorunlu hale getiriyoruz
  });

  void _onItemTapped(BuildContext context, int index) {
    if (currentIndex == index) return;

    late Widget targetPage;

    // Varsayılan veri kontrolü
    final Map<String, dynamic> validUserData = userData ?? {
      'email': 'varsayilan@email.com',
      'username': 'Varsayılan Kullanıcı',
      'phone': '0000000000',
      'gender': 'Bilinmiyor',
      'birthDate': '',
      'photoUrl': 'https://via.placeholder.com/150',
      'name': 'Varsayılan',
      'surname': 'Kullanıcı',
      'password': '123456',
    };

    print('BottomNavigator Received userData: $validUserData');

    switch (index) {
      case 0:
        targetPage = CustomerMainPage();
        break;
      case 1:
        targetPage = CustomerPlaceList(
          userData: validUserData,
          userId: userId,
        );
        break;
      case 2:
        targetPage = FriendsList(
          userData: validUserData,
          userId: userId,
          );
        break;
      case 3:
        targetPage = CustomerProfile(
          userData: validUserData,
          userId: userId, // Burada userId parametresini aktarıyoruz
        );
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
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
