/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_flutter/CustomUI/chat.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcı Listesi'),
      ),
      body: FutureBuilder(
        future: getUsersFromFirestore(), // Firestore'dan kullanıcıları çek
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Hata: ${snapshot.error}');
          } else {
            List<DocumentSnapshot> users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var userData = users[index].data() as Map<String, dynamic>;
                String username = userData['username']; // Kullanıcının adını Firestore'da hangi alan adıyla sakladığınıza göre güncelleyin.
                String userId = users[index].id;

                return ListTile(
                  title: Text(username),
                  onTap: () {
                    // Tıklanan kullanıcıya ait sohbet ekranına yönlendirme
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(userId: userId, chatId: '',),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> getUsersFromFirestore() async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance.collection('kullanicilar').get();
    return usersSnapshot.docs;
  }
}
*/