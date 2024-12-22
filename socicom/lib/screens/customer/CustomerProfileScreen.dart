import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CustomerProfile extends StatefulWidget {
  final Map<String, dynamic> userData;
  final String userId;

  const CustomerProfile({super.key, required this.userData, required this.userId});

  @override
  _CustomerProfileState createState() => _CustomerProfileState();
}

class _CustomerProfileState extends State<CustomerProfile> {
  late TextEditingController phoneController;
  late TextEditingController genderController;
  late TextEditingController birthDateController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  String? profileImageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController(text: widget.userData['phone']);
    genderController = TextEditingController(text: widget.userData['gender']);
    birthDateController = TextEditingController(
        text: widget.userData['birthDate'] != null
            ? (widget.userData['birthDate'] as Timestamp)
                .toDate()
                .toIso8601String()
                .split('T')[0]
            : '');
    emailController = TextEditingController(text: widget.userData['email']);
    usernameController =
        TextEditingController(text: widget.userData['username']);
    passwordController =
        TextEditingController(text: widget.userData['password']);
    profileImageUrl = widget.userData['photoUrl'];
  }

  @override
  void dispose() {
    phoneController.dispose();
    genderController.dispose();
    birthDateController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${widget.userId}.jpg');
        await storageRef.putFile(file);
        final newProfileImageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('profiles')
            .doc(widget.userId)
            .update({'photoUrl': newProfileImageUrl});

        setState(() {
          profileImageUrl = newProfileImageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf güncellenemedi: $e')),
        );
      }
    }
  }

  Future<void> saveProfile() async {
    final updatedData = {
      'phone': phoneController.text,
      'gender': genderController.text,
      'birthDate': birthDateController.text.isNotEmpty
          ? Timestamp.fromDate(DateTime.parse(birthDateController.text))
          : null,
      'email': emailController.text,
      'username': usernameController.text,
      'password': passwordController.text,
      'photoUrl': profileImageUrl,
    };

    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.userId)
          .update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil başarıyla güncellendi!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }

  InputDecoration _buildInputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.orange),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : const NetworkImage(
                              'https://via.placeholder.com/150'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.userData['name'] ?? ''} ${widget.userData['surname'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration('Telefon', Icons.phone),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: genderController,
                          decoration: _buildInputDecoration('Cinsiyet', Icons.male),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: birthDateController,
                          readOnly: true,
                          decoration: _buildInputDecoration(
                              'Doğum Tarihi', Icons.calendar_today),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                birthDateController.text =
                                    pickedDate.toIso8601String().split('T')[0];
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _buildInputDecoration('E-posta', Icons.email),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: usernameController,
                    decoration: _buildInputDecoration('Kullanıcı Adı', Icons.person),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: _buildInputDecoration('Şifre', Icons.lock),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Düzenle'),
            ),
          ],
        ),
      ),
    );
  }
}
