import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/screens/customer/CustomerDirections.dart';
import 'package:socicom/screens/customer/CustomerPlaceMenuScreen.dart';

class CustomerPlaceDetails extends StatefulWidget {
  final Map<String, dynamic> customerData;
  final Map<String, dynamic>? userData;
  final String userId;

  const CustomerPlaceDetails({
    required this.customerData,
    this.userData,
    required this.userId,
    super.key,
  });

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

      // İşletme ID'sini al
      final String? businessId = widget.customerData['buisness_id'];

      if (businessId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("İşletme ID'si eksik, giriş yapılamadı.")),
        );
        return;
      }

      // Kullanıcı girişini kaydet
      final docRef = await FirebaseFirestore.instance.collection('ben_buradayim').add({
        'gender': gender,
        'age': age,
        'entry_time': FieldValue.serverTimestamp(),
        'buisness_id': businessId,
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
                        builder: (context) => CustomerPlaceDetailsMenuScreen(
                          businessId: widget.customerData['buisness_id'], // buisness_id gönderiliyor
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
                        builder: (context) => CustomerDirectionsWithRoute(
                          buisnessId: widget.customerData['buisness_id'], // buisness_id gönderiliyor
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
