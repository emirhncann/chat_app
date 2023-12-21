import 'package:chat_app_flutter/model/messageList.dart';
import 'package:chat_app_flutter/model/userList.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF285059),
        title: Center(
          child: Text(
            "Projenin Adı",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Center(
            child: MessageList(),
          ),
          Center(
            child: UserList(),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 60,
        backgroundColor: Color(0xF2F2F2),
        color: Color(0xFF285059),
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: [
          Icon(
            Icons.message_outlined,
            color: Colors.white,
          ),
          Icon(
            Icons.portrait_outlined,
            color: Colors.white,
          ),
        ],
        index: _selectedIndex,
      ),
    );
  }
}
