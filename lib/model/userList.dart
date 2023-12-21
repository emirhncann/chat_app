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
                  var currentUserEmail =
                      FirebaseAuth.instance.currentUser?.email;
                  var chatCollection =
                      FirebaseFirestore.instance.collection('sohbetler');

                  var existingChat = await chatCollection
                      .where('from', isEqualTo: currentUserEmail)
                      .where('to', isEqualTo: otherUserEmail)
                      .get();

                  if (existingChat.docs.isEmpty) {
                    existingChat = await chatCollection
                        .where('from', isEqualTo: otherUserEmail)
                        .where('to', isEqualTo: currentUserEmail)
                        .get();
                  }

                  if (existingChat.docs.isNotEmpty) {
                    var chatDocumentId = existingChat.docs.first.id;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatDocumentId: chatDocumentId,
                          userName: userName,
                          userSurname: userSurname,
                          userEmail: userEmail,
                          otherUserEmail: '',
                          otherUserName: "",
                          otherUserSurname: "",
                        ),
                      ),
                    );
                  } else {
                    var newChatDocument = await chatCollection.add({
                      'from': currentUserEmail,
                      'to': otherUserEmail,
                      'tarih': Timestamp.now(),
                    });

                    var chatDocumentId = newChatDocument.id;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatDocumentId: chatDocumentId,
                          userName: userName,
                          userSurname: userSurname,
                          userEmail: userEmail,
                          otherUserEmail: '',
                          otherUserName: "",
                          otherUserSurname: "",
                        ),
                      ),
                    );
                  }
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
                              '$userEmail',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            /*  Text(
                            isOnline ? 'Online' : 'Çevrimdışı',
                              style: TextStyle(
                                color: isOnline ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),*/
                          ],
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            //color: isOnline ? Colors.green : Colors.grey,
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
