import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/utils/BottomNavigatorBar.dart';

class FriendsList extends StatefulWidget {
  final String userId; // Kullanıcı ID'si
  final Map<String, dynamic>? userData; // Kullanıcı bilgileri

  const FriendsList({super.key, required this.userId, this.userData});

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final TextEditingController _usernameController = TextEditingController();

  // Gerçek zamanlı arkadaş verilerini almak için stream oluşturuyoruz
  Stream<List<Map<String, dynamic>>> fetchFriendsStream() {
  final String actualUserId = widget.userData?['userid'] ?? '';

  if (actualUserId.isEmpty) {
    return Stream.value([]); // Eğer kullanıcı ID'si yoksa boş bir liste döndür
  }

  return FirebaseFirestore.instance
      .collection('profiles')
      .where('userid', isEqualTo: actualUserId)
      .snapshots()
      .asyncMap((profileSnapshot) async {
    if (profileSnapshot.docs.isEmpty) {
      return []; // Eğer kullanıcı bulunamazsa boş bir liste döndür
    }

    String userProfileId = profileSnapshot.docs.first.id;

    // Kullanıcının friends alt koleksiyonunu oku
    QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .doc(userProfileId)
        .collection('friends')
        .get();

    List<String> friendUserIds = friendsSnapshot.docs
        .map((doc) => doc['userid'] as String)
        .toList();

    if (friendUserIds.isEmpty) {
      return []; // Eğer arkadaş yoksa boş bir liste döndür
    }

    // Arkadaşların bilgilerini getir
    QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance
        .collection('profiles')
        .where('userid', whereIn: friendUserIds)
        .get();

    return profilesSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  });
}


  Future<void> addFriend(String username) async {
    try {
      // 1. TextField'e girilen username'i arama
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('profiles')
          .where('username', isEqualTo: username)
          .get();

      if (userQuery.docs.isEmpty) {
        print("Kullanıcı bulunamadı: username=$username");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı bulunamadı!")),
        );
        return;
      }

      // Arkadaş olarak eklenmek istenen kullanıcının bilgilerini al
      DocumentSnapshot friendDoc = userQuery.docs.first;
      String friendUserId = friendDoc['userid'];
      print("Bulunan arkadaşın userid'si: $friendUserId");

      // 2. Giriş yapmış kullanıcının userid'sini `userData`dan al
      final String? currentUserId = widget.userData?['userid'];
      if (currentUserId == null || currentUserId.isEmpty) {
        print("Giriş yapmış kullanıcı bilgisi eksik.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı bilgileri eksik!")),
        );
        return;
      }
      print("Giriş yapmış kullanıcının userid'si: $currentUserId");

      // 3. Giriş yapmış kullanıcının random document id'sini bul
      QuerySnapshot profileQuery = await FirebaseFirestore.instance
          .collection('profiles')
          .where('userid', isEqualTo: currentUserId)
          .get();

      if (profileQuery.docs.isEmpty) {
        print("Giriş yapmış kullanıcı profili bulunamadı: userid=$currentUserId");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı profili bulunamadı!")),
        );
        return;
      }

      // Giriş yapmış kullanıcının random document id'si
      String currentUserDocId = profileQuery.docs.first.id;
      print("Giriş yapmış kullanıcının document id'si: $currentUserDocId");

      // 4. Giriş yapmış kullanıcının friends alt koleksiyonuna yeni bir belge oluştur
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(currentUserDocId) // Giriş yapmış kullanıcının document ID'si
          .collection('friends')
          .add({
        'userid': friendUserId, // Eklenen arkadaşın userid'si
      });

      print("Arkadaş başarıyla eklendi.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Arkadaş başarıyla eklendi!")),
      );
    } catch (e, stackTrace) {
      // Hata durumunda detaylı loglama
      print("Arkadaş eklenirken hata oluştu: $e");
      print("StackTrace: $stackTrace");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arkadaşlar")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Arkadaş Kullanıcı Adı",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    final username = _usernameController.text.trim();
                    if (username.isNotEmpty) {
                      addFriend(username);
                      _usernameController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: fetchFriendsStream(),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigator(
        currentIndex: 2,
        userId: widget.userId,
        userData: widget.userData,
      ),
    );
  }
}
