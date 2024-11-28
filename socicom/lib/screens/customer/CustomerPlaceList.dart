import 'package:flutter/material.dart';

class CustomerPlaceList extends StatefulWidget {
  @override
  _CustomerPlaceListState createState() => _CustomerPlaceListState();
}

class _CustomerPlaceListState extends State<CustomerPlaceList> {
  int _selectedIndex = 1; // İşletmeler sekmesi için varsayılan index (1)

  // Navigasyon değişikliğini kontrol eden fonksiyon
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Burada alt menü için yönlendirme yapılabilir.
    // Örneğin: Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

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
        title: Text("İşletme Listesi"),
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
                  backgroundColor: Colors.grey.shade200, // Geçici bir arka plan
                  child: Icon(Icons.store, color: Colors.orange), // Simge
                  radius: 25,
                ),
                title: Text(
                  businessList[index]["name"]!,
                  style: TextStyle(fontWeight: FontWeight.bold),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'İşletmeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Arkadaşlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
