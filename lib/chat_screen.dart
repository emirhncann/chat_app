import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/lib/message/LocalStroage.dart';

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
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    var loadedMessages = await LocalStorage.loadMessages(widget.chatDocumentId);

    setState(() {
      messages = loadedMessages.map((msg) {
        return Message(
          msg['msg'],
          msg['from'] == widget.userEmail,
          msg['from'],
          msg['to'],
          DateTime.parse(msg['tarih']),
        );
      }).toList();
    });
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
                    ? OwnMessageCard(
                        message: message.content,
                        timestamp: message.timestamp.toString(),
                      )
                    : ReplyCard(
                        message: message.content,
                        timestamp: message.timestamp.toString(),
                      );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_messageController.text);
                    _messageController.clear();
                  },
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
      await LocalStorage.saveMessage(
        widget.chatDocumentId,
        text,
        FirebaseAuth.instance.currentUser?.email ?? '',
        widget.userEmail,
      );

      setState(() {
        messages.add(Message(
          text,
          true,
          FirebaseAuth.instance.currentUser?.email ?? '',
          widget.userEmail,
          DateTime.now(),
        ));
      });
    } catch (error) {
      print("Error sending message: $error");
    }
  }
}

class OwnMessageCard extends StatelessWidget {
  final String message;
  final String timestamp;

  OwnMessageCard({required this.message, required this.timestamp});

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
                const SizedBox(height: 5),
                Text(
                  timestamp,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
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
  final String timestamp;

  ReplyCard({
    required this.message,
    required this.timestamp,
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
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      timestamp,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
