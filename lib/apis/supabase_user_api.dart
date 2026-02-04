import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseUserAPI {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all users as a stream
  Stream<List<UserModel>> getAllUsers() {
    return _supabase
      .from('users')
      .stream(primaryKey: ['username'])
      .map((data) => data.map((json) => UserModel.fromJson(json)).toList());
  }

  // Get user by authId as a stream
  Stream<List<UserModel>> getUserByAuthId(String authId) {
    return _supabase
      .from('users')
      .stream(primaryKey: ['username'])
      .eq('authid', authId)
      .map((data) => data.map((json) => UserModel.fromJson(json)).toList());
  }

  // Get users by usernames
  Future<List<UserModel>> getUsersByUserNames(List<String> userNames) async {
    try {
        // For multiple usernames, we need to build an OR query
      if (userNames.isEmpty) return [];

        // Supabase column name is 'username' (lowercase)
        String filter = userNames.map((name) => 'username.eq.$name').join(',');
        final response = await _supabase.from('users').select().or(filter);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching users by usernames: $e');
      return [];
    }
  }

  // Get a single user by userName
  Future<UserModel> getUserById(String userName) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', userName)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('Error fetching user by ID: $e');
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Add a new user
  Future<void> addUser(String userName, UserModel user) async {
    try {
      debugPrint('Inserting user: $userName');
      final response = await _supabase
          .from('users')
          .insert(user.toJson());
      debugPrint('User inserted successfully: $response');
    } catch (e) {
      debugPrint('Error adding user: $e');
      throw Exception('Failed to add user: $e');
    }
  }

  // Delete a user
  Future<String> deleteUser(String userName) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('username', userName);
      return "Successfully deleted user!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  // Edit/update a user
  Future<String> editUser(String userName, Map<String, dynamic> edit) async {
    try {
      await _supabase
          .from('users')
          .update(edit)
          .eq('username', userName);
      return "Successfully edited user!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  // Get users by position
  Future<List<UserModel>> getUsersByPosition(String position) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('position', position);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching users by position: $e');
      return [];
    }
  }

  // Get users by office
  Future<List<UserModel>> getUsersByOffice(String office) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('office', office);

      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching users by office: $e');
      return [];
    }
  }

  // Get users by userType
  Stream<List<UserModel>> getUsersByType(int userType) {
    return _supabase
      .from('users')
      .stream(primaryKey: ['username'])
      .eq('usertype', userType)
      .map((data) => data.map((json) => UserModel.fromJson(json)).toList());
  }

  // Check if username exists
  Future<bool> usernameExists(String userName) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('username', userName);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  // Update user profile
  Future<String> updateUserProfile(String userName, UserModel updatedUser) async {
    try {
      await _supabase
          .from('users')
          .update(updatedUser.toJson())
          .eq('username', userName);
      return "Successfully updated user profile!";
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}
