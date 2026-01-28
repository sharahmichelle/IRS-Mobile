// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../apis/supabase_auth_api.dart';
import '../apis/supabase_user_api.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  late SupabaseAuthAPI authService;
  late SupabaseUserAPI userService;
  late Stream<User?> uStream;
  User? supabaseUser;
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  AuthProvider() {
    authService = SupabaseAuthAPI();
    userService = SupabaseUserAPI();
    supabaseUser = Supabase.instance.client.auth.currentUser;
    uStream = authService.getUser();

    // Listen to auth state changes
    uStream.listen((user) async {
      supabaseUser = user;
      if (user != null) {
        // Load user data from Supabase when auth state changes
        await _loadCurrentUser(user);
      } else {
        currentUser = null;
      }
      notifyListeners();
    });
  }

  Stream<User?> get userStream => uStream;
  bool get isLoggedIn => supabaseUser != null;
  bool get isEmailVerified => supabaseUser?.emailConfirmedAt != null;

  // Load current user data from Supabase
  Future<void> _loadCurrentUser(User supabaseUser) async {
    try {
      isLoading = true;
      notifyListeners();

      // Extract username from email for querying
      final emailParts = supabaseUser.email!.split('@');
      final userName = emailParts[0];

      // Get user by userName from Supabase
      final users = await userService.getUsersByUserNames([userName]);
      if (users.isNotEmpty) {
        currentUser = users.first;
        print('Loaded current user');
      } else {
        // If user doesn't exist in Supabase, create a new one
        currentUser = await _createUserInSupabase(supabaseUser);
        print('Created new user in Supabase');
      }
    } catch (e) {
      errorMessage = 'Failed to load user data: $e';
      debugPrint('Error loading current user: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Create user in Supabase after Supabase Auth registration
  Future<UserModel> _createUserInSupabase(User supabaseUser) async {
    try {
      // Extract email username for document ID
      final emailParts = supabaseUser.email!.split('@');
      final userName = emailParts[0];

      // If user_metadata has display_name, use it; otherwise, default to 'Encoder'
      final userMetadata = supabaseUser.userMetadata;
      final firstName = userMetadata?['display_name']?.split(' ').first ?? 'Encoder';
      final lastName = userMetadata?['display_name']?.split(' ').last ?? '';

      final newUser = UserModel(
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        middleName: '',
        suffix: '',
        email: supabaseUser.email ?? '',
        authId: supabaseUser.id,
        upCampus: 'UPM', // Default campus
        office: 'DRRMO',
        position: 'Encoder',
        userType: 1, // Default user type
        bldgName: '',
      );

      await userService.addUser(userName, newUser);
      return newUser;
    } catch (e) {
      throw Exception('Failed to create user in Supabase: $e');
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

      // Step 1: Create user in Supabase Auth
      debugPrint('Step 1: Creating auth user...');
      await authService.signUp(email, password);
      debugPrint('Auth user created successfully');

      // Extract username from email
      final emailParts = email.split('@');
      final userName = emailParts[0];

      // Build display name for Supabase Auth
      final displayNameParts = [firstName];
      if (middleName.isNotEmpty) displayNameParts.add(middleName);
      displayNameParts.add(lastName);
      if (suffix.isNotEmpty) displayNameParts.add(suffix);
      final displayName = displayNameParts.join(' ');

      // Step 2: Update Supabase Auth profile with display name
      debugPrint('Step 2: Updating profile...');
      try {
        await authService.updateProfile(displayName: displayName);
        debugPrint('Profile updated successfully');
      } catch (e) {
        debugPrint('Warning: Profile update failed: $e');
        // Don't fail signup if profile update fails
      }

      // Step 3: Create user in database
      debugPrint('Step 3: Creating user in database...');
      final newUser = UserModel(
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
        suffix: suffix,
        email: email,
        authId: Supabase.instance.client.auth.currentUser?.id ?? '',
        upCampus: upCampus,
        office: office,
        position: position,
        userType: userType,
        bldgName: bldgName,
      );

      try {
        await userService.addUser(userName, newUser);
        debugPrint('User added to database successfully');
      } catch (e) {
        debugPrint('Error: User database insert failed: $e');
        // Log the error but don't fail signup - auth succeeded
        // The user can still sign in, just without a profile
      }

      // Step 4: Send email verification (optional, don't fail if this fails)
      debugPrint('Step 4: Sending verification email...');
      try {
        await authService.verifyEmail();
        debugPrint('Verification email sent');
      } catch (e) {
        debugPrint('Warning: Verification email failed: $e');
      }

      debugPrint('Sign up completed successfully!');
      return null; // Success
    } catch (e) {
      errorMessage = 'Sign up failed: ${e.toString()}';
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
      supabaseUser = null;

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

      if (currentUser != null && supabaseUser != null) {
        // Update Supabase user
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

        // Update Supabase Auth display name
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
  bool get isAdmin => hasPermission(2);

  // Check if user is encoder (assuming userType 1 is encoder)
  bool get isEncoder => hasPermission(1);

}