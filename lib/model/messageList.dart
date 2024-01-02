import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app_flutter/chat_screen.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Step 1: Read the JSON file
    final directory = Directory.current;
    final filePath =
        "/storage/emulated/0/Android/data/com.example.chat_app_flutter/files/messages.json";
    try {
      final file = File(filePath);
      final jsonString = file.readAsStringSync();
      final jsonData = json.decode(jsonString);

      // Step 2: Extract messages from JSON data
      List<Map<String, dynamic>> chatMessages =
          List<Map<String, dynamic>>.from(jsonData);

      // Step 3: Display messages in your Flutter app
      return ListView.builder(
        itemCount: chatMessages.length,
        itemBuilder: (context, index) {
          String chatid = chatMessages[index]['message']['from'];
          String from = chatMessages[index]['message']['from'];
          String? to = chatMessages[index]['message']['to'];
          String message = chatMessages[index]['message']['msg'];
          String timestamp = chatMessages[index]['message']['tarih'];

          // Extract email addresses
          to = to ?? "Sohbet Bulunamadı";

          return GestureDetector(
            onTap: () {
              // Handle tap, open ChatScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    // Pass necessary data to ChatScreen if needed
                    from: from!,
                    to: to!,
                    message: message!,
                    timestamp: timestamp!,
                  ),
                ),
              );
            },
            child: Card(
              child: ListTile(
                title: Text(
                  to,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Handle file reading error
      return Center(
        child: Text("Hemen Sohbet Etmeye Başla."),
      );
    }
  }
}
