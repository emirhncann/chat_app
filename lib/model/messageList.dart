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

  
    final directory = Directory.current;
    final filePath =
        "/storage/emulated/0/Android/data/com.example.chat_app_flutter/files/messages.json";

    try {
      final file = File(filePath);
      final jsonString = file.readAsStringSync();
      final jsonData = json.decode(jsonString);

      List<Map<String, dynamic>> chatMessages =
          List<Map<String, dynamic>>.from(jsonData);

      Set<String> uniqueChatIds = Set<String>();

      return ListView.builder(
        itemCount: chatMessages.length,
        itemBuilder: (context, index) {
          int reversedIndex = chatMessages.length - 1 - index;
          String chatid = chatMessages[reversedIndex]['chatid'];
          String from = chatMessages[reversedIndex]['message']['from'];
          String? to = chatMessages[reversedIndex]['message']['to'];
          String message = chatMessages[reversedIndex]['message']['msg'];
          String timestamp = chatMessages[reversedIndex]['message']['tarih'];

        
          to = to ?? "Sohbet Bulunamadı";

         
          if (uniqueChatIds.contains(chatid)) {
            return Container(); 
          }

         
          uniqueChatIds.add(chatid);

          return GestureDetector(
            onTap: () {
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                   
                    from: from!,
                    to: to!,
                    message: message!,
                    timestamp: timestamp!,
                    selectedChatMessages: chatMessages
                        .where((msg) => msg['chatid'] == chatid)
                        .toList(),
                    chatId: '',
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
      // sohbet yoksa
      return Center(
        child: Text("Hemen Sohbet Etmeye Başla."),
      );
    }
  }
}
