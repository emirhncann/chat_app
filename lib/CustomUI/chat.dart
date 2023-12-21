import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  TextEditingController _controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  _loadMessages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/lib/message/messages.json';
      final file = File(filePath);
      if (file.existsSync()) {
        String content = await file.readAsString();
        setState(() {
          messages = List<String>.from(json.decode(content));
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  _saveMessage(String message) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/lib/message/messages.json';
      final file = File(filePath);
      messages.add(message);
      await file.writeAsString(json.encode(messages));
    } catch (e) {
      print("Error saving message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesajlar'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı girin',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _controller.text.trim();
                    if (message.isNotEmpty) {
                      _saveMessage(message);
                      _controller.clear();
                      setState(() {
                        messages.add(message);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
