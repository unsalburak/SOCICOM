import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewBusinessMenuScreen extends StatefulWidget {
  const NewBusinessMenuScreen({super.key});

  @override
  _NewBusinessMenuScreenState createState() => _NewBusinessMenuScreenState();
}

class _NewBusinessMenuScreenState extends State<NewBusinessMenuScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker(); // ImagePicker instance
  final List<Map<String, dynamic>> _menuItems = []; // Fotoğraflı ürünler için liste

  // Yeni ürün eklemek için fotoğraf ile birlikte fonksiyon
  void _addMenuItem(File? imageFile) {
    final productName = _productNameController.text;
    final price = _priceController.text;

    if (productName.isNotEmpty && price.isNotEmpty && imageFile != null) {
      setState(() {
        _menuItems.add({
          'product': productName,
          'price': price,
          'image': imageFile, // Fotoğraf dosyası ekliyoruz
        });
      });
      _productNameController.clear();
      _priceController.clear();
    }
  }

  // Fotoğraf çekme veya galeriden seçme
  Future<void> _pickImage() async {
    final pickedImage = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Fotoğraf Seç"),
        content: const Text("Kameradan mı yoksa galeriden mi fotoğraf seçmek istersiniz?"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
            },
            child: const Text("Kamera"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
            },
            child: const Text("Galeri"),
          ),
        ],
      ),
    );

    if (pickedImage != null) {
      _addMenuItem(File(pickedImage.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Yeni İşletme Yemek Menüsü',
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
                // Fotoğraf ekleme ikonu
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.add_a_photo, size: 50, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
                // Ürün ismi ve fiyatı TextField'ları
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _productNameController,
                        decoration: InputDecoration(
                          labelText: 'Ürün ismi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.orangeAccent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Fiyat',
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
                // Menü Listesi
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _menuItems.length,
                  itemBuilder: (context, index) {
                    final item = _menuItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: FileImage(item['image']), // Ürün resmi gösterimi
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.orangeAccent),
                                ),
                                hintText: item['product'],
                              ),
                              readOnly: true, // Sadece görüntüleme için
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.orangeAccent),
                                ),
                                hintText: item['price'],
                              ),
                              readOnly: true, // Sadece görüntüleme için
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Menüyü Tamamla Butonu
                ElevatedButton(
                  onPressed: () {
                    // Menüyü tamamlama işlemi
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Menüyü Tamamla',
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
