import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

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
  final String? chatDocumentId;
  final String? userName;
  final String? userSurname;
  final String? userEmail;

  const ChatScreen({
    Key? key,
    this.chatDocumentId,
    this.userName,
    this.userSurname,
    this.userEmail,
    required String from,
    required String to,
    required String message,
    required String timestamp,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];
  late String myEmail;

  @override
  void initState() {
    super.initState();
    myEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    // You may initialize the messages list if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return message.isOwnMessage
                    ? OwnMessageCard(message: message.content)
                    : ReplyCard(message: message.content);
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
      await saveMessageToJSON({
        'chatid': widget.userEmail! + ";" + myEmail,
        'message': {
          'from': myEmail,
          'to': widget.userEmail,
          'msg': text,
          'tarih': DateTime.now().toUtc().toString(),
        },
      });

      setState(() {
        messages.add(Message(
            text, true, widget.userName ?? '', widget.userSurname ?? ''));
      });

      print('Mesaj başarıyla JSON dosyasına kaydedildi.');
    } catch (error) {
      print("Mesaj gönderme hatası: $error");
    }
  }

  Future<void> saveMessageToJSON(Map<String, dynamic> message) async {
    try {
      final directory = await getExternalStorageDirectory();
      final file = File(
          "/storage/emulated/0/Android/data/com.example.chat_app_flutter/files/messages.json");

      List<dynamic> messagesList = [];
      if (await file.exists()) {
        final contents = await file.readAsString();
        messagesList = json.decode(contents);
      }

      messagesList.add(message);

      await file.writeAsString(json.encode(messagesList));
      print('Mesaj başarıyla JSON dosyasına kaydedildi.');
      print(
          "/storage/emulated/0/Android/data/com.example.chat_app_flutter/files/messages.json");
    } catch (error) {
      print('JSON dosyasına mesajı kaydetme hatası: $error');
    }
  }
}
