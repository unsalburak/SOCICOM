import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/screens/customer/NewCustomerProfileScreen.dart';
import 'package:socicom/screens/customer/CustomerMainPage.dart'; // CustomerMainPage'i ekleyin

class CustomerLoginScreen extends StatefulWidget {
  @override
  _CustomerLoginScreenState createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  bool _isPasswordVisible = false; // Şifre göster/gizle durumu
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Giriş yapma fonksiyonu
  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      // Firestore'dan e-posta ve şifreyi doğrulama
      final querySnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password) // Şifreyi String olarak kontrol
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Giriş başarılı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş başarılı!')),
        );
        // CustomerMainPage sayfasına yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerMainPage()),
        );
      } else {
        // Giriş başarısız
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hatalı e-posta veya şifre')),
        );
      }
    } catch (e) {
      // Hata durumunda mesaj gösterme
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
          icon: Icon(Icons.close, color: Colors.black),
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
              Image.asset(
                'assets/socicom_logo.png', // Logonun yolu
                height: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-Posta Adresi',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orangeAccent),
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
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Şifremi unuttum aksiyonu
                },
                child: Text.rich(
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Giriş yapma fonksiyonunu çağır
                  loginUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Müşteri Giriş',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewCustomerProfileScreen()),
                  );
                },
                child: Text.rich(
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
