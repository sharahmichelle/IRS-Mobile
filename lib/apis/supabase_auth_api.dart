import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user stream
  Stream<User?> getUser() {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Reset password error: $e');
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (photoURL != null) updates['photo_url'] = photoURL;

      await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(email: newEmail),
      );
    } catch (e) {
      throw Exception('Update email error: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Update password error: $e');
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _supabase.auth.admin.deleteUser(_supabase.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Delete account error: $e');
    }
  }

  // Verify email
  Future<void> verifyEmail() async {
    try {
      await _supabase.auth.resend(
        type: OtpType.email,
        email: _supabase.auth.currentUser?.email,
      );
    } catch (e) {
      throw Exception('Verify email error: $e');
    }
  }

  // Get user token
  Future<String?> getIdToken() async {
    try {
      return _supabase.auth.currentSession?.accessToken;
    } catch (e) {
      throw Exception('Get token error: $e');
    }
  }

  // Re-authenticate user (for sensitive operations)
  Future<void> reauthenticate(String password) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null && user.email != null) {
        await _supabase.auth.signInWithPassword(
          email: user.email!,
          password: password,
        );
      }
    } catch (e) {
      throw Exception('Re-authenticate error: $e');
    }
  }
}
