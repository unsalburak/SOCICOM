import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuisnessOrderPage extends StatefulWidget {
  final Map<String, dynamic> menuData;
  final Map<String, dynamic> buisnessData;

  const BuisnessOrderPage({required this.menuData, required this.buisnessData, super.key});

  @override
  _BuisnessOrderPageState createState() => _BuisnessOrderPageState();
}

class _BuisnessOrderPageState extends State<BuisnessOrderPage> {
  final Map<String, int> selectedItems = {};
  double totalPrice = 0;

void calculateTotal() {
  totalPrice = 0;
  selectedItems.forEach((key, quantity) {
    final itemPrice = double.tryParse(widget.menuData[key]['price'].toString()) ?? 0; // Tür dönüşümü
    totalPrice += itemPrice * quantity;
  });
  setState(() {});
}

Future<void> placeOrder() async {
  try {
    // Veritabanındaki en yüksek order_id'yi bul
    final orderSnapshot = await FirebaseFirestore.instance
        .collection('order') // 'order' koleksiyonu
        .orderBy('order_id', descending: true) // order_id'ye göre sıralama
        .limit(1) // Sadece en sonuncu order_id'yi al
        .get();

    final int lastOrderId = orderSnapshot.docs.isNotEmpty
        ? (orderSnapshot.docs.first.data()['order_id'] as int) // Eğer veri varsa al
        : 0; // Veri yoksa 0 başlangıç değeri

    // Yeni order_id, son order_id'ye 1 eklenerek oluşturulur
    final int newOrderId = lastOrderId + 1;

    // Sıralı item key'leri oluştur
    final Map<String, Map<String, dynamic>> orderedItems = {};
    int itemIndex = 1;

    selectedItems.forEach((key, quantity) {
      orderedItems['item_$itemIndex'] = {
        'product': widget.menuData[key]['product'],
        'price': double.tryParse(widget.menuData[key]['price'].toString()) ?? 0,
        'quantity': quantity,
      };
      itemIndex++;
    });

    // Yeni sipariş verilerini oluştur
    final newOrder = {
      'order_id': newOrderId, // Benzersiz ve artırılmış order_id
      'buisness_id': widget.buisnessData['buisness_id'],
      'order_price': totalPrice,
      'order_items': orderedItems, // Artan sıralı item_1, item_2 yapısı
      'created_at': FieldValue.serverTimestamp(), // Siparişin oluşturulma zamanı
    };

    // 'order' koleksiyonuna yeni siparişi ekle
    await FirebaseFirestore.instance.collection('order').add(newOrder);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sipariş başarıyla verildi!')),
    );

    // Sipariş sonrasında durumu sıfırla
    setState(() {
      selectedItems.clear();
      totalPrice = 0;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sipariş başarısız: $e')),
    );
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sipariş Ver'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: widget.menuData.entries.map((entry) {
                  final itemId = entry.key;
                  final itemData = entry.value;
                  final itemQuantity = selectedItems[itemId] ?? 0;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: itemData['image'] != null
                          ? Image.network(
                              itemData['image'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.fastfood, size: 32, color: Colors.orangeAccent),
                      title: Text(itemData['product'] ?? 'Ürün Adı'),
                      subtitle: Text('${itemData['price'] ?? 0}₺'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              if (itemQuantity > 0) {
                                setState(() {
                                  selectedItems[itemId] = itemQuantity - 1;
                                  if (selectedItems[itemId] == 0) {
                                    selectedItems.remove(itemId);
                                  }
                                  calculateTotal();
                                });
                              }
                            },
                          ),
                          Text('$itemQuantity'),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                selectedItems[itemId] = itemQuantity + 1;
                                calculateTotal();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                Text(
                  'Toplam Tutar: $totalPrice₺',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: selectedItems.isNotEmpty ? placeOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sipariş Ver',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
