import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:socicom/screens/login/BusinessLoginScreen.dart';
import 'package:socicom/screens/login/CustomerLoginScreen.dart';
import 'package:socicom/screens/selectScreen.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SocicomApp());
}

class SocicomApp extends StatelessWidget {
  const SocicomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Başlangıç rotası
      routes: {
        '/': (context) => const SelectScreen(), // Ana giriş ekranı
        '/customerLogin': (context) => const CustomerLoginScreen(), // Müşteri Giriş ekranı
        '/businessLogin': (context) => const BuisnessLoginScreen(), // İşletme Giriş ekranı
      },
    );
  }
}
