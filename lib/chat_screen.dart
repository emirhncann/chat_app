import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class OwnMessageCard extends StatelessWidget {
  final String message;

  OwnMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: const Color.fromARGB(255, 167, 238, 199),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReplyCard extends StatelessWidget {
  final String message;

  ReplyCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: Color.fromARGB(255, 191, 228, 246),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 60,
                  top: 5,
                  bottom: 20,
                ),
                child: ListTile(
                  title: Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Message {
  final String content;
  final bool isOwnMessage;
  final String userName;
  final String userSurname;

  Message(
    this.content,
    this.isOwnMessage,
    this.userName,
    this.userSurname,
  );
}

class ChatScreen extends StatefulWidget {
  final String chatDocumentId;
  final String userName;
  final String userSurname;
  final String userEmail;

  const ChatScreen({
    Key? key,
    required this.chatDocumentId,
    required this.userName,
    required this.userSurname,
    required this.userEmail,
    required String otherUserEmail,
    required otherUserName,
    required otherUserSurname,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

var currentUser = FirebaseAuth.instance.currentUser;
var myEmail = currentUser?.email;

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('sohbetler/${widget.chatDocumentId}/msg')
                  .orderBy('tarih')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                messages.clear();

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  var content = data['msg'] as String;
                  var from = data['from'] as String;
                  var to = data['to'] as String;
                  var isOwnMessage = to == widget.userEmail;
                  messages.add(Message(content, isOwnMessage, from, to));
                }
                print(widget.userEmail);
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return message.isOwnMessage
                        ? OwnMessageCard(message: message.content)
                        : ReplyCard(message: message.content);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextFormField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    sendMessage(_messageController.text);
                    _messageController.clear();
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    try {
      CollectionReference chatCollection =
          FirebaseFirestore.instance.collection('sohbetler');
      DocumentReference chatDocumentRef =
          chatCollection.doc(widget.chatDocumentId);
      CollectionReference messagesCollection =
          chatDocumentRef.collection('msg');

      DocumentReference newMessageRef = await messagesCollection.add({
        'from': myEmail,
        'to': widget.userEmail,
        'msg': text,
        'tarih': DateTime.now().toUtc().toString(),
      });

      print(
          'Mesaj başarıyla gönderildi Firestore koleksiyonuna. ID: ${newMessageRef.id}');

      // Gönderilen mesajı JSON dosyasına kaydet
      await saveMessageToJSON({
        'from': myEmail,
        'to': widget.userEmail,
        'msg': text,
        'tarih': DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      print("Mesaj gönderme hatası: $error");
    }
  }

  Future<void> saveMessageToJSON(Map<String, dynamic> message) async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File('${directory!.path}/messages.json');

      // JSON dosyasını oku
      List<dynamic> messages = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        messages = json.decode(contents);
      }

      // Yeni mesajı ekle
      messages.add(message);

      // JSON dosyasına yaz
      await file.writeAsString(json.encode(messages));
      print('Mesaj başarıyla JSON dosyasına kaydedildi.');
      print('Dosya yolu: ${directory!.path}/messages.json');
    } catch (error) {
      print('JSON dosyasına mesajı kaydetme hatası: $error');
    }
  }
}
