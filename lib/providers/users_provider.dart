import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:upm_drrm_irs_mobile/apis/firebase_user_api.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';

class Users with ChangeNotifier {
  late final FirebaseUserAPI firebaseService;
  late Stream<List<User>> _usersStream;
  List<User> _currentUsers = [];
  StreamSubscription<List<User>>? _usersSubscription;

  Users() {
    firebaseService = FirebaseUserAPI();
    fetchUsers();
  }

  Stream<List<User>> get users => _usersStream;
  List<User> get currentUsers => _currentUsers;

  void fetchUsers() {
    try {
      _usersStream = firebaseService.getAllUsers().map((snapshot) {
        return snapshot.docs.map((doc) {
          return User.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
        }).toList();
      });

      // Subscribe to the stream to update currentUsers
      _usersSubscription = _usersStream.listen((users) {
        _currentUsers = users;
        notifyListeners();
      }, onError: (error) {
        debugPrint('Error in users stream: $error');
        _currentUsers = [];
        notifyListeners();
      });
      
    } catch (e) {
      debugPrint('Error fetching users: $e');
      // Initialize with empty stream
      _usersStream = Stream.value([]);
      _currentUsers = [];
      notifyListeners();
    }
  }

  Future<String> addUser(User user) async {
    try {
      final message = await firebaseService.addUser(user.userName, user);
      debugPrint(message);
      notifyListeners();
      return message;
    } catch (e) {
      debugPrint('Error adding user: $e');
      return "Failed to add user: $e";
    }
  }

  Future<void> editUser(String userName, Map<String, dynamic> edit) async {
    try {
      final message = await firebaseService.editUser(userName, edit);
      debugPrint(message);
      notifyListeners();
    } catch (e) {
      debugPrint('Error editing user: $e');
      throw Exception('Failed to edit user: $e');
    }
  }

  Future<void> deleteUser(String userName) async {
    try {
      final message = await firebaseService.deleteUser(userName);
      debugPrint(message);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<User> getUserById(String userName) async {
    try {
      final user = await firebaseService.getUserById(userName);
      return user;
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      throw Exception('Failed to get user: $e');
    }
  }

  Stream<User?> getUserByAuthIdStream(String authId) {
    return firebaseService.getUserByAuthId(authId).map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return User.fromFirestore(snapshot.docs.first as DocumentSnapshot<Map<String, dynamic>>);
    });
  }

  Future<List<User>> getUsersByUserNames(List<String> userNames) async {
    try {
      final users = await firebaseService.getUsersByUserNames(userNames);
      return users;
    } catch (e) {
      debugPrint('Error getting users by usernames: $e');
      return [];
    }
  }

  Future<List<User>> getUsersByPosition(String position) async {
    try {
      final users = await firebaseService.getUsersByPosition(position);
      return users;
    } catch (e) {
      debugPrint('Error getting users by position: $e');
      return [];
    }
  }

  Future<List<User>> getUsersByOffice(String office) async {
    try {
      final users = await firebaseService.getUsersByOffice(office);
      return users;
    } catch (e) {
      debugPrint('Error getting users by office: $e');
      return [];
    }
  }

  Stream<List<User>> getUsersByType(int userType) {
    try {
      return firebaseService.getUsersByType(userType);
    } catch (e) {
      debugPrint('Error getting users by type: $e');
      return Stream.value([]);
    }
  }

  Future<bool> usernameExists(String userName) async {
    try {
      return await firebaseService.usernameExists(userName);
    } catch (e) {
      debugPrint('Error checking username existence: $e');
      return false;
    }
  }

  Future<String> updateUserProfile(String userName, User updatedUser) async {
    try {
      final message = await firebaseService.updateUserProfile(userName, updatedUser);
      debugPrint(message);
      notifyListeners();
      return message;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return "Failed to update user profile: $e";
    }
  }

  // Search users by name
  Stream<List<User>> searchUsers(String query) {
    return _usersStream.map((users) {
      if (query.isEmpty) return users;
      return users.where((user) {
        final fullName = user.fullName.toLowerCase();
        final userNameLower = user.userName.toLowerCase();
        final searchQuery = query.toLowerCase();
        return fullName.contains(searchQuery) || userNameLower.contains(searchQuery);
      }).toList();
    });
  }

  // Get user by authId synchronously from current list
  User? getUserByAuthIdFromList(String authId) {
    try {
      if (_currentUsers.isEmpty) return null;
      return _currentUsers.firstWhere(
        (user) => user.authId == authId,
        orElse: () => throw StateError('User not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Get user by userName synchronously from current list
  User? getUserByUserNameFromList(String userName) {
    try {
      if (_currentUsers.isEmpty) return null;
      return _currentUsers.firstWhere(
        (user) => user.userName == userName,
        orElse: () => throw StateError('User not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Search users synchronously from current list
  List<User> searchUsersFromList(String query) {
    if (query.isEmpty) return _currentUsers;
    
    return _currentUsers.where((user) {
      final fullName = user.fullName.toLowerCase();
      final userNameLower = user.userName.toLowerCase();
      final searchQuery = query.toLowerCase();
      return fullName.contains(searchQuery) || userNameLower.contains(searchQuery);
    }).toList();
  }

  // Clean up subscription
  @override
  void dispose() {
    _usersSubscription?.cancel();
    super.dispose();
  }
}