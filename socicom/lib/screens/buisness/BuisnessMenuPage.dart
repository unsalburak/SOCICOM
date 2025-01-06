import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BuisnessMenuPage extends StatefulWidget {
  final Map<String, dynamic> buisnessData;

  const BuisnessMenuPage({
    required this.buisnessData,
    super.key,
  });

  @override
  _BuisnessMenuPageState createState() => _BuisnessMenuPageState();
}

class _BuisnessMenuPageState extends State<BuisnessMenuPage> {
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

  Future<void> _updateMenuItem({
    required String product,
    required double price,
    required String menuItemId,
    File? imageFile,
    String? currentImageUrl,
  }) async {
    try {
      String? imageUrl = currentImageUrl;

      // Eğer yeni bir görsel seçilmişse, Firebase'e yükle
      if (imageFile != null) {
        imageUrl = await _uploadImageToFirebase(imageFile);
      }

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

  Future<void> _pickImage(
    ImageSource source, {
    required Function(File) onImagePicked,
  }) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
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
              final TextEditingController productController =
                  TextEditingController(text: menuItem['product']);
              final TextEditingController priceController =
                  TextEditingController(text: menuItem['price'].toString());

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      _pickImage(
                        ImageSource.gallery,
                        onImagePicked: (pickedImage) {
                          _updateMenuItem(
                            product: productController.text,
                            price: double.tryParse(priceController.text) ?? 0,
                            menuItemId: menuItem.id,
                            imageFile: pickedImage,
                            currentImageUrl: menuItem['image'],
                          );
                        },
                      );
                    },
                    child: menuItem['image'] != null && menuItem['image'].isNotEmpty
                        ? Image.network(
                            menuItem['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                            },
                          )
                        : const Icon(Icons.fastfood, size: 50, color: Colors.orangeAccent),
                  ),
                  title: TextField(
                    controller: productController,
                    decoration: const InputDecoration(
                      hintText: 'Ürün Adı',
                    ),
                    onSubmitted: (value) {
                      _updateMenuItem(
                        product: value,
                        price: double.tryParse(priceController.text) ?? 0,
                        menuItemId: menuItem.id,
                        currentImageUrl: menuItem['image'],
                      );
                    },
                  ),
                  subtitle: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Fiyat',
                    ),
                    onSubmitted: (value) {
                      _updateMenuItem(
                        product: productController.text,
                        price: double.tryParse(value) ?? 0,
                        menuItemId: menuItem.id,
                        currentImageUrl: menuItem['image'],
                      );
                    },
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _updateMenuItem(
                        product: productController.text,
                        price: double.tryParse(priceController.text) ?? 0,
                        menuItemId: menuItem.id,
                        currentImageUrl: menuItem['image'],
                      );
                    },
                    child: const Text('Düzenle'),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni ürün ekleme işlemleri
        },
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
