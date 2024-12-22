import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewBusinessMenuScreen extends StatefulWidget {
  const NewBusinessMenuScreen({super.key});

  @override
  _NewBusinessMenuScreenState createState() => _NewBusinessMenuScreenState();
}

class _NewBusinessMenuScreenState extends State<NewBusinessMenuScreen> {
  final List<Map<String, dynamic>> menuData = []; // Menü verileri
  int _itemIdCounter = 1; // Benzersiz ID sayacı

  // Yeni ürün eklemek için fonksiyon
  void _addMenuItem() {
    setState(() {
      menuData.add({
        'id': _itemIdCounter, // Her ürün için benzersiz bir ID
        'product': '',
        'price': '',
        'image': null,
      });
      _itemIdCounter++; // ID sayacını artır
    });
  }

  // Menüyü tamamlayıp önceki sayfaya yönlendirme
  void _completeMenu() {
    Navigator.pop(context, menuData); // Menü verilerini geri gönder
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Menü Listesi
              Expanded(
                child: ListView.builder(
                  itemCount: menuData.length,
                  itemBuilder: (context, index) {
                    return ItemCard(
                      itemData: menuData[index],
                      onUpdate: (updatedData) {
                        setState(() {
                          menuData[index] = updatedData;
                        });
                      },
                      onDelete: () {
                        setState(() {
                          menuData.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Yeni Ürün Ekle Butonu
              ElevatedButton(
                onPressed: _addMenuItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Yeni Ürün Ekle',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              // Menüyü Tamamla ve Geri Dön
              ElevatedButton(
                onPressed: _completeMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
    );
  }
}

class ItemCard extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.itemData,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.itemData['product'];
    _priceController.text = widget.itemData['price'];
    _imageFile = widget.itemData['image'];
  }

  void _pickImage() async {
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
      setState(() {
        _imageFile = File(pickedImage.path);
      });
      _updateData();
    }
  }

  void _updateData() {
    widget.onUpdate({
      'id': widget.itemData['id'], // ID sabit kalır
      'product': _productNameController.text,
      'price': _priceController.text,
      'image': _imageFile,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null ? const Icon(Icons.add_a_photo, size: 30) : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün ismi',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _updateData(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _updateData(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
