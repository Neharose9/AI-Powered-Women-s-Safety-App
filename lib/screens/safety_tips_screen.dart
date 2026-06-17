import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../services/api_service.dart';
import 'dart:ui';
import '../widgets/safety_logo.dart';

class SafetyTipsScreen extends StatefulWidget {
  const SafetyTipsScreen({Key? key}) : super(key: key);

  @override
  State<SafetyTipsScreen> createState() => _SafetyTipsScreenState();
}

class _SafetyTipsScreenState extends State<SafetyTipsScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "text": "Hello! I am your Kaval Bot. How can I help you stay safe today?",
      "time": DateTime.now()
    }
  ];
  bool _isTyping = false;
  final List<String> _quickReplies = [
    "I am being followed",
    "Scam call help",
    "Home visitor safety",
    "Gas leak emergency",
    "Road accident help",
    "Online fraud alert",
    "ATM scam protection",
    "Medical emergency",
    "First aid for burns",
    "Elevator help"
  ];

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    String query = _controller.text.trim();
    setState(() {
      _messages.add({
        "isUser": true,
        "text": query,
        "time": DateTime.now()
      });
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // API Call
    final res = await ApiService.askSafetyAi(query);
    
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add({
        "isUser": false,
        "text": res['response'] ?? "I'm sorry, I'm having trouble connecting right now.",
        "time": DateTime.now()
      });
    });
    _scrollToBottom();
  }

  void _sendSpecificQuery(String query) async {
    setState(() {
      _messages.add({
        "isUser": true,
        "text": query,
        "time": DateTime.now()
      });
      _isTyping = true;
    });
    _scrollToBottom();

    final res = await ApiService.askSafetyAi(query);
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add({
        "isUser": false,
        "text": res['response'] ?? "I'm sorry, I'm having trouble connecting right now.",
        "time": DateTime.now()
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FA),
      body: Column(
        children: [
          // Custom Branded Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20, left: 20, right: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 15),
                const SafetyLogo(size: 40, color: Colors.white),
                const SizedBox(width: 15),
                Text(
                  "Kaval Bot", 
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg['text'], msg['isUser']);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 10),
              child: Row(
                children: [
                  FadeIn(child: Text("Kaval Bot is thinking...", style: GoogleFonts.poppins(color: const Color(0xFF4A148C).withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic))),
                ],
              ),
            ),
          
          // Quick Replies
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickReplies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(_quickReplies[index]),
                    labelStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF7B1FA2)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE1BEE7)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => _sendSpecificQuery(_quickReplies[index]),
                  ),
                );
              },
            ),
          ),
          
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF7B1FA2) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isUser ? 20 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isUser ? Colors.white : const Color(0xFF4A148C), 
              fontSize: 14,
              fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _controller,
                  style: GoogleFonts.poppins(color: const Color(0xFF4A148C), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Type a safety question...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

