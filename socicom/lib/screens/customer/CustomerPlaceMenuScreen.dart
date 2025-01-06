import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerPlaceDetailsMenuScreen extends StatelessWidget {
  final String businessId;

  const CustomerPlaceDetailsMenuScreen({required this.businessId, super.key});

  Future<List<Map<String, dynamic>>> fetchMenuItems() async {
    // Firestore'dan doğru şekilde menu alt koleksiyonunu al
    final menuSnapshot = await FirebaseFirestore.instance
        .collection('buisness_profiles')
        .where('buisness_id', isEqualTo: businessId)
        .get();

    if (menuSnapshot.docs.isEmpty) {
      return [];
    }

    // İlk belgeyi al ve menu alt koleksiyonundaki belgeleri çek
    final buisnessDocId = menuSnapshot.docs.first.id;

    final menuCollection = await FirebaseFirestore.instance
        .collection('buisness_profiles')
        .doc(buisnessDocId)
        .collection('menu')
        .get();

    return menuCollection.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Müşteri Menü"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Bir hata oluştu: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Menüde herhangi bir ürün bulunamadı.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final menuItems = snapshot.data!;

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ürün Resmi
                    if (item['image'] != null)
                      Image.network(
                        item['image'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ürün Adı
                          Text(
                            item['product'] ?? "Ürün Adı Yok",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          // Ürün Fiyatı
                          Text(
                            "Fiyat: ${item['price'] ?? "Bilinmiyor"}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
