import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserAPI {
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getAllUsers() {
    return db.collection("users").snapshots();
  }

  Stream<QuerySnapshot> getUserByAuthId(String authId) {
    return db
        .collection('users')
        .where('authId', isEqualTo: authId)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getUsersByUserNames(List<String> userNames) async {
    try{ 
      QuerySnapshot snapshot = await db
        .collection('users')
        .where(FieldPath.documentId, whereIn: userNames)
        .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['userName'] = doc.id; // Add the username as the document ID
        return data;
      }).toList();
      
    } catch (e) {
      print('Error fetching users by usernames: $e');
      return [];
    }
  }

  Future<String> addUser(String userName, Map<String, dynamic> user) async {
    try {
      await db.collection("users").doc(userName).set(user);
      return "Successfully added user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    }
  }

  Future<String> deleteUser(String? id) async {
    try {
      await db.collection("users").doc(id).delete();
      return "Successfully deleted user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    }
  }

  Future<String> editUser(String? id, Map<String, dynamic> edit) async {
    try {
      await db.collection("users").doc(id).update(edit);
      return "Successfully edited user!";
    } on FirebaseException catch (e) {
      return "Failed with error '${e.code}: ${e.message}'";
    }
  }
}
