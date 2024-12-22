import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'NewBuisnessMenuScreen.dart';
import 'NewBuisnessAddressScreen.dart';

class NewBuisnessProfileScreen extends StatefulWidget {
  const NewBuisnessProfileScreen({super.key});

  @override
  _NewBuisnessProfileScreenState createState() =>
      _NewBuisnessProfileScreenState();
}

class _NewBuisnessProfileScreenState extends State<NewBuisnessProfileScreen> {
  final TextEditingController _buisnessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> menuData = [];
  Map<String, double>? addressCoordinates;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _navigateToAddressScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewBusinessAddressScreen()),
    );

    if (result != null && result is Map<String, double>) {
      setState(() {
        addressCoordinates = result;
      });
    }
  }

  Future<void> _navigateToMenuScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewBusinessMenuScreen()),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        menuData = result;
      });
    }
  }

  Future<void> saveBuisnessProfile() async {
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('buisness_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .orderBy('buisness_id', descending: true)
          .limit(1)
          .get();

      int newBuisnessId = 1;
      if (querySnapshot.docs.isNotEmpty) {
        final highestId = int.parse(querySnapshot.docs.first['buisness_id']);
        newBuisnessId = highestId + 1;
      }

      final businessDocRef =
          FirebaseFirestore.instance.collection('buisness_profiles').doc();

      await businessDocRef.set({
        'buisness_email': _emailController.text.trim(),
        'buisness_information': _aboutController.text.trim(),
        'buisness_logo': imageUrl ?? '',
        'buisness_name': _buisnessNameController.text.trim(),
        'buisness_phone': _phoneController.text.trim(),
        'buisness_id': newBuisnessId.toString(),
        'buisness_password': int.parse(_passwordController.text.trim()),
      });

      if (menuData.isNotEmpty) {
        final menuCollectionRef = businessDocRef.collection('menu');
        int itemIdCounter = 1;

        for (final menuItem in menuData) {
          String? menuImageUrl;

          if (menuItem['image'] != null && menuItem['image'] is File) {
            final menuStorageRef = FirebaseStorage.instance
                .ref()
                .child('menu_items/${DateTime.now().millisecondsSinceEpoch}.jpg');
            await menuStorageRef.putFile(menuItem['image']);
            menuImageUrl = await menuStorageRef.getDownloadURL();
          }

          await menuCollectionRef.add({
            'item_id': itemIdCounter.toString(),
            'buisness_id': newBuisnessId.toString(),
            'product': menuItem['product'],
            'price': menuItem['price'],
            'image': menuImageUrl ?? '',
          });

          itemIdCounter++;
        }
      }

      if (addressCoordinates != null) {
        final addressCollectionRef = businessDocRef.collection('address');
        await addressCollectionRef.add({
          'latitude': addressCoordinates!['latitude'],
          'longitude': addressCoordinates!['longitude'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil ve adres başarıyla kaydedildi!')),
      );

      Navigator.pop(context);
    } catch (e) {
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
        title: const Text(
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
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.add_a_photo,
                            size: 50, color: Colors.black54)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _buisnessNameController,
                  decoration: InputDecoration(
                    labelText: 'İşletme İsmi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _aboutController,
                  decoration: InputDecoration(
                    labelText: 'Hakkında',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta Adresi',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.number,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _navigateToAddressScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Adres'),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _navigateToMenuScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Menü'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: saveBuisnessProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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
