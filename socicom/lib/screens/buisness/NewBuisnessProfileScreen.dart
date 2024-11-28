import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socicom/screens/buisness/NewBuisnessAddressScreen.dart';
import 'package:socicom/screens/buisness/NewBuisnessMenuScreen.dart';

class NewBusinessProfileScreen extends StatefulWidget {
  @override
  _NewBusinessProfileScreenState createState() => _NewBusinessProfileScreenState();
}

class _NewBusinessProfileScreenState extends State<NewBusinessProfileScreen> {
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // Şifre göster/gizle durumu
  File? _selectedImage; // Seçilen profil fotoğrafı için değişken
  final ImagePicker _picker = ImagePicker(); // ImagePicker örneği

  // Fotoğraf seçme işlevi
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Yeni İşletme Profil Bilgileri',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                // Profil fotoğrafı ekleme alanı
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? Icon(Icons.add_a_photo, size: 50, color: Colors.black54)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                // İşletme ismi TextField
                TextField(
                  controller: _businessNameController,
                  decoration: InputDecoration(
                    labelText: 'İşletme ismi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // İşletme Telefon Numarası TextField
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'İşletme Telefon Numarası',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Hakkında TextField
                TextField(
                  controller: _aboutController,
                  decoration: InputDecoration(
                    labelText: 'Hakkında',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // E-posta adresi TextField
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-PostaAdresi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Şifre TextField
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Şifreyi gizle/göster
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
                SizedBox(height: 20),
                // Menü ve Adres Bilgileri Butonları
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Menü Bilgileri sayfasına yönlendirme
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewBusinessMenuScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Menü Bilgileri',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Adres Bilgileri sayfasına yönlendirme
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewBusinessAddressScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Adres Bilgileri',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Yeni Hesap Oluştur Butonu
                ElevatedButton(
                  onPressed: () {
                    // Yeni Hesap Oluştur işlemi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Yeni Hesap Oluştur',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
