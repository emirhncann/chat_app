import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app_flutter/chat_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 0.8), // Add top and bottom spacing
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF285059),
                                Color.fromARGB(255, 184, 221, 167)
                              ], // Set your gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.all(25), // Increased padding
                            color:
                                Colors.white, // Set background color to white
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          otherUserEmail,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        Text(
                                          "$otherUserName"
                                          " $otherUserSurname",
                                          style: GoogleFonts.heebo(
                                              color: Colors.black87,
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w400
                                              // Set additional text size to 25
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          )),
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
