import 'package:flutter/material.dart';
import 'package:socicom/screens/buisness/BuisnessReportsPage.dart';
import 'BuisnessProfilePage.dart'; // İşletme Bilgileriniz sayfası
import 'BuisnessMenuPage.dart'; // İşletme Menüsü sayfası
import 'BuisnessAdressPage.dart'; // İşletme Adres sayfası
import 'BuisnessOrderPage.dart'; // Sipariş Ver sayfası

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
                    builder: (context) => BuisnessAdressPage(addressData: addressData),
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
  onTap: () {
    // Navigator ile PowerBIReportScreen'e yönlendirme
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PowerBIReportScreen(
          reportId: 'Report1', // Firebase'deki raporun ID'si
        ),
      ),
    );
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
