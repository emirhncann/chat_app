import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_flutter/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('kullanicilar').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var userData = snapshot.data!.docs[index];
              return buildUserCard(context, userData);
            },
          );
        }
      },
    );
  }

  Widget buildUserCard(
      BuildContext context, QueryDocumentSnapshot<Object?> userData) {
    var username = userData['name'];
    var email = userData['email'];

    return Card(
      child: ListTile(
        title: Text(username),
        subtitle: Text(email),
        onTap: () {
          openChatScreen(context, userData);
        },
      ),
    );
  }

  void openChatScreen(
      BuildContext context, QueryDocumentSnapshot<Object?> userData) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      var currentUserEmail = user.email;
      var selectedUserEmail = userData['email'];

      bool chatExists =
          await checkIfChatExists(currentUserEmail!, selectedUserEmail);

      if (chatExists) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: "$currentUserEmail;$selectedUserEmail",
              selectedChatMessages: const [],
              timestamp: '',
              message: '',
              to: '',
              from: '',
              userEmail: selectedUserEmail,
            ),
          ),
        );
      } else {
        await createNewChat(currentUserEmail, selectedUserEmail);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: "$currentUserEmail;$selectedUserEmail",
              selectedChatMessages: const [],
              timestamp: '',
              message: '',
              to: '',
              from: '',
              userEmail: selectedUserEmail,
            ),
          ),
        );
      }
    } else {
      print("Kullanıcı oturum açmamış.");
    }
  }

  Future<bool> checkIfChatExists(String user1, String user2) async {
    var chatDocument = await FirebaseFirestore.instance
        .collection('chats')
        .doc('$user1;$user2')
        .get();
    return chatDocument.exists;
  }

  Future<void> createNewChat(String user1, String user2) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc('$user1;$user2')
        .set({
      'user1': user1,
      'user2': user2,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
