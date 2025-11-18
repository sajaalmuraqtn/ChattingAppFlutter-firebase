import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_session/screens/profile_screen.dart';
import 'package:firebase_session/utils/appcolor.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String receivedName;
  final String receivedEmail;
  final String receivedphone;

  const ChatScreen({
    super.key,
    required this.receivedName,
    required this.receivedEmail,
    required this.receivedphone,
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
    // بين المرسل الحالي والمستقبل اللي انا بدي ارسللو
    chatId = signedUser.email!.compareTo(widget.receivedEmail) < 0
        ? "${signedUser.email}_${widget.receivedEmail}"
        : "${widget.receivedEmail}_${signedUser.email}";
  }

  void _sendMessage() async {
    final text = textmessageController.text.trim();
    if (text.isEmpty) return;

    await _firestore.collection('messages').doc(chatId).collection("chat").add({
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendProfileScreen(
                              ismy: false,
                              name: widget.receivedName,
                              email: widget.receivedEmail,
                              phone: widget.receivedphone,
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.receivedName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FriendProfileScreen(
                                ismy: false,
                                name: widget.receivedName,
                                email: widget.receivedEmail,
                                phone: widget.receivedphone,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          widget.receivedName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // الرسائل
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
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
                        return const Center(child: CircularProgressIndicator());
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
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                // اسم المرسل
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 4,
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    isMe ? "You" : widget.receivedName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // فقاعة الرسالة
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 14,
                                  ),
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

                                // الوقت والتاريخ
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 4,
                                    top: 2,
                                  ),
                                  child: Text(
                                    msg['timestamp'] != null
                                        ? "${DateTime.fromMillisecondsSinceEpoch(msg['timestamp'].millisecondsSinceEpoch).hour.toString().padLeft(2, '0')}:"
                                              "${DateTime.fromMillisecondsSinceEpoch(msg['timestamp'].millisecondsSinceEpoch).minute.toString().padLeft(2, '0')}  "
                                              "${DateTime.fromMillisecondsSinceEpoch(msg['timestamp'].millisecondsSinceEpoch).day}/"
                                              "${DateTime.fromMillisecondsSinceEpoch(msg['timestamp'].millisecondsSinceEpoch).month}/"
                                              "${DateTime.fromMillisecondsSinceEpoch(msg['timestamp'].millisecondsSinceEpoch).year}"
                                        : "",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // ------------------ Input Field ------------------
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
