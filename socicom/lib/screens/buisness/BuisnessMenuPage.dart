import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BuisnessMenuPage extends StatefulWidget {
  final Map<String, dynamic> buisnessData; // İşletme bilgileri

  const BuisnessMenuPage({
    required this.buisnessData,
    super.key,
  });

  @override
  _BuisnessMenuPageState createState() => _BuisnessMenuPageState();
}

class _BuisnessMenuPageState extends State<BuisnessMenuPage> {
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();
  late CollectionReference menuCollection;

  @override
  void initState() {
    super.initState();
    _initializeMenuCollection();
  }

  Future<void> _initializeMenuCollection() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('buisness_profiles')
          .where('buisness_id', isEqualTo: widget.buisnessData['buisness_id'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        setState(() {
          menuCollection = FirebaseFirestore.instance
              .collection('buisness_profiles')
              .doc(documentId)
              .collection('menu');
        });
      } else {
        print('Belge bulunamadı: buisness_id = ${widget.buisnessData['buisness_id']}');
      }
    } catch (e) {
      print('Menu koleksiyonu başlatılırken hata: $e');
    }
  }

  Future<void> _showAddOrEditDialog({DocumentSnapshot? menuItem}) async {
    // Eğer düzenleme işlemi yapılacaksa ilgili alanları doldur
    if (menuItem != null) {
      _productController.text = menuItem['product'] ?? '';
      _priceController.text = menuItem['price']?.toString() ?? '';
      _selectedImage = null; // Görsel değişmeden düzenleme yapılabilir
    } else {
      _productController.clear();
      _priceController.clear();
      _selectedImage = null;
    }

    // Dialog arayüzü
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(menuItem == null ? 'Ürün Ekle' : 'Ürünü Düzenle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Ürün adı alanı
                TextField(
                  controller: _productController,
                  decoration: const InputDecoration(labelText: 'Ürün Adı'),
                ),
                // Ürün fiyatı alanı
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Fiyat'),
                ),
                const SizedBox(height: 10),
                // Seçilen görsel
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : const Text('Henüz bir görsel seçilmedi.'),
                const SizedBox(height: 10),
                // Görsel seçme seçenekleri
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      label: const Text('Galeri'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            // İptal butonu
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            // Kaydet butonu
            TextButton(
              onPressed: () async {
                final product = _productController.text;
                final price = double.tryParse(_priceController.text) ?? 0;

                if (product.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ürün adı boş olamaz!')),
                  );
                  return;
                }

                String? imageUrl;
                if (_selectedImage != null) {
                  imageUrl = await _uploadImageToFirebase(_selectedImage!);
                }

                if (menuItem != null) {
                  // Ürün güncelleme
                  await _updateMenuItem(
                    product: product,
                    price: price,
                    imageUrl: imageUrl,
                    menuItemId: menuItem.id,
                  );
                } else {
                  // Yeni ürün ekleme
                  await _addMenuItem(
                    product: product,
                    price: price,
                    imageUrl: imageUrl,
                  );
                }

                Navigator.pop(context);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final fileName = 'menu_items/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Görsel yüklenirken hata: $e');
      return null;
    }
  }

  Future<void> _addMenuItem({
    required String product,
    required double price,
    String? imageUrl,
  }) async {
    try {
      final menuItem = {
        'product': product,
        'price': price,
        'image': imageUrl ?? '',
        'buisness_id': widget.buisnessData['buisness_id'],
      };

      await menuCollection.add(menuItem);
      print('Yeni ürün başarıyla eklendi.');
    } catch (e) {
      print('Ürün eklenirken hata: $e');
    }
  }

  Future<void> _updateMenuItem({
    required String product,
    required double price,
    String? imageUrl,
    required String menuItemId,
  }) async {
    try {
      final updatedItem = {
        'product': product,
        'price': price,
        'image': imageUrl ?? '',
      };

      await menuCollection.doc(menuItemId).update(updatedItem);
      print('Ürün başarıyla güncellendi.');
    } catch (e) {
      print('Ürün güncellenirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.buisnessData['buisness_name']} Menüsü'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: menuCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Menü boş, yeni ürün ekleyin.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final menuItem = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text(menuItem['product'] ?? 'Ürün Adı Yok'),
                  subtitle: Text('${menuItem['price']} ₺'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showAddOrEditDialog(menuItem: menuItem),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
