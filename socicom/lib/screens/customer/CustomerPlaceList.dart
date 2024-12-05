import 'package:flutter/material.dart';
import 'package:socicom/BottomNavigatorBar.dart'; // BottomNavigatorBar'ın yolu

class CustomerPlaceList extends StatefulWidget {
  final String userId; // Kullanıcı ID'si
  final Map<String, dynamic>? userData; // Kullanıcı bilgileri (isteğe bağlı)

  const CustomerPlaceList({super.key, required this.userId, this.userData});

  @override
  _CustomerPlaceListState createState() => _CustomerPlaceListState();
}

class _CustomerPlaceListState extends State<CustomerPlaceList> {
  @override
  Widget build(BuildContext context) {
    // İşletme isimleri ve ilgili yönlendirme rotaları
    final List<Map<String, String>> businessList = [
      {"name": "BarbeCue", "route": "/barbecueProfile"},
      {"name": "Antojitos", "route": "/antojitosProfile"},
      {"name": "EcoFood", "route": "/ecofoodProfile"},
      {"name": "Fish & Chips", "route": "/fishchipsProfile"},
      {"name": "Gelato 1993", "route": "/gelato1993Profile"},
      {"name": "Old Bar", "route": "/oldbarProfile"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("İşletme Listesi"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: businessList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200, // Simge
                  radius: 25, // Geçici bir arka plan
                  child: Icon(Icons.store, color: Colors.orange),
                ),
                title: Text(
                  businessList[index]["name"]!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // İşletme profiline yönlendirme
                  Navigator.pushNamed(context, businessList[index]["route"]!);
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(
        currentIndex: 1,
        userId: widget.userId, // userId parametresi eklendi
        userData: widget.userData, // userData da isteğe bağlı olarak eklendi
      ),
    );
  }
}
