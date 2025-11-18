import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_session/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_session/utils/appcolor.dart';
 import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final currentUser = snapshot.data!;

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
              child: Column(
                children: [
                  // ---------- Top Header ----------
                  Container(
                    height: kToolbarHeight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            // جلب بيانات المستخدم من Firestore
                            final doc = await _firestore
                                .collection('users')
                                .doc(currentUser.uid)
                                .get();

                            final data = doc.data();
                            if (data != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FriendProfileScreen(
                                    ismy: true,
                                    name: data['displayName'] ?? 'No Name',
                                    email: data['email'] ?? 'No Email',
                                    phone: data['phone'] ?? 'No Phone',
                                  ),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              (currentUser.displayName != null &&
                                      currentUser.displayName!.isNotEmpty)
                                  ? currentUser.displayName![0].toUpperCase()
                                  : (currentUser.email != null &&
                                          currentUser.email!.isNotEmpty)
                                      ? currentUser.email![0].toUpperCase()
                                      : '?',
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        const Text(
                          'Friends',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ---------- Users List ----------
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('users').snapshots(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        final users = userSnapshot.data!.docs
                            .where((doc) => doc['uid'] != currentUser.uid)
                            .toList();

                        if (users.isEmpty) {
                          return const Center(
                            child: Text(
                              "No users found",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final displayName =
                                user['displayName'] ?? 'No Name';
                            final email = user['email'] ?? 'No Email';
                            final phone = user['phone'] ?? 'No Phone';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.secondary,
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : '?',
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text(displayName),
                                subtitle: Text(email),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        receivedName: displayName,
                                        receivedEmail: email,
                                        receivedphone: phone,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
