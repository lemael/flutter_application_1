import 'storage_helper.dart';

class MessagingStorageService {
  static const String _key = 'messages.json';

  static Future<Map<String, dynamic>> _readAll() async {
    return StorageHelper.read(_key, defaultValue: {'conversations': {}});
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    await StorageHelper.write(_key, data);
  }

  /// Clé unique pour identifier une conversation entre deux utilisateurs
  static String _convKey(String emailA, String emailB) {
    final sorted = [emailA, emailB]..sort();
    return '${sorted[0]}__${sorted[1]}';
  }

  /// Retourne la liste des messages d'une conversation
  static Future<List<Map<String, dynamic>>> getMessages(
      String emailA, String emailB) async {
    final data = await _readAll();
    final convs = data['conversations'] as Map<String, dynamic>;
    final key = _convKey(emailA, emailB);
    if (!convs.containsKey(key)) return [];
    final conv = convs[key] as Map<String, dynamic>;
    return (conv['messages'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
  }

  /// Envoie un message (texte, photo, vidéo ou audio)
  static Future<void> sendMessage({
    required String fromEmail,
    required String toEmail,
    required String content,
    String type = 'text', // text | photo | video | audio
  }) async {
    final data = await _readAll();
    data.putIfAbsent('conversations', () => <String, dynamic>{});
    final convs = data['conversations'] as Map<String, dynamic>;
    final key = _convKey(fromEmail, toEmail);

    convs.putIfAbsent(key, () => {
          'participants': [fromEmail, toEmail],
          'messages': <dynamic>[],
        });

    final conv = convs[key] as Map<String, dynamic>;
    final messages = conv['messages'] as List<dynamic>;

    messages.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'from': fromEmail,
      'to': toEmail,
      'content': content,
      'type': type,
      'sentAt': DateTime.now().toIso8601String(),
      'read': false,
    });

    data['conversations'] = convs;
    await _writeAll(data);
  }

  /// Marque tous les messages d'une conversation comme lus pour un destinataire
  static Future<void> markAsRead(
      String myEmail, String otherEmail) async {
    final data = await _readAll();
    final convs = data['conversations'] as Map<String, dynamic>;
    final key = _convKey(myEmail, otherEmail);
    if (!convs.containsKey(key)) return;
    final conv = convs[key] as Map<String, dynamic>;
    final messages = (conv['messages'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    for (final m in messages) {
      if (m['to'] == myEmail) m['read'] = true;
    }
    conv['messages'] = messages;
    data['conversations'] = convs;
    await _writeAll(data);
  }

  /// Retourne la liste de toutes les conversations d'un utilisateur
  /// avec le dernier message et le nombre de non-lus
  static Future<List<Map<String, dynamic>>> getConversations(
      String myEmail) async {
    final data = await _readAll();
    final convs = data['conversations'] as Map<String, dynamic>;
    final result = <Map<String, dynamic>>[];

    convs.forEach((key, value) {
      final conv = value as Map<String, dynamic>;
      final participants =
          (conv['participants'] as List<dynamic>).cast<String>();
      if (!participants.contains(myEmail)) return;

      final otherEmail =
          participants.firstWhere((e) => e != myEmail, orElse: () => '');
      final messages = (conv['messages'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      final unread = messages
          .where((m) => m['to'] == myEmail && m['read'] == false)
          .length;

      final last = messages.isNotEmpty ? messages.last : null;

      result.add({
        'otherEmail': otherEmail,
        'lastMessage': last,
        'unread': unread,
      });
    });

    // Trier par date du dernier message (plus récent en premier)
    result.sort((a, b) {
      final la = a['lastMessage'] as Map<String, dynamic>?;
      final lb = b['lastMessage'] as Map<String, dynamic>?;
      final da = la != null
          ? DateTime.tryParse(la['sentAt'] as String? ?? '') ?? DateTime(2000)
          : DateTime(2000);
      final db = lb != null
          ? DateTime.tryParse(lb['sentAt'] as String? ?? '') ?? DateTime(2000)
          : DateTime(2000);
      return db.compareTo(da);
    });

    return result;
  }
}
