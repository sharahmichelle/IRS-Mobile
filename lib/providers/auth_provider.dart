// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../apis/firebase_auth_api.dart';
import '../apis/firebase_user_api.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuthAPI authService;
  late FirebaseUserAPI userService;
  late Stream<User?> uStream;
  User? firebaseUser;
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  AuthProvider() {
    authService = FirebaseAuthAPI();
    userService = FirebaseUserAPI();
    firebaseUser = FirebaseAuth.instance.currentUser;
    uStream = authService.getUser();
    
    // Listen to auth state changes
    uStream.listen((user) async {
      firebaseUser = user;
      if (user != null) {
        // Load user data from Firestore when auth state changes
        await _loadCurrentUser(user);
      } else {
        currentUser = null;
      }
      notifyListeners();
    });
  }

  Stream<User?> get userStream => uStream;
  bool get isLoggedIn => firebaseUser != null;
  bool get isEmailVerified => firebaseUser?.emailVerified ?? false;

  // Load current user data from Firestore
  Future<void> _loadCurrentUser(User firebaseUser) async {
    try {
      isLoading = true;
      notifyListeners();
      
      // Extract username from email for querying
      final emailParts = firebaseUser.email!.split('@');
      final userName = emailParts[0];
      
      // Get user by userName from Firestore
      final users = await userService.getUsersByUserNames([userName]);
      if (users.isNotEmpty) {
        currentUser = users.first;
        print('Loaded current user');
      } else {
        // If user doesn't exist in Firestore, create a new one
        currentUser = await _createUserInFirestore(firebaseUser);
        print('Created new user in Firestore');
      }
    } catch (e) {
      errorMessage = 'Failed to load user data: $e';
      debugPrint('Error loading current user: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Create user in Firestore after Firebase Auth registration
  Future<UserModel> _createUserInFirestore(User firebaseUser) async {
    try {
      // Extract email username for document ID
      final emailParts = firebaseUser.email!.split('@');
      final userName = emailParts[0];
      
      final newUser = UserModel(
        userName: userName,
        firstName: firebaseUser.displayName?.split(' ').first ?? '',
        lastName: firebaseUser.displayName?.split(' ').last ?? '',
        middleName: '',
        suffix: '',
        email: firebaseUser.email ?? '',
        authId: firebaseUser.uid,
        upCampus: 'UPM', // Default campus
        office: 'DRRMO',
        position: 'Encoder',
        userType: 1, // Default user type
        bldgName: '',
      );

      await userService.addUser(userName, newUser);
      return newUser;
    } catch (e) {
      throw Exception('Failed to create user in Firestore: $e');
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await authService.signIn(email, password);
      
      // User will be loaded automatically via the stream listener
      return null; // Success
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e);
      debugPrint('Sign in error: ${e.code} - ${e.message}');
      return errorMessage;
    } catch (e) {
      errorMessage = 'Sign in failed. Please try again.';
      debugPrint('Sign in error: $e');
      return errorMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String upCampus,
    required String office,
    required String position,
    String middleName = '',
    String suffix = '',
    String bldgName = '',
    int userType = 1,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Create user in Firebase Auth
      await authService.signUp(email, password);
      
      // Extract username from email
      final emailParts = email.split('@');
      final userName = emailParts[0];
      
      // Create user in Firestore
      final newUser = UserModel(
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        suffix: suffix,
        email: email,
        authId: FirebaseAuth.instance.currentUser?.uid ?? '',
        upCampus: upCampus,
        office: office,
        position: position,
        userType: userType,
        bldgName: bldgName,
      );

      await userService.addUser(userName, newUser);
      
      // Send email verification
      await authService.verifyEmail();
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e);
      debugPrint('Sign up error: ${e.code} - ${e.message}');
      return errorMessage;
    } catch (e) {
      errorMessage = 'Sign up failed. Please try again.';
      debugPrint('Sign up error: $e');
      return errorMessage;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();
      
      await authService.signOut();
      currentUser = null;
      firebaseUser = null;
      
      // Navigate to login screen
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      errorMessage = 'Sign out failed. Please try again.';
      debugPrint('Sign out error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      
      await authService.resetPassword(email);
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e);
      debugPrint('Reset password error: ${e.code} - ${e.message}');
    } catch (e) {
      errorMessage = 'Reset password failed. Please try again.';
      debugPrint('Reset password error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? middleName,
    String? suffix,
    String? displayName,
    String? office,
    String? position,
    String? upCampus,
    String? bldgName,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      
      if (currentUser != null && firebaseUser != null) {
        // Update Firestore user
        final updates = <String, dynamic>{};
        if (firstName != null) updates['firstName'] = firstName;
        if (lastName != null) updates['lastName'] = lastName;
        if (middleName != null) updates['middleName'] = middleName;
        if (suffix != null) updates['suffix'] = suffix;
        if (office != null) updates['office'] = office;
        if (position != null) updates['position'] = position;
        if (upCampus != null) updates['upCampus'] = upCampus;
        if (bldgName != null) updates['bldgName'] = bldgName;
        
        if (updates.isNotEmpty) {
          await userService.editUser(currentUser!.userName, updates);
          
          // Update local user object
          currentUser = currentUser!.copyWith(
            firstName: firstName ?? currentUser!.firstName,
            lastName: lastName ?? currentUser!.lastName,
            middleName: middleName ?? currentUser!.middleName,
            suffix: suffix ?? currentUser!.suffix,
            office: office ?? currentUser!.office,
            position: position ?? currentUser!.position,
            upCampus: upCampus ?? currentUser!.upCampus,
            bldgName: bldgName ?? currentUser!.bldgName,
          );
        }
        
        // Update Firebase Auth display name
        if (displayName != null) {
          await authService.updateProfile(displayName: displayName);
        }
      }
    } catch (e) {
      errorMessage = 'Profile update failed. Please try again.';
      debugPrint('Update profile error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmail() async {
    try {
      await authService.verifyEmail();
    } catch (e) {
      debugPrint('Verify email error: $e');
      rethrow;
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Clear error message
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Check if user has specific role/permission
  bool hasPermission(int requiredLevel) {
    return currentUser?.userType != null && 
           currentUser!.userType >= requiredLevel;
  }

  // Check if user is admin (assuming userType 3 is admin)
  bool get isAdmin => hasPermission(3);

  // Check if user is encoder (assuming userType 1 is encoder)
  bool get isEncoder => hasPermission(1);

  // Check if user is manager (assuming userType 2 is manager)
  bool get isManager => hasPermission(2);
}