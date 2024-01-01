import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessageList extends StatelessWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Step 1: Read the JSON file
    final directory = Directory.current;
    final file = File('${directory.path}/messages.json');
    final jsonString = file.readAsStringSync();
    final jsonData = json.decode(jsonString);

    // Step 2: Extract messages from JSON data
    List<Map<String, dynamic>> chatMessages =
        List<Map<String, dynamic>>.from(jsonData);

    // Step 3: Display messages in your Flutter app
    return ListView.builder(
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        String from = chatMessages[index]['message']['from'];
        String to = chatMessages[index]['message']['to'];
        String message = chatMessages[index]['message']['msg'];
        String timestamp = chatMessages[index]['message']['tarih'];

        return ListTile(
          title: Text(
            'From: $from\nTo: $to\nMessage: $message\nTimestamp: $timestamp',
          ),
        );
      },
    );
  }
}
