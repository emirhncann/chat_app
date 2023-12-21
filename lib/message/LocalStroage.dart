
import 'dart:convert';
import 'dart:io';

class LocalStorage {
  static Future<void> saveMessage(String chatDocumentId, String message, String from, String to) async {
    final messagesPath = 'message/$chatDocumentId.json';

    File file = File(messagesPath);
    List<dynamic> messages = [];

    if (file.existsSync()) {
      String content = await file.readAsString();
      messages = json.decode(content);
    }

    messages.add({
      'msg': message,
      'from': from,
      'to': to,
      'tarih': DateTime.now().toIso8601String(),
    });

    await file.writeAsString(json.encode(messages));
  }

  static Future<List<Map<String, dynamic>>> loadMessages(String chatDocumentId) async {
    final messagesPath = 'messages/$chatDocumentId.json';

    File file = File(messagesPath);

    if (!file.existsSync()) {
      return [];
    }

    String content = await file.readAsString();
    return json.decode(content).cast<Map<String, dynamic>>();
  }
}
