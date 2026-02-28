import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final String? hotelId;
  final String? bookingId;
  final String type;
  final String title;

  const ChatScreen({
    Key? key,
    this.hotelId,
    this.bookingId,
    this.type = 'hotel',
    this.title = 'Chat',
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  ChatConversation? _conversation;
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    
    final user = _authService.currentUser;
    if (user != null) {
      final conversation = await _chatService.getOrCreateConversation(
        userId: user['id']?.toString() ?? user['uid']?.toString() ?? '',
        hotelId: widget.hotelId,
        bookingId: widget.bookingId,
        type: widget.type,
      );
      
      if (conversation != null) {
        final messages = await _chatService.getMessages(conversation.id);
        await _chatService.markMessagesAsRead(conversation.id, user['id']?.toString() ?? user['uid']?.toString() ?? '');
        
        setState(() {
          _conversation = conversation;
          _messages = messages;
          _isLoading = false;
        });
        
        _scrollToBottom();
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversation == null) return;
    
    final user = _authService.currentUser;
    if (user == null) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();
    
    setState(() => _isSending = true);

    final message = await _chatService.sendMessage(
      conversationId: _conversation!.id,
      senderId: user['id']?.toString() ?? user['uid']?.toString() ?? '',
      message: messageText,
    );

    if (message != null) {
      setState(() {
        _messages.add(message);
        _isSending = false;
      });
      
      _scrollToBottom();
      
      // Trigger bot reply for support chats
      if (widget.type == 'support') {
        await _chatService.sendBotReply(_conversation!.id, messageText);
        await _loadMessages();
      }
    } else {
      setState(() => _isSending = false);
    }
  }

  Future<void> _loadMessages() async {
    if (_conversation != null) {
      final messages = await _chatService.getMessages(_conversation!.id);
      setState(() => _messages = messages);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Color(0xFF8B1538),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                ),
                _buildMessageInput(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Send a message to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final user = _authService.currentUser;
    final isMe = user != null && message.senderId == (user['id']?.toString() ?? user['uid']?.toString() ?? '');
    final isBot = (message.isFromBot as bool?) ?? false;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && !isBot)
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF8B1538),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
          if (isBot)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
          SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? Color(0xFF8B1538)
                    : isBot
                        ? Colors.blue[50]
                        : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: isMe ? Radius.circular(16) : Radius.circular(4),
                  bottomRight: isMe ? Radius.circular(4) : Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF8B1538),
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF8B1538),
              child: IconButton(
                icon: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
