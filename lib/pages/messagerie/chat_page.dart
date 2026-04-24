import 'package:flutter/material.dart';

import '../../services/messaging_storage_service.dart';

class ChatPage extends StatefulWidget {
  final String myEmail;
  final String otherEmail;
  final String otherName;
  final Color themeColor;

  const ChatPage({
    super.key,
    required this.myEmail,
    required this.otherEmail,
    required this.otherName,
    required this.themeColor,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    await MessagingStorageService.markAsRead(
        widget.myEmail, widget.otherEmail);
    final msgs = await MessagingStorageService.getMessages(
        widget.myEmail, widget.otherEmail);
    setState(() {
      _messages = msgs;
      _loading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendText() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _textController.clear();
    await MessagingStorageService.sendMessage(
      fromEmail: widget.myEmail,
      toEmail: widget.otherEmail,
      content: text,
      type: 'text',
    );
    await _loadMessages();
    setState(() => _sending = false);
  }

  Future<void> _sendAttachment(String type) async {
    setState(() => _sending = true);
    String content;
    switch (type) {
      case 'photo':
        content = '📷 Photo';
        break;
      case 'video':
        content = '🎬 Vidéo';
        break;
      case 'audio':
        content = '🎵 Message vocal';
        break;
      default:
        content = '📎 Fichier';
    }
    await MessagingStorageService.sendMessage(
      fromEmail: widget.myEmail,
      toEmail: widget.otherEmail,
      content: content,
      type: type,
    );
    await _loadMessages();
    setState(() => _sending = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$content envoyé(e)'),
          backgroundColor: widget.themeColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Photo',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      _sendAttachment('photo');
                    }),
                _attachOption(
                    icon: Icons.videocam_outlined,
                    label: 'Vidéo',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _sendAttachment('video');
                    }),
                _attachOption(
                    icon: Icons.mic_outlined,
                    label: 'Audio',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      _sendAttachment('audio');
                    }),
                _attachOption(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'Fichier',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      _sendAttachment('file');
                    }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _attachOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  bool _isSameDay(String? isoA, String? isoB) {
    if (isoA == null || isoB == null) return false;
    try {
      final a = DateTime.parse(isoA);
      final b = DateTime.parse(isoB);
      return a.year == b.year && a.month == b.month && a.day == b.day;
    } catch (_) {
      return false;
    }
  }

  String _dayLabel(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso);
      final now = DateTime.now();
      if (d.year == now.year &&
          d.month == now.month &&
          d.day == now.day) return "Aujourd'hui";
      final yesterday = now.subtract(const Duration(days: 1));
      if (d.year == yesterday.year &&
          d.month == yesterday.month &&
          d.day == yesterday.day) return 'Hier';
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withAlpha(60),
              child: Text(
                _initials(widget.otherName),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF44FF44),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('En ligne',
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone des messages
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        color: widget.themeColor))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 56,
                                color:
                                    widget.themeColor.withAlpha(80)),
                            const SizedBox(height: 12),
                            Text(
                              'Démarrez la conversation\navec ${widget.otherName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final prev = index > 0
                              ? _messages[index - 1]
                              : null;
                          final showDay = prev == null ||
                              !_isSameDay(
                                  prev['sentAt'] as String?,
                                  msg['sentAt'] as String?);
                          return Column(
                            children: [
                              if (showDay)
                                _buildDayDivider(
                                    msg['sentAt'] as String?),
                              _buildMessageBubble(msg),
                            ],
                          );
                        },
                      ),
          ),

          // Barre de saisie
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  // Bouton attachement
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _showAttachmentMenu,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.themeColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Champ de texte
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                hintText: 'Écrire ici…',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10),
                              ),
                              maxLines: 4,
                              minLines: 1,
                              textCapitalization:
                                  TextCapitalization.sentences,
                              onSubmitted: (_) => _sendText(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.mic_outlined,
                                color: Colors.grey.shade500),
                            onPressed: () =>
                                _sendAttachment('audio'),
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Bouton envoyer
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: _sendText,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.themeColor,
                          shape: BoxShape.circle,
                        ),
                        child: _sending
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.send,
                                color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDivider(String? iso) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          const SizedBox(width: 10),
          Text(
            _dayLabel(iso),
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['from'] == widget.myEmail;
    final type = msg['type'] as String? ?? 'text';
    final content = msg['content'] as String? ?? '';
    final time = _formatTime(msg['sentAt'] as String?);

    Widget messageContent;

    switch (type) {
      case 'photo':
        messageContent = Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 110,
              decoration: BoxDecoration(
                color: isMe
                    ? widget.themeColor.withAlpha(40)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_outlined,
                      size: 40,
                      color: isMe
                          ? widget.themeColor
                          : Colors.grey.shade500),
                  const SizedBox(height: 6),
                  Text('Photo',
                      style: TextStyle(
                          color: isMe
                              ? widget.themeColor
                              : Colors.grey.shade600,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        );
        break;

      case 'video':
        messageContent = Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 110,
              decoration: BoxDecoration(
                color: isMe
                    ? widget.themeColor.withAlpha(40)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_circle_outline,
                      size: 44,
                      color: isMe
                          ? widget.themeColor
                          : Colors.grey.shade500),
                  const SizedBox(height: 4),
                  Text('Vidéo',
                      style: TextStyle(
                          color: isMe
                              ? widget.themeColor
                              : Colors.grey.shade600,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        );
        break;

      case 'audio':
        messageContent = Container(
          width: 180,
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isMe ? widget.themeColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.play_arrow,
                  color: isMe ? Colors.white : Colors.grey.shade700,
                  size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white.withAlpha(180)
                            : Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text('0:08',
                  style: TextStyle(
                      color:
                          isMe ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 11)),
            ],
          ),
        );
        break;

      default:
        messageContent = Text(
          content,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 13,
              backgroundColor:
                  widget.themeColor.withAlpha(40),
              child: Text(
                _initials(widget.otherName),
                style: TextStyle(
                    color: widget.themeColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (type == 'text')
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        MediaQuery.of(context).size.width * 0.65,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? widget.themeColor
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft:
                          Radius.circular(isMe ? 18 : 4),
                      bottomRight:
                          Radius.circular(isMe ? 4 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: messageContent,
                )
              else
                messageContent,
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.grey),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 3),
                    Icon(Icons.done_all,
                        size: 13,
                        color: msg['read'] == true
                            ? Colors.blue
                            : Colors.grey),
                  ],
                ],
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
