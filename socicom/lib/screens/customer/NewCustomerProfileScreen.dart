import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewCustomerProfileScreen extends StatefulWidget {
  const NewCustomerProfileScreen({super.key});

  @override
  _NewCustomerProfileScreenState createState() =>
      _NewCustomerProfileScreenState();
}

class _NewCustomerProfileScreenState extends State<NewCustomerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aboutyourselfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedGender = 'Cinsiyet';
  DateTime? _selectedDate;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Benzersiz ve sıralı UserID oluşturma
  Future<String> generateUserId() async {
  try {
    final collection = FirebaseFirestore.instance.collection('profiles');

    // Koleksiyondaki dokümanları sırayla kontrol et
    final querySnapshot =
        await collection.orderBy('userid', descending: true).limit(1).get();

    // Koleksiyonda doküman varsa
    if (querySnapshot.docs.isNotEmpty) {
      // Son kaydın userid'sini kontrol et
      final lastUserId = querySnapshot.docs.first.data()['userid'];
      if (lastUserId != null) {
        // userid varsa artır
        return (int.parse(lastUserId) + 1).toString();
      } else {
        // userid alanı eksikse, 1 ile başla
        return '1';
      }
    } else {
      // Koleksiyon boşsa ilk kullanıcıya '1' ver
      return '1';
    }
  } catch (e) {
    print("UserID oluşturulurken hata: $e");
    return '1'; // Hata durumunda varsayılan olarak '1' döner
  }
}

  // Takvimden tarih seçimi
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Firebase Storage'a resim yükleme
  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(imageFile);

      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Resim seçme
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        _selectedImage = imageFile;
      });

      final imageUrl = await uploadImageToFirebase(imageFile);
      if (imageUrl != null) {
        print('Image uploaded successfully. URL: $imageUrl');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim yüklenirken bir hata oluştu')),
        );
      }
    }
  }

  // Firestore'a veri kaydetme
  Future<void> saveProfileData() async {
    String? photoUrl;
    if (_selectedImage != null) {
      photoUrl = await uploadImageToFirebase(_selectedImage!);
    }

    // Benzersiz bir UserID oluştur
    final userId = await generateUserId();

    await FirebaseFirestore.instance.collection('profiles').add({
      'userid': userId,
      'name': _nameController.text,
      'surname': _surnameController.text,
      'username': _usernameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'about': _aboutyourselfController.text,
      'password': _passwordController.text,
      'gender': _selectedGender,
      'birthDate': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil bilgileri başarıyla kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Yeni Kullanıcı Profil Bilgileri',
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
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera),
                                title: const Text('Kamera'),
                                onTap: () {
                                  _pickImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Galeri'),
                                onTap: () {
                                  _pickImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        _selectedImage != null ? FileImage(_selectedImage!) : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.add_a_photo,
                            size: 50, color: Colors.black54)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'İsim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          labelText: 'Soyisim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                        items: <String>['Cinsiyet', 'Erkek', 'Kadın', 'Diğer']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Doğum Tarihi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.orangeAccent),
                            ),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Tarih seçin'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _aboutyourselfController,
                  decoration: InputDecoration(
                    labelText: 'Hakkında',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await saveProfileData();
                  },
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
                    'Profili Tamamla',
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
