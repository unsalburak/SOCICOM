import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/BottomNavigatorBar.dart';

class FriendsList extends StatelessWidget {
  final String userId; // Kullanıcı ID'si
  final Map<String, dynamic>? userData; // Kullanıcı bilgileri

  const FriendsList({super.key, required this.userId, this.userData});

 Future<List<Map<String, dynamic>>> fetchFriends() async {
  List<Map<String, dynamic>> friends = [];

  try {
    // userData'dan userid alınıyor
    final String actualUserId = userData?['userid'] ?? ''; // 'userid' doğru değerle alınır

    if (actualUserId.isEmpty) {
      print("Geçerli bir userid bulunamadı.");
      return [];
    }

    // İlk olarak userid alanına göre doğru belgeyi bul
    QuerySnapshot profileSnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .where('userid', isEqualTo: actualUserId) // 'userid' kullanılıyor
        .get();

    print("Profiles'dan dönen belgeler: ${profileSnapshot.docs}");

    if (profileSnapshot.docs.isEmpty) {
      print("Kullanıcı profili bulunamadı: $actualUserId");
      return [];
    }

    // İlk belgeyi al
    DocumentSnapshot userProfile = profileSnapshot.docs.first;

    // Bulunan belgenin altındaki friends koleksiyonuna eriş
    QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(userProfile.id) // Bulunan belgenin ID'si
        .collection('friends')
        .get();

    print("Friends'den dönen belgeler: ${friendsSnapshot.docs}");

    // Eğer friends alt koleksiyonu boşsa, kullanıcıya arkadaş yok mesajı göster
    if (friendsSnapshot.docs.isEmpty) {
      print("Hiç arkadaş bulunamadı (friends alt koleksiyonu boş).");
      return [];
    }

    // Friends koleksiyonundaki tüm userid'leri al
    List<String> friendUserIds = friendsSnapshot.docs
        .map((doc) => doc['userid'] as String) // 'userid' kullanılıyor
        .toList();

    print("Arkadaşların userid'leri: $friendUserIds");

    if (friendUserIds.isEmpty) {
      print("Hiç arkadaş yok!");
      return [];
    }

    // Profiles koleksiyonunda arkadaşların bilgilerini al
    QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .where('userid', whereIn: friendUserIds) // 'userid' ile sorgu
        .get();

    print("Profiles'dan arkadaş bilgilerinden dönen belgeler: ${profilesSnapshot.docs}");

    for (var doc in profilesSnapshot.docs) {
      Map<String, dynamic> friendData = doc.data() as Map<String, dynamic>;
      friends.add(friendData);
    }

    print("Arkadaşlar başarıyla alındı: ${friends.length}");
  } catch (e) {
    print("Hata: $e");
  }

  return friends;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arkadaşlar")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFriends(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Hiç arkadaşınız yok!"));
          }

          List<Map<String, dynamic>> friends = snapshot.data!;

          return ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: friend['profileImage'] != null &&
                          friend['profileImage'].isNotEmpty
                      ? NetworkImage(friend['profileImage'])
                      : null,
                  child: friend['profileImage'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(friend['name'] ?? 'İsimsiz Kullanıcı'),
                subtitle: Text(friend['email'] ?? ''),
                onTap: () {
                  print("Arkadaş ID: ${friend['userid']}");
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(
        currentIndex: 2,
        userId: userId,
        userData: userData,
      ),
    );
  }
}
