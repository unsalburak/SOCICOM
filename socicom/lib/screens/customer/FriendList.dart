import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socicom/BottomNavigatorBar.dart';

class FriendsList extends StatefulWidget {
  final String userId; // Kullanıcı ID'si
  final Map<String, dynamic>? userData; // Kullanıcı bilgileri

  const FriendsList({super.key, required this.userId, this.userData});

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final TextEditingController _usernameController = TextEditingController();

  Future<List<Map<String, dynamic>>> fetchFriends() async {
    // Aynı fetchFriends fonksiyonunuz devam ediyor.
    List<Map<String, dynamic>> friends = [];
    try {
      final String actualUserId = widget.userData?['userid'] ?? '';
      if (actualUserId.isEmpty) return [];

      QuerySnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('userid', isEqualTo: actualUserId)
          .get();

      if (profileSnapshot.docs.isEmpty) return [];

      DocumentSnapshot userProfile = profileSnapshot.docs.first;

      QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(userProfile.id)
          .collection('friends')
          .get();

      List<String> friendUserIds = friendsSnapshot.docs
          .map((doc) => doc['userid'] as String)
          .toList();

      QuerySnapshot profilesSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('userid', whereIn: friendUserIds)
          .get();

      for (var doc in profilesSnapshot.docs) {
        friends.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Hata: $e");
    }

    return friends;
  }

  Future<void> addFriend(String username) async {
    try {
      final userId = widget.userData?['userid'];
      if (userId == null || userId.isEmpty) return;

      // Kullanıcı adını `profiles` koleksiyonunda arayın
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('profiles')
          .where('username', isEqualTo: username)
          .get();

      if (userQuery.docs.isEmpty) {
        print("Kullanıcı bulunamadı.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kullanıcı bulunamadı!")),
        );
        return;
      }

      // İlk sonucu arkadaş olarak ekle
      DocumentSnapshot friendDoc = userQuery.docs.first;
      String friendUserId = friendDoc['userid'];

      // Arkadaş ekleme işlemi
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.userData?['docId']) // Kullanıcının belgesi
          .collection('friends')
          .doc(friendUserId)
          .set({
        'userid': friendUserId,
        'name': friendDoc['name'] ?? '',
        'email': friendDoc['email'] ?? '',
        'profileImage': friendDoc['profileImage'] ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Arkadaş eklendi!")),
      );
    } catch (e) {
      print("Arkadaş eklenirken hata oluştu: $e");
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
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
