import 'package:chat_app_flutter/CustomUI/OwnMessageCard.dart';
import 'package:chat_app_flutter/CustomUI/ReplyCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String lastname;

  ChatScreen({
    Key? key,
    required this.name,
    required this.phone,
    required this.lastname,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io("http://192.168.56.1:3001", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.onConnect((data) => print("connected"));
    print(socket.connected);
    socket.emit("/test", "hello world");
    socket.on("/test", (data) {
      setState(() {
        messages.add(data);
        buildMessageList(_messageController.text);
      });
    });
  }

  Widget buildMessageList(String newText) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final String messageType = message['type'] ?? '';

        if (message['id'] == widget.phone) {
          print("1");
          return OwnMessageCard(message['msg']);
        } else {
          print("2");
          return ReplyCard(message['msg']);
        }
      },
    );
  }

  void sendJsonToServer(String msg) async {
    final Map<String, dynamic> jsonData = {
      "phone": widget.phone,
      "name": widget.name + " " + widget.lastname,
      "msg": msg,
    };

    final String serverUrl = "http://192.168.56.1:3001/test";

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

        setState(() {
          messages.add(json.decode(response.body));
          buildMessageList(_messageController.text);
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
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
              child: buildMessageList(_messageController.text),
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
