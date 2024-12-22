import 'package:flutter/material.dart';

class BuisnessAdressPage extends StatelessWidget {
  final Map<String, dynamic> addressData;

  const BuisnessAdressPage({required this.addressData, super.key});

  @override
  Widget build(BuildContext context) {
    final address = addressData['address_id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletme Adresiniz'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enlem (Latitude): ${address?['latitude'] ?? 'Bilinmiyor'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Boylam (Longitude): ${address?['longitude'] ?? 'Bilinmiyor'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Burada ileride bir harita gösterimi yapılabilir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
