import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuisnessProfilePage extends StatefulWidget {
  final Map<String, dynamic> buisnessData;

  const BuisnessProfilePage({required this.buisnessData, super.key});

  @override
  _BuisnessProfilePageState createState() => _BuisnessProfilePageState();
}

class _BuisnessProfilePageState extends State<BuisnessProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;
  late TextEditingController passwordController;

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Varsayılan verileri doldur
    nameController = TextEditingController(text: widget.buisnessData['buisness_name']);
    phoneController = TextEditingController(text: widget.buisnessData['buisness_phone']);
    emailController = TextEditingController(text: widget.buisnessData['buisness_email']);
    descriptionController = TextEditingController(text: widget.buisnessData['buisness_information']);
    passwordController = TextEditingController(text: widget.buisnessData['buisness_password'].toString());
  }

 Future<void> updateData() async {
  try {
    // Öncelikle buisness_id'ye sahip olan documentId'yi bulalım
    String buisnessId = widget.buisnessData['buisness_id'];

    // Firestore sorgusu ile documentId'yi bul
    final querySnapshot = await FirebaseFirestore.instance
        .collection('buisness_profiles')
        .where('buisness_id', isEqualTo: buisnessId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // İlk belgeyi al (varsayım: buisness_id benzersizdir)
      final document = querySnapshot.docs.first;
      final documentId = document.id;

      // Belgeyi güncelle
      await FirebaseFirestore.instance.collection('buisness_profiles').doc(documentId).update({
        'buisness_name': nameController.text.trim(),
        'buisness_phone': phoneController.text.trim(),
        'buisness_email': emailController.text.trim(),
        'buisness_information': descriptionController.text.trim(),
        'buisness_password': int.parse(passwordController.text.trim()),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler başarıyla güncellendi')),
      );

      setState(() {
        isEditing = false;
      });
    } else {
      // Eğer belge bulunamazsa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belge bulunamadı: buisness_id eşleşmedi')),
      );
    }
  } catch (e) {
    // Hata durumunda kullanıcıya bilgi ver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Güncelleme başarısız: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // İşletme Logosu
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(widget.buisnessData['buisness_logo'] ?? ''),
            ),
            const SizedBox(height: 16),
            // İşletme Adı
            TextField(
              controller: nameController,
              readOnly: !isEditing,
              decoration: const InputDecoration(
                labelText: 'İşletme Adı',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Telefon
            TextField(
              controller: phoneController,
              readOnly: !isEditing,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // E-posta
            TextField(
              controller: emailController,
              readOnly: !isEditing,
              decoration: const InputDecoration(
                labelText: 'E-Posta',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Açıklama
            TextField(
              controller: descriptionController,
              readOnly: !isEditing,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // Şifre
            TextField(
              controller: passwordController,
              readOnly: !isEditing,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Düzenle veya Kaydet Butonu
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  updateData();
                } else {
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isEditing ? 'Kaydet' : 'Düzenle'),
            ),
          ],
        ),
      ),
    );
  }
}
