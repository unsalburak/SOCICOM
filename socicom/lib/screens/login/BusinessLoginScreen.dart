import 'package:flutter/material.dart';
import 'package:socicom/screens/buisness/NewBuisnessProfileScreen.dart';
 // NewBusinessProfileScreen için doğru import

class BuisnessLoginScreen extends StatefulWidget {
  @override
  _BuisnessLoginScreenState createState() => _BuisnessLoginScreenState();
}

class _BuisnessLoginScreenState extends State<BuisnessLoginScreen> {
  bool _isPasswordVisible = false; // Şifre göster/gizle durumu
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            // Sayfayı kapatma
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
                'assets/socicom_logo.png', // Logonun yolu
                height: 150,
              ),
              SizedBox(height: 20),
              // "Giriş Yap" başlığı
              Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              // E-Posta TextField
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
              // Şifre TextField
              TextField(
                controller: passwordController,
                obscureText: !_isPasswordVisible, // Şifreyi gizle/göster
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orangeAccent),
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
              SizedBox(height: 10),
              // "Şifremi Unuttum" butonu (Ortalanmış ve "Yeni Hesap Oluştur" ile aynı)
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
              // İşletme Giriş Butonu
              ElevatedButton(
                onPressed: () {
                  // İşletme Giriş aksiyonu
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
                  'İşletme Giriş',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              // "Yeni Hesap Oluştur" butonu
              TextButton(
                onPressed: () {
                  // Yeni hesap oluştur sayfasına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewBusinessProfileScreen()), // NewBusinessProfileScreen'e yönlendirme
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
