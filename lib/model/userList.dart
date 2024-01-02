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

      // Check if a chat already exists between the current user and the selected user
      bool chatExists = checkIfChatExists(currentUserEmail!, selectedUserEmail);

      if (chatExists) {
        // Open existing chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(chatId: "$currentUserEmail;$selectedUserEmail", selectedChatMessages: const [], timestamp: '.', message: '', to: '', from: '',),
          ),
        );
      } else {
        // Create a new chat and open it
        createNewChat(currentUserEmail, selectedUserEmail);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatScreen(chatId: "$currentUserEmail;$selectedUserEmail", selectedChatMessages: const [], timestamp: '', message: '', to: '', from: '',),
          ),
        );
      }
    } else {
      print("Kullanıcı oturum açmamış.");
    }
  }

  bool checkIfChatExists(String user1, String user2) {
    // Implement logic to check if a chat already exists
    // You can use Firestore or any other storage mechanism to store chat information
    // Return true if a chat exists, false otherwise
    // Example: You can check a collection of chats in Firestore
    // and see if a document with the given users' emails already exists
    return false; // Replace with your actual logic
  }

  void createNewChat(String user1, String user2) {
    // Implement logic to create a new chat
    // You can use Firestore or any other storage mechanism to store chat information
    // Example: You can add a new document to a collection of chats in Firestore
    // with information about the users involved in the chat
    // and other necessary details
    // This is just a placeholder function, replace it with your actual logic
  }
}
