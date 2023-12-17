import 'package:flutter/material.dart';

class ReplyCard extends StatelessWidget {
  final String message;

  ReplyCard(this.message);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: Color.fromARGB(255, 191, 228, 246),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 60, top: 5, bottom: 20),
                child: ListTile(
                  title: Text(
                    message,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      "20:58",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}