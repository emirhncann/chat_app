import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_flutter/chat_screen.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sohbetler')
          .where('from', isEqualTo: user!.email)
          .snapshots(),
      builder: (context, snapshotFrom) {
        if (!snapshotFrom.hasData) {
          return CircularProgressIndicator();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sohbetler')
              .where('to', isEqualTo: user!.email)
              .snapshots(),
          builder: (context, snapshotTo) {
            if (!snapshotTo.hasData) {
              return CircularProgressIndicator();
            }

            // Buraya kadar geldiysek, her iki sorgu da veri içeriyor demektir.
            // Şimdi iki sorgunun sonuçlarını birleştiriyoruz.
            List<QueryDocumentSnapshot> messagesFrom = snapshotFrom.data!.docs;
            List<QueryDocumentSnapshot> messagesTo = snapshotTo.data!.docs;
            List<QueryDocumentSnapshot> allMessages = [
              ...messagesFrom,
              ...messagesTo,
            ];

            return ListView.builder(
              itemCount: allMessages.length,
              itemBuilder: (context, index) {
                var message = allMessages[index];
                String otherUserEmail = message['to'] == user!.email
                    ? message['from']
                    : message['to'];

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('kullanicilar')
                      .where('email', isEqualTo: otherUserEmail)
                      .get()
                      .then((querySnapshot) => querySnapshot.docs.first),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    var otherUserData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    String otherUserName = otherUserData['name'];
                    String otherUserSurname = otherUserData['surname'];

                    return InkWell(
                      onTap: () async {
                        var currentUserEmail =
                            FirebaseAuth.instance.currentUser?.email;
                        var chatCollection =
                            FirebaseFirestore.instance.collection('sohbetler');

                        // Check if a chat already exists with these participants
                        var existingChat = await chatCollection
                            .where('from', isEqualTo: currentUserEmail)
                            .where('to', isEqualTo: otherUserEmail)
                            .get();

                        if (existingChat.docs.isEmpty) {
                          // Check the reverse scenario
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
                                userName: user.displayName ?? "",
                                userSurname: "",
                                userEmail: otherUserEmail,
                                otherUserEmail: currentUserEmail ?? "",
                                otherUserName: otherUserName,
                                otherUserSurname: otherUserSurname,
                              ),
                            ),
                          );
                        } else {
                          // If no existing chat, create a new one
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
                                userName: user.displayName ?? "",
                                userSurname: "",
                                userEmail: currentUserEmail ?? "",
                                otherUserEmail: otherUserEmail,
                                otherUserName: otherUserName,
                                otherUserSurname: otherUserSurname,
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        child: ListTile(
                          title: Text(otherUserEmail),
                          // Add more UI components as needed
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
