import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final Rxn<User> user = Rxn<User>();
  final RxBool isAdmin = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
    ever(user, _checkAdminStatus);
  }

  Future<void> _checkAdminStatus(User? firebaseUser) async {
    if (firebaseUser == null) {
      isAdmin.value = false;
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists && doc.data()?['role'] == 'admin') {
        isAdmin.value = true;
      } else {
        isAdmin.value = false;
      }
    } catch (e) {
      isAdmin.value = false;
      Get.log('Error checking admin status: $e');
    }
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Input Error',
        'Please enter email and password.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Perform Admin Role Check
      var doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(credential.user!.uid)
          .get();

      // Temporary Admin Seeding Fallback
      if (!doc.exists && email == 'joysanyal1999@gmail.com') {
        final adminData = {
          'name': 'Sourav',
          'role': 'admin',
          'email': 'joysanyal1999@gmail.com',
          'password': '01307460389',
          'createdAt': FieldValue.serverTimestamp(),
        };
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(credential.user!.uid)
            .set(adminData);

        // Re-fetch the document
        doc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(credential.user!.uid)
            .get();
      }

      if (doc.exists && doc.data()?['role'] == 'admin') {
        isAdmin.value = true;
        Get.offAllNamed(kIsWeb ? AppRoutes.adminDashboard : AppRoutes.home);
        Get.snackbar(
          'Login Successful',
          'Welcome, Admin ${doc.data()?['name'] ?? ''}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
        );
      } else {
        // Not an admin! Log out immediately.
        await _auth.signOut();
        isAdmin.value = false;
        Get.snackbar(
          'Access Denied',
          'You are not authorized as an admin.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No admin user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      }
      Get.snackbar(
        'Login Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    isAdmin.value = false;
    Get.offAllNamed(AppRoutes.home);
  }

  void goToAdmin() {
    Get.toNamed(AppRoutes.admin);
  }
}
