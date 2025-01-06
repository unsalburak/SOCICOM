import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/utils/BottomNavigatorBar.dart';
import 'CustomerPlaceDetails.dart'; // CustomerPlaceDetails sayfasını doğru şekilde dahil edin
 // BottomNavigator bileşenini dahil edin

class CustomerPlaceList extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? userData;

  const CustomerPlaceList({super.key, required this.userId, this.userData});

  @override
  _CustomerPlaceListState createState() => _CustomerPlaceListState();
}

class _CustomerPlaceListState extends State<CustomerPlaceList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İşletme Listesi"),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buisness_profiles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Hiç işletme bulunamadı."));
          }

          final businessList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: businessList.length,
            itemBuilder: (context, index) {
              final business = businessList[index];
              final data = business.data() as Map<String, dynamic>?;

              if (data == null) {
                return const SizedBox(); // Eğer veri null ise boş bir widget döndür
              }

              final businessName = data['buisness_name'] ?? "Bilinmeyen İşletme";
              final businessLogo = data['buisness_logo'] ?? "https://via.placeholder.com/150";
              final businessId = business.id;
              final businessAttributeId = data['buisness_id'] ?? "Eksik ID";
              final String gender = data.containsKey('gender') ? data['gender'] : "Bilinmiyor";

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(businessLogo),
                      radius: 25,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(
                      businessName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      // CustomerPlaceDetails sayfasına yönlendirme
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerPlaceDetails(
                            customerData: {
                              'documentId': businessId,
                              'buisness_id': businessAttributeId,
                              'buisness_name': businessName,
                              'buisness_logo': businessLogo,
                              'buisness_phone': data['buisness_phone'] ?? '',
                              'buisness_email': data['buisness_email'] ?? '',
                              'buisness_information': data['buisness_information'] ?? '',
                              'gender': gender,
                            },
                            userData: {
                              'gender': widget.userData?['gender'] ?? "Bilinmiyor",
                              'birthDate': widget.userData?['birthDate'] ?? "Bilinmiyor",
                            },
                            userId: widget.userId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(
        currentIndex: 1, // İşletmeler sekmesini aktif yapar
        userData: widget.userData, // Kullanıcı verilerini geçirir
        userId: widget.userId,     // Kullanıcı ID'sini geçirir
      ),
    );
  }
}
