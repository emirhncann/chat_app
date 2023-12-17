import 'package:flutter/material.dart';

class OwnMessageCard extends StatelessWidget {
  final String message;
  final String? timestamp;

  OwnMessageCard(this.message, {required this.timestamp});

  @override
  Widget build(BuildContext context) {
    print("Own message: $message");
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 45,
        ),
        child: Card(
          color: const Color.fromARGB(255, 167, 238, 199),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  timestamp!,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
