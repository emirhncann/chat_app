import 'package:chat_app_flutter/model/userList.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app_flutter/model/messageList.dart';

class home extends StatelessWidget {
  const home({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.message_outlined), text: 'Mesajlar'),
                Tab(
                  icon: Icon(Icons.supervised_user_circle_outlined),
                  text: 'Kullanıcılar',
                ),
              ],
            ),
            title: const Text('TEST'),
          ),
          body: TabBarView(
            children: [
              MessageList(),
              UserList(),
            ],
          ),
        ),
      ),
    );
  }
}
