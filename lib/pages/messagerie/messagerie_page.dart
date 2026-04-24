import 'package:flutter/material.dart';

import '../../services/messaging_storage_service.dart';
import 'chat_page.dart';

class MessageriePage extends StatefulWidget {
  final String myEmail;
  final Color themeColor;
  final Map<String, String> contactNames; // email → nom affiché

  const MessageriePage({
    super.key,
    required this.myEmail,
    required this.themeColor,
    required this.contactNames,
  });

  @override
  State<MessageriePage> createState() => _MessageriePageState();
}

class _MessageriePageState extends State<MessageriePage> {
  List<Map<String, dynamic>> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _loading = true);
    final convs =
        await MessagingStorageService.getConversations(widget.myEmail);
    setState(() {
      _conversations = convs;
      _loading = false;
    });
  }

  String _displayName(String email) {
    return widget.contactNames[email] ?? email;
  }

  String _lastMessagePreview(Map<String, dynamic>? msg) {
    if (msg == null) return '';
    final type = msg['type'] as String? ?? 'text';
    switch (type) {
      case 'photo':
        return '📷 Photo';
      case 'video':
        return '🎬 Vidéo';
      case 'audio':
        return '🎵 Message vocal';
      default:
        final content = msg['content'] as String? ?? '';
        return content.length > 50
            ? '${content.substring(0, 50)}…'
            : content;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(d);
      if (diff.inMinutes < 1) return "maintenant";
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays == 1) return 'Hier';
      if (diff.inDays < 7) return '${diff.inDays}j';
      return '${d.day}/${d.month}';
    } catch (_) {
      return '';
    }
  }

  String _initials(String email) {
    final name = _displayName(email);
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messagerie',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: widget.themeColor,
            child: Row(
              children: [
                _tabLabel('Chats', true),
                _tabLabel('Appels', false),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 12),
                        Icon(Icons.search, color: Colors.grey, size: 18),
                        SizedBox(width: 8),
                        Text('Rechercher…',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.tune_outlined,
                    color: Colors.grey.shade600, size: 22),
              ],
            ),
          ),

          // Liste des conversations
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        color: widget.themeColor))
                : _conversations.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        color: widget.themeColor,
                        child: ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) =>
                              _buildConvTile(_conversations[index]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        onPressed: _loadConversations,
        tooltip: 'Actualiser',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _tabLabel(String label, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                active ? Colors.white : Colors.white.withAlpha(150),
            fontWeight:
                active ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildConvTile(Map<String, dynamic> conv) {
    final otherEmail = conv['otherEmail'] as String;
    final lastMsg = conv['lastMessage'] as Map<String, dynamic>?;
    final unread = (conv['unread'] as int?) ?? 0;
    final isFromMe = lastMsg?['from'] == widget.myEmail;

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPage(
              myEmail: widget.myEmail,
              otherEmail: otherEmail,
              otherName: _displayName(otherEmail),
              themeColor: widget.themeColor,
            ),
          ),
        );
        _loadConversations();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  widget.themeColor.withAlpha(40),
              child: Text(
                _initials(otherEmail),
                style: TextStyle(
                  color: widget.themeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Nom + dernier message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName(otherEmail),
                    style: TextStyle(
                      fontWeight: unread > 0
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isFromMe)
                        const Icon(Icons.done_all,
                            size: 14, color: Colors.blue),
                      if (isFromMe) const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          _lastMessagePreview(lastMsg),
                          style: TextStyle(
                            fontSize: 13,
                            color: unread > 0
                                ? Colors.black87
                                : Colors.grey,
                            fontWeight: unread > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontStyle:
                                lastMsg?['type'] == 'text'
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Heure + badge non-lus
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(lastMsg?['sentAt'] as String?),
                  style: TextStyle(
                    fontSize: 11,
                    color: unread > 0
                        ? widget.themeColor
                        : Colors.grey,
                    fontWeight: unread > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                if (unread > 0)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: widget.themeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline,
              size: 72, color: widget.themeColor.withAlpha(80)),
          const SizedBox(height: 16),
          const Text(
            'Aucune conversation',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vos échanges avec les grossistes\napparaîtront ici.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
