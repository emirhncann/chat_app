import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:uuid/uuid.dart';

// Message class to represent chat messages
class Message {
  final String content;
  final bool isOwnMessage;

  Message(this.content, this.isOwnMessage);
}

// Custom widget for own messages
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

// Custom widget for other user's messages
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

// ChatScreen widget
class ChatScreen extends StatefulWidget {
  final String? chatDocumentId;
  final String? userName;
  final String? userSurname;
  final String? userEmail;
  final List<Map<String, dynamic>> selectedChatMessages;

  const ChatScreen({
    Key? key,
    this.chatDocumentId,
    this.userName,
    this.userSurname,
    this.userEmail,
    required this.selectedChatMessages,
    required String timestamp,
    required String message,
    required String to,
    required String from, required String chatId,
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
    initializeMessages();
  }

  void initializeMessages() {
    setState(() {
      // Convert selectedChatMessages to Message objects
      messages = widget.selectedChatMessages.map((chatMessage) {
        return Message(
          chatMessage['message']['msg'],
          chatMessage['message']['from'] == myEmail,
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
                        hintText: 'Type your message...',
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
      // Construct a message map
      Map<String, dynamic> message = {
        'chatid': widget.userEmail! + ";" + myEmail,
        'message': {
          'from': myEmail,
          'to': widget.userEmail,
          'msg': text,
          'tarih': DateTime.now().toUtc().toString(),
        },
      };

      // Save the message to JSON file
      await saveMessageToJSON(message);

      // Update the state to reflect the new message
      setState(() {
        messages.add(Message(
          text,
          true,
        ));
      });

      print('Message successfully saved to JSON file.');
    } catch (error) {
      print("Error sending message: $error");
    }
  }

  Future<void> saveMessageToJSON(Map<String, dynamic> message) async {
    try {
      // Specify the file path
      final filePath = File(
          "/storage/emulated/0/Android/data/com.example.chat_app_flutter/files/messages.json");

      // Read the existing messages from the file
      List<dynamic> messagesList = [];
      if (await filePath.exists()) {
        final contents = await filePath.readAsString();
        messagesList = json.decode(contents);
      }

      // Add the new message to the list
      messagesList.add(message);

      // Write the updated messages list back to the file
      await filePath.writeAsString(json.encode(messagesList));

      print('Message successfully saved to JSON file.');
      print(filePath.path);
    } catch (error) {
      print('Error saving message to JSON file: $error');
    }
  }
}
