import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> friendsInBusiness(String documentId) async {
  try {
    // Firestore referansı
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Belirtilen documentId ile profile dökümanını al
    DocumentSnapshot userDoc = await firestore.collection('profiles').doc(documentId).get();

    if (userDoc.exists) {
      // User'ın friends alt koleksiyonunu al
      CollectionReference friendsCollection =
          firestore.collection('profiles').doc(documentId).collection('friends');

      // Friends alt koleksiyonundaki tüm arkadaşları al
      QuerySnapshot friendsSnapshot = await friendsCollection.get();

      // Tüm friends userid'lerini al
      List<String> friendsIds = friendsSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['userid'].toString()) // Attribute ismi "userid" olarak değiştirildi
          .toList();

      if (friendsIds.isNotEmpty) {
        // Ekrana yazdır
        for (int i = 0; i < friendsIds.length; i++) {
          print('Friend ${i + 1}: ${friendsIds[i]}');
        }
      } else {
        print('No friends found for the given document ID.');
      }
    } else {
      print('No profile found with the given document ID.');
    }
  } catch (e) {
    print('Error fetching friends: $e');
  }
}
