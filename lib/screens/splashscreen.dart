import 'package:firebase_session/screens/signup_screen.dart';
import 'package:firebase_session/utils/appcolor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
 import 'login_screen.dart';
 import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isChecking = true; // لعرض لودينغ بسيط أثناء الفحص

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(milliseconds: 300)); // شكل نظافة بسيطة

    if (user != null) {
      // المستخدم مسجل دخول → تحويل لـ Home مباشرة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // غير مسجل دخول → إظهار الأزرار
      setState(() {
        isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isChecking
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_rounded,
                    size: 120,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "ChitChatter",
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // أزرار Login و Signup
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textLight,
                            foregroundColor: AppColors.secondary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Colors.white, width: 2),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignupScreen()),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
