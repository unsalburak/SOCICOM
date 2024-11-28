import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewCustomerProfileScreen extends StatefulWidget {
  @override
  _NewCustomerProfileScreenState createState() => _NewCustomerProfileScreenState();
}

class _NewCustomerProfileScreenState extends State<NewCustomerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _aboutyourselfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Şifre alanı
  String _selectedGender = 'Cinsiyet';
  DateTime? _selectedDate;

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

  // Firestore'a veri kaydetme fonksiyonu
  Future<void> saveProfileData() async {
    await FirebaseFirestore.instance.collection('profiles').add({
      'name': _nameController.text,
      'surname': _surnameController.text,
      'username': _usernameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'about': _aboutyourselfController.text,
      'password': _passwordController.text, // Şifre kaydediliyor
      'gender': _selectedGender,
      'birthDate': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Bilgilendirme mesajı
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil bilgileri başarıyla kaydedildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
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
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/CustomerProfilePhoto.png'),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'İsim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: TextField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          labelText: 'Soyisim',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                        items: <String>['Cinsiyet', 'Erkek', 'Kadın', 'Atak Helikopteri', 'Sude']
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
                    SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Doğum Tarihi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.orangeAccent),
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
                SizedBox(height: 20),
                TextField(
                  controller: _aboutyourselfController,
                  decoration: InputDecoration(
                    labelText: 'Hakkında',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Şifreyi gizleme
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await saveProfileData();
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
