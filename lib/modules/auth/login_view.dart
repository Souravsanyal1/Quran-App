import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_routes.dart';
import 'auth_controller.dart';

// ── Design Tokens ────────────────────────────────────────────────────────────
class _LoginTheme {
  _LoginTheme._();
  static const Color emerald      = Color(0xFF1B5E35);
  static const Color emeraldLight = Color(0xFF2E7D52);
  static const Color emeraldDark  = Color(0xFF0D3B1E);
  static const Color gold         = Color(0xFFC9A84C);
  static const Color goldLight    = Color(0xFFE8C97A);
  static const Color darkSurface  = Color(0xFF141420);
}

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect if already logged in as admin
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isAdmin.value && controller.user.value != null) {
        Get.offAllNamed(AppRoutes.adminDashboard);
      }
    });

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final isObscured = true.obs;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_LoginTheme.emeraldDark, _LoginTheme.darkSurface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _LoginTheme.emerald.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: _LoginTheme.gold.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      color: _LoginTheme.gold,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Admin Login',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access your Qurania dashboard',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Email Field
                  TextField(
                    controller: emailController,
                    style: GoogleFonts.poppins(color: Colors.white),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: GoogleFonts.poppins(color: Colors.white30),
                      prefixIcon: const Icon(Icons.email_outlined, color: _LoginTheme.gold),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _LoginTheme.emerald.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _LoginTheme.emerald, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  Obx(() => TextField(
                    controller: passwordController,
                    obscureText: isObscured.value,
                    style: GoogleFonts.poppins(color: Colors.white),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      controller.login(
                        emailController.text.trim(),
                        passwordController.text.trim(),
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.poppins(color: Colors.white30),
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: _LoginTheme.gold),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isObscured.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _LoginTheme.emerald,
                        ),
                        onPressed: () => isObscured.toggle(),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: _LoginTheme.emerald.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: _LoginTheme.emerald, width: 1.5),
                      ),
                    ),
                  )),
                  const SizedBox(height: 32),
                  
                  // Login Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value 
                        ? null 
                        : () => controller.login(
                            emailController.text.trim(), 
                            passwordController.text.trim()
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _LoginTheme.emerald,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: _LoginTheme.gold, width: 0.5),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Back to User App Button
                  TextButton.icon(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    icon: const Icon(Icons.arrow_back_rounded, color: _LoginTheme.gold, size: 18),
                    label: Text(
                      'Back to App',
                      style: GoogleFonts.poppins(
                        color: _LoginTheme.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
