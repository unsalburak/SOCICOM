import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerPlaceDetails extends StatefulWidget {
  final Map<String, dynamic> customerData;
  final Map<String, dynamic>? userData;

  const CustomerPlaceDetails({required this.customerData, this.userData, super.key});

  @override
  State<CustomerPlaceDetails> createState() => _CustomerPlaceDetailsState();
}

class _CustomerPlaceDetailsState extends State<CustomerPlaceDetails> {
  bool isCheckedIn = false;
  String? documentId;

  /// Kullanıcının yaşını hesaplar
  int calculateAgeFromTimestamp(Timestamp birthDateTimestamp) {
    try {
      DateTime birthDate = birthDateTimestamp.toDate();
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0; // Geçersiz bir tarihse yaş 0 olarak döner
    }
  }

  /// Firestore'a giriş işlemini kaydeder
  Future<void> checkIn(BuildContext context) async {
    try {
      final String gender = widget.userData?['gender'] ?? "Bilinmiyor";
      final Timestamp? birthDateTimestamp = widget.userData?['birthDate'];
      int age = 0;

      if (birthDateTimestamp != null) {
        age = calculateAgeFromTimestamp(birthDateTimestamp);
      }

      // İşletme ID'sini ve belge ID'sini al
      final String? businessId = widget.customerData['buisness_id'];
      final String? documentIdFromCustomer = widget.customerData['documentId'];

      if (businessId == null || documentIdFromCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İşletme veya belge ID'si eksik, giriş yapılamadı.")),
        );
        return;
      }

      final docRef = await FirebaseFirestore.instance.collection('ben_buradayim').add({
        'gender': gender, // Kullanıcının cinsiyeti
        'age': age, // Kullanıcının yaşı
        'entry_time': FieldValue.serverTimestamp(), // Giriş zamanı
        'buisness_id': businessId, // İşletme ID'si
        'document_id': documentIdFromCustomer, // Belge ID'si
      });

      setState(() {
        isCheckedIn = true;
        documentId = docRef.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giriş yapıldı!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  /// Firestore'da çıkış işlemini kaydeder
  Future<void> checkOut(BuildContext context) async {
    try {
      if (documentId != null) {
        await FirebaseFirestore.instance
            .collection('ben_buradayim')
            .doc(documentId)
            .update({'check_out_time': FieldValue.serverTimestamp()});

        setState(() {
          isCheckedIn = false;
          documentId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Çıkış yapıldı!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İŞLETME MENÜ'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // İşletme logosu
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.customerData['buisness_logo'] ?? ''),
            ),
            const SizedBox(height: 16),
            // İşletme adı
            Text(
              widget.customerData['buisness_name'] ?? "İşletme Adı",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // İşletme açıklaması
            Text(
              widget.customerData['buisness_information'] ?? "Açıklama Yok",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Telefon bilgisi
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text(
                  widget.customerData['buisness_phone'] ?? "Telefon Yok",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // E-posta bilgisi
            Row(
              children: [
                const Icon(Icons.email, color: Colors.orangeAccent),
                const SizedBox(width: 8),
                Text(
                  widget.customerData['buisness_email'] ?? "E-posta Yok",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Menü ve Adres Butonları
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuScreen(
                          businessId: widget.customerData['documentId'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text("Menü"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressScreen(
                          businessId: widget.customerData['documentId'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  child: const Text("Adres"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // "Ben Buradayım" veya "Ayrılıyorum" Butonu
            ElevatedButton(
              onPressed: () {
                if (isCheckedIn) {
                  checkOut(context);
                } else {
                  checkIn(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCheckedIn ? Colors.red : Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              ),
              child: Text(isCheckedIn ? "Ayrılıyorum" : "Ben Buradayım"),
            ),
          ],
        ),
      ),
    );
  }
}

// Menü Ekranı
class MenuScreen extends StatelessWidget {
  final String businessId;

  const MenuScreen({required this.businessId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menü"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buisness_profiles')
            .doc(businessId)
            .collection('menu')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Menüde ürün bulunamadı."));
          }

          final menuItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return ListTile(
                title: Text(item['name'] ?? "Ürün Adı"),
                subtitle: Text("${item['price']} ₺"),
              );
            },
          );
        },
      ),
    );
  }
}

// Adres Ekranı
class AddressScreen extends StatelessWidget {
  final String businessId;

  const AddressScreen({required this.businessId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adres"),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('buisness_profiles')
            .doc(businessId)
            .collection('address')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Adres bilgisi bulunamadı."));
          }

          final addressList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: addressList.length,
            itemBuilder: (context, index) {
              final address = addressList[index];
              return ListTile(
                title: Text(address['location_name'] ?? "Adres Adı"),
                subtitle: Text(address['details'] ?? "Adres Detayları"),
              );
            },
          );
        },
      ),
    );
  }
}
