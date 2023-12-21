// UserList.dart
import 'package:chat_app_flutter/chat_screen.dart';
import 'package:chat_app_flutter/message/LocalStroage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchUserEmails(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var currentUser = FirebaseAuth.instance.currentUser;
        var myEmail = currentUser?.email;

        List<Widget> userList = [];

        for (var userEmail in snapshot.data!) {
          if (myEmail != null && userEmail != myEmail) {
            userList.add(
              InkWell(
                onTap: () async {
                  var otherUserEmail = userEmail;
                  var currentUserEmail =
                      FirebaseAuth.instance.currentUser?.email;

                  var chatDocumentId =
                      '$currentUserEmail;$otherUserEmail'; // Custom ID

                  // Navigate to the chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatDocumentId: chatDocumentId,
                        userName: '', // No user name available here
                        userSurname: '',
                        userEmail: otherUserEmail, otherUserEmail: '',
                      ),
                    ),
                  );

                  // Add a message to the 'messages' folder
                  await _addInitialMessage(
                      currentUserEmail!, otherUserEmail, chatDocumentId);
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
                          ],
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
            title: Text('Users'),
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

  Future<List<String>> _fetchUserEmails() async {
    var usersSnapshot =
        await FirebaseFirestore.instance.collection('kullanicilar').get();

    return usersSnapshot.docs
        .map((userDoc) => userDoc['email'] as String)
        .toList();
  }

  Future<void> _addInitialMessage(String currentUserEmail,
      String otherUserEmail, String chatDocumentId) async {
    await LocalStorage.saveMessage(
        chatDocumentId, 'Hello!', currentUserEmail, otherUserEmail);
  }
}
