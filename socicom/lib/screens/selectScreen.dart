import 'package:flutter/material.dart';

class SelectScreen extends StatelessWidget {
  const SelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50), // Yukarıdan biraz boşluk bırakmak için
            Image.asset(
              'assets/socicom_logo.png', // Burada logoyu koyacağın yeri belirtirsin.
              height: 250,
            ),
            const SizedBox(height: 20), // Logo ile uygulama ismi arasında boşluk
            const Text(
              'SOCICOM',
              style: TextStyle(
                fontFamily: 'MontserratAlternates',
                fontSize: 50,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40), // Uygulama ismi ile butonlar arasında boşluk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  // Müşteri Giriş Butonu
                  ElevatedButton(
                    onPressed: () {
                      // Müşteri Giriş butonuna tıklanınca yapılacaklar
                      Navigator.pushNamed(context, '/customerLogin'); // Örnek rota
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // Arka plan rengi
                      foregroundColor: Colors.white, // Yazı rengi
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50), // Butonun genişliği
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Yuvarlak köşeler
                        side: BorderSide(color: Colors.black), // Siyah çerçeve
                      ),
                    ),
                    child: const Text(
                      'Müşteri Giriş',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20), // Butonlar arası boşluk

                  // İşletme Giriş Butonu
                  ElevatedButton(
                    onPressed: () {
                      // İşletme Giriş butonuna tıklanınca yapılacaklar
                      Navigator.pushNamed(context, '/businessLogin'); // Örnek rota
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // Arka plan rengi
                      foregroundColor: Colors.white, // Yazı rengi
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50), // Butonun genişliği
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // Yuvarlak köşeler
                        side: BorderSide(color: Colors.black), // Siyah çerçeve
                      ),
                    ),
                    child: const Text(
                      'İşletme Giriş',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
