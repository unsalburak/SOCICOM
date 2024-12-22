import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/screens/buisness/NewBuisnessProfileScreen.dart';
import 'package:socicom/screens/buisness/BuisnessMainPage.dart'; // İşletme ana sayfası için import

class BuisnessLoginScreen extends StatefulWidget {
  const BuisnessLoginScreen({super.key});

  @override
  _BuisnessLoginScreenState createState() => _BuisnessLoginScreenState();
}

class _BuisnessLoginScreenState extends State<BuisnessLoginScreen> {
  bool _isPasswordVisible = false; // Şifre göster/gizle durumu
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

Future<void> loginUser() async {
  String email = emailController.text.trim();
  String passwordInput = passwordController.text.trim();

  // Kullanıcıdan alınan şifreyi int türüne dönüştür
  int? password = int.tryParse(passwordInput);

  if (password == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifre yalnızca sayılardan oluşmalıdır.')),
    );
    return;
  }

  try {
    // Firestore'dan kullanıcı bilgilerini sorgula
    final querySnapshot = await FirebaseFirestore.instance
        .collection('buisness_profiles')
        .where('buisness_email', isEqualTo: email)
        .where('buisness_password', isEqualTo: password)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Ana belgeyi al
      final userDocument = querySnapshot.docs.first;
      final documentId = userDocument.id; // Belge ID'si
      final buisnessData = userDocument.data(); // Ana belge verileri

      // Alt koleksiyonları sorgula: Menü
      final menuSnapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .doc(documentId)
          .collection('menu')
          .get();

      final menuData = {
        for (var doc in menuSnapshot.docs) doc.id: doc.data()
      };

      // Alt koleksiyonları sorgula: Adres
      final addressSnapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .doc(documentId)
          .collection('address')
          .get();

      final addressData = {
        for (var doc in addressSnapshot.docs) doc.id: doc.data()
      };

      // Ana sayfaya yönlendirme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BuisnessMainPage(
            buisnessData: buisnessData,
            menuData: menuData,
            addressData: addressData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hatalı e-posta veya şifre')),
      );
    }
  } catch (e) {
    print('Firestore Hatası: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bir hata oluştu: $e')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/socicom_logo.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              // E-Posta TextField
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-Posta Adresi',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Şifre TextField
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible, // Şifreyi gizle/göster
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orangeAccent),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Şifremi unuttum aksiyonu
                },
                child: const Text.rich(
                  TextSpan(
                    text: 'Şifremi ',
                    children: [
                      TextSpan(
                        text: 'Unuttum',
                        style: TextStyle(color: Colors.orangeAccent),
                      ),
                    ],
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'İşletme Giriş',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Yeni hesap oluştur sayfasına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewBuisnessProfileScreen(),
                    ),
                  );
                },
                child: const Text.rich(
                  TextSpan(
                    text: 'Yeni ',
                    children: [
                      TextSpan(
                        text: 'Hesap Oluştur',
                        style: TextStyle(color: Colors.orangeAccent),
                      ),
                    ],
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
