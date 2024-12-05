import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/BottomNavigatorBar.dart';
import 'package:socicom/screens/customer/CustomerMainPage.dart';
import 'package:socicom/screens/customer/NewCustomerProfileScreen.dart'; // Yeni sayfa import edilmiştir.

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});

  @override
  _CustomerLoginScreenState createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Firestore'dan kullanıcı sorgulama
      final querySnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Kullanıcı bilgilerini al
        final userDocument = querySnapshot.docs.first;
        final userData = userDocument.data();
        final documentId = userDocument.id;

        userData['documentId'] = documentId; // documentId ekle

        print('Firestore Sorgu Başarılı: $userData'); // Loglama

        // Navigator ile geçiş
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              body: CustomerMainPage(),
              bottomNavigationBar: BottomNavigator(
                currentIndex: 0,
                userData: userData, // Tüm kullanıcı verileri aktarılıyor
                userId: documentId, // userId parametresi burada sağlanıyor
              ),
            ),
          ),
        );
      } else {
        // Kullanıcı bulunamadı
        print('HATA: Firestore sorgusu boş döndü.');
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/socicom_logo.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-Posta Adresi',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Müşteri Giriş',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Şifremi Unuttum (Şimdilik bir şey yapmıyor)
                    },
                    child: const Text(
                      'Şifremi Unuttum',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Yeni Hesap Oluştur (NewCustomerProfileScreen'e yönlendiriyor)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewCustomerProfileScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Yeni Hesap Oluştur',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
