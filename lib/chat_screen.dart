import 'package:chat_app_flutter/CustomUI/OwnMessageCard.dart';
import 'package:chat_app_flutter/CustomUI/ReplyCard.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  IO.Socket socket;

  void connect() {
    socket = IO.io(uri);
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
                      onPressed: () {},
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
