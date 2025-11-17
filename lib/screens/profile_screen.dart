import 'package:flutter/material.dart';
import '../utils/appcolor.dart';

class FriendProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  const FriendProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 👈 شفاف
        elevation: 0,
        title: const Text(
          'Friend Profile',
          style: TextStyle(color: AppColors.textLight),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textLight),
      ),
      extendBodyBehindAppBar: true, // 👈 مهم لظهور الخلفية خلف الـ AppBar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar Circle
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Text(
                      name,
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Email
                Row(
                  children: [
                    const Icon(Icons.email, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Phone
                Row(
                  children: [
                    const Icon(Icons.phone, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Text(
                      phone,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Chat button
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
