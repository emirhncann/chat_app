import 'package:chat_app_flutter/CustomUI/OwnMessageCard.dart';
import 'package:chat_app_flutter/CustomUI/ReplyCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String name;
  const ChatScreen(
      {super.key,
      required this.name,
      required String phone,
      required String lastname});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

TextEditingController _messageController = TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  FocusNode focusNode = FocusNode();
  bool show = false;
  @override
  void initState() {
    super.initState();
    connect();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  void connect() {
    socket = IO.io("http://192.168.56.1:7162", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.onConnect((data) => print("connected"));
    print(socket.connected);
    socket.emit("/test", "hello world");
    final Map<String, dynamic> jsonData = {
      "type": "ownMsg",
      "name": "Emir",
      "msg": "Hello, server!",
      "senderName": "emiiir",
    };
  }

  void sendJsonToServer(String msg) async {
    final Map<String, dynamic> jsonData = {
      "type": "ownMsg",
      "name": "John Doe",
      "msg": msg,
      "senderName": "John",
    };

    final String serverUrl =
        "http://192.168.56.1:7162/test"; // Sunucu URL'sini buraya ekleyin

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200) {
        print("Server Response: ${response.body}");
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void sendMsg(String msg, String senderName) {
    socket!.emit("/test", {
      "type": "ownMsg",
      "name": widget.name,
      "msg": _messageController.text,
      "senderName": senderName,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.blueGrey,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 140,
              child: ListView(
                children: [
                  OwnMessageCard(),
                  ReplyCard(),
                  OwnMessageCard(),
                  ReplyCard(),
                  OwnMessageCard(),
                  ReplyCard(),
                  OwnMessageCard(),
                  ReplyCard(),
                  ReplyCard(),
                  OwnMessageCard(),
                  ReplyCard(),
                  OwnMessageCard(),
                  ReplyCard(),
                  OwnMessageCard(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      margin:
                          const EdgeInsets.only(left: 2, right: 2, bottom: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: TextFormField(
                          controller: _messageController,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          decoration: const InputDecoration(
                            hintText: "Mesaj yaz",
                            contentPadding: EdgeInsets.all(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        sendJsonToServer(_messageController.text);
                        _messageController.clear();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
