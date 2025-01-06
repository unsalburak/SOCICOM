import 'package:flutter/material.dart';
import 'package:socicom/screens/buisness/BuisnessFutureReportsPage.dart';
import 'package:socicom/screens/buisness/BuisnessReportsPage.dart';
import 'BuisnessProfilePage.dart'; // İşletme Bilgileriniz sayfası
import 'BuisnessMenuPage.dart'; // İşletme Menüsü sayfası
import 'BuisnessAdressPage.dart'; // İşletme Adres sayfası
import 'BuisnessOrderPage.dart'; // Sipariş Ver sayfası
import 'package:cloud_firestore/cloud_firestore.dart';


class BuisnessMainPage extends StatelessWidget {
  final Map<String, dynamic> buisnessData;
  final Map<String, dynamic> menuData;
  final Map<String, dynamic> addressData;

  const BuisnessMainPage({
    required this.buisnessData,
    required this.menuData,
    required this.addressData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldiniz, ${buisnessData['buisness_name'] ?? 'İşletme Sahibi'}'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCard(
              context,
              icon: Icons.store,
              title: 'İşletme Bilgileriniz',
              subtitle: 'E-Posta: ${buisnessData['buisness_email'] ?? 'Bilinmiyor'}',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuisnessProfilePage(buisnessData: buisnessData),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.menu_book,
              title: 'İşletme Menüsü',
              subtitle: 'Menü öğelerinizi yönetin.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuisnessMenuPage(buisnessData: buisnessData,),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.location_on,
              title: 'İşletme Adres',
              subtitle: 'Adres bilgilerinizi düzenleyin.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuisnessAdressPage(buisnessData: buisnessData,),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              icon: Icons.shopping_cart,
              title: 'Sipariş Ver',
              subtitle: 'Siparişlerinizi kolayca oluşturun.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BuisnessOrderPage(
                      buisnessData: buisnessData,
                      menuData: menuData,
                    ),
                  ),
                );
              },
            ),
            _buildCard(
  context,
  icon: Icons.analytics,
  title: 'İşletme Analizleri',
  subtitle: 'Satışlarınızı ve müşteri analizlerinizi görün.',
  onTap: () async {
    try {
      // Firestore'dan belge ismini al
      final businessId = buisnessData['buisness_id'];
      if (businessId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Reports')
            .where('buisness_id', isEqualTo: businessId)
            .limit(1) // İlk eşleşeni al
            .get();

        if (snapshot.docs.isNotEmpty) {
          final reportId = snapshot.docs.first.id; // Belgenin ID'si
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PowerBIReportScreen(
                reportId: reportId,
              ),
            ),
          );
        } else {
          // Eğer eşleşen bir rapor yoksa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rapor bulunamadı.'),
            ),
          );
        }
      } else {
        // Eğer business_id eksikse
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İşletme kimliği eksik.'),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
        ),
      );
    }
  },
),
_buildCard(
  context,
  icon: Icons.bar_chart,
  title: 'Gelecek Raporlar',
  subtitle: 'Yaklaşan analizlerinizi görün.',
  onTap: () async {
    try {
      // Firestore'dan futureReportId al
      final businessId = buisnessData['buisness_id'];
      if (businessId != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Future_reports') // Farklı bir koleksiyon
            .where('buisness_id', isEqualTo: businessId)
            .limit(1) // İlk eşleşeni al
            .get();

        if (snapshot.docs.isNotEmpty) {
          final futureReportId = snapshot.docs.first.id; // Belgenin ID'si
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessFutureReportsPage(
                futureReportId: futureReportId, // Burada futureReportId gönderiliyor
              ),
            ),
          );
        } else {
          // Eğer eşleşen bir rapor yoksa
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Yaklaşan rapor bulunamadı.'),
            ),
          );
        }
      } else {
        // Eğer business_id eksikse
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('İşletme kimliği eksik.'),
          ),
        );
      }
    } catch (e) {
      // Hata durumunda mesaj göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
        ),
      );
    }
  },
),



          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.orangeAccent, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}
