import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:upm_drrm_irs_mobile/models/user_model.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Get all users as a stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return db.collection("users").snapshots();
  }

  // Get user by authId as a stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserByAuthId(String authId) {
    return db
        .collection('users')
        .where('authId', isEqualTo: authId)
        .snapshots();
  }

  // Get users by usernames (document IDs)
  Future<List<User>> getUsersByUserNames(List<String> userNames) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('users')
        .where(FieldPath.documentId, whereIn: userNames)
        .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return User.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error fetching users by usernames: $e');
      return [];
    }
  }

  // Get a single user by userName (document ID)
  Future<User> getUserById(String userName) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await db.collection("users").doc(userName).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Add a new user
  Future<String> addUser(String userName, User user) async {
    try {
      await db.collection("users").doc(userName).set(user.toJson());
      return "Successfully added user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  // Delete a user
  Future<String> deleteUser(String userName) async {
    try {
      await db.collection("users").doc(userName).delete();
      return "Successfully deleted user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  // Edit/update a user
  Future<String> editUser(String userName, Map<String, dynamic> edit) async {
    try {
      await db.collection("users").doc(userName).update(edit);
      return "Successfully edited user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    } catch (e) {
      return "Failed with error: $e";
    }
  }

  // Get users by position
  Future<List<User>> getUsersByPosition(String position) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('users')
        .where('position', isEqualTo: position)
        .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return User.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error fetching users by position: $e');
      return [];
    }
  }

  // Get users by office
  Future<List<User>> getUsersByOffice(String office) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await db
        .collection('users')
        .where('office', isEqualTo: office)
        .get();

      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return User.fromFirestore(doc);
      }).toList();
    } catch (e) {
      print('Error fetching users by office: $e');
      return [];
    }
  }

  // Get users by userType
  Stream<List<User>> getUsersByType(int userType) {
    return db
        .collection('users')
        .where('userType', isEqualTo: userType)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
        return User.fromFirestore(doc);
      }).toList();
    });
  }

  // Check if username exists
  Future<bool> usernameExists(String userName) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await db.collection("users").doc(userName).get();
      return doc.exists;
    } catch (e) {
      print('Error checking username existence: $e');
      return false;
    }
  }

  // Update user profile
  Future<String> updateUserProfile(String userName, User updatedUser) async {
    try {
      await db.collection("users").doc(userName).update(updatedUser.toJson());
      return "Successfully updated user profile!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    } catch (e) {
      return "Failed with error: $e";
    }
  }
}