import 'package:chat_app_flutter/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('kullanicilar').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var currentUser = FirebaseAuth.instance.currentUser;
        var myEmail = currentUser?.email;

        List<Widget> userList = [];

        for (var user in snapshot.data!.docs) {
          var userData = user.data() as Map<String, dynamic>;
          var userName = userData['name'];
          var userSurname = userData['surname'];
          var userEmail = userData['email'];
          var isOnline = userData['isOnline'] ?? true;

          if (myEmail != null && userEmail != null && myEmail != userEmail) {
            userList.add(
              InkWell(
                onTap: () async {
                  var otherUserEmail = userEmail;
                  var chatDocumentId = '$myEmail;$otherUserEmail';

                  var chatDocument = FirebaseFirestore.instance
                      .collection('sohbetler')
                      .doc(chatDocumentId);

                  if (!(await chatDocument.get()).exists) {
                    await chatDocument.set({
                      'participants': [myEmail, otherUserEmail],
                      'created_at': FieldValue.serverTimestamp(),
                      "userName": userName,
                      "userSurname": userSurname,
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatDocumentId: chatDocumentId,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$userName $userSurname',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              isOnline ? 'Online' : 'Çevrimdışı',
                              style: TextStyle(
                                color: isOnline ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Kullanıcılar'),
          ),
          body: ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              return userList[index];
            },
          ),
        );
      },
    );
  }
}
