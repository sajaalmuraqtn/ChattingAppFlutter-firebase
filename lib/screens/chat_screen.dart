import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_session/utils/appcolor.dart';
import 'package:flutter/material.dart';
 
class ChatScreen extends StatefulWidget {
  final String receivedName;
  final String receivedEmail;

  const ChatScreen({
    super.key,
    required this.receivedName,
    required this.receivedEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late User signedUser;
  final TextEditingController textmessageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String chatId;

  void getCred() {
    signedUser = _auth.currentUser!;
    // إنشاء chatId ثابت بين المستخدمين
    chatId = signedUser.email!.compareTo(widget.receivedEmail) < 0
        ? "${signedUser.email}_${widget.receivedEmail}"
        : "${widget.receivedEmail}_${signedUser.email}";
  }

  void _sendMessage() async {
    final text = textmessageController.text.trim();
    if (text.isEmpty) return;

    await _firestore
        .collection('messages')
        .doc(chatId)
        .collection("chat")
        .add({
      'text': text,
      'sender': signedUser.email,
      'received': widget.receivedEmail,
      'timestamp': FieldValue.serverTimestamp(),
    });

    textmessageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 70,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getCred();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
               Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.receivedName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.receivedName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

               Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('messages')
                        .doc(chatId)
                        .collection('chat')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg =
                              messages[index].data() as Map<String, dynamic>;
                          bool isMe = msg['sender'] == signedUser.email;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.chatMe
                                    : AppColors.chatOther,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg['text'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

               Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textmessageController,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
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
