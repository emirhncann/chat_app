import 'package:chat_app_flutter/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key});

  @override
  Widget build(BuildContext context) {
    // Kullanıcı bilgisini almak için FirebaseAuth kullanıyoruz
    User? user = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('sohbetler').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Veri alınırken yükleniyor göstergesi
        }

        if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}');
        }

        // Varsayılan olarak mesajlarınızın Firestore koleksiyonunun içinde "from", "to", "userName" ve "userSurname" adında alanları olduğunu varsayalım
        final messages = snapshot.data?.docs ?? [];

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            // Her bir mesaj belgesinden "from", "to", "userName" ve "userSurname" alanlarını alıyoruz
            final messageData = messages[index].data() as Map<String, dynamic>;

            // Mesajı gönderen veya alıcısı olduğunuz mesajları filtreleyin
            if (user != null) {
              var from = messageData['from'];
              var to = messageData['to'];

              // Eğer "from" veya "to" alanlarından biri kullanıcının email'ini içeriyorsa mesajı göster
              if (from == user.email || to == user.email) {
                final userName = messageData['userName'];
                final userSurname = messageData['userSurname'];

                return Card(
                  child: ListTile(
                    title: Text('$userName $userSurname'),
                    // Gerektiğinde daha fazla UI öğesi ekleyebilirsiniz
                    onTap: () {
                      // Navigate to the chat screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            // Pass the necessary data to the ChatScreen
                            // Adjust these parameters based on your ChatScreen requirements
                            userName: userName,
                            userSurname: userSurname,
                            chatDocumentId: '',
                            userEmail: '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }

            // Eğer kullanıcının email'i "from" veya "to" alanlarında değilse mesajı gösterme
            return Container(); // Boş bir Container döndürebilirsiniz, veya null döndürebilirsiniz.
          },
        );
      },
    );
  }
}
