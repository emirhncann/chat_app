import 'package:chat_app_flutter/model/OwnMessageCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Message {
  final String content;
  final bool isOwnMessage;

  var userName;

  var userSurname;

  Message(this.content, this.isOwnMessage, this.userName, this.userSurname);
}

class ChatScreen extends StatefulWidget {
  final String chatDocumentId;

  const ChatScreen({Key? key, required this.chatDocumentId}) : super(key: key);

  State<ChatScreen> createState() => _ChatScreenState();
}

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
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return message.isOwnMessage
                    ? OwnMessageCard(
                        message.content,
                        timestamp: '',
                      )
                    : ListTile(
                        title: Text(message.content),
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
                      hintText: 'Mesajınızı yazın...',
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

  void sendMessage(String text) async {
    try {
      // Önce mesajı yerel olarak ekleyin
      messages.add(Message(text, true, text, text));

      // Mesajı sunucuya gönderme işlemi (HTTP veya socket kullanabilirsiniz)
      await sendToServer(text);

      // İşlem başarılıysa, UI'ı güncelleyin
      setState(() {});
    } catch (error) {
      // Hata durumunda kullanıcıya bilgi verilebilir
      print("Mesaj gönderme hatası: $error");
      // Eklenen mesajı geri çekme veya başka bir hata işlemi yapabilirsiniz.
    }
  }

  Future<void> sendToServer(String text) async {
    // Burada mesajı sunucuya veya veritabanına gönderme işlemlerini gerçekleştirin
    // Örneğin: HTTP veya socket kullanabilirsiniz

    // HTTP POST örneği:
    var url = Uri.parse('https://example.com/sendMessage');
    var response = await http.post(
      url,
      body: {'text': text},
    );

    if (response.statusCode == 200) {
      // Mesaj başarıyla gönderildi
      print('Mesaj başarıyla gönderildi');
    } else {
      // Mesaj gönderme hatası
      throw Exception('Mesaj gönderme hatası: ${response.reasonPhrase}');
    }
  }
}
