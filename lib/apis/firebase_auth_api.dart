import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthAPI {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> getUser() {
    return _auth.authStateChanges();
  }

  Future<UserCredential?> signIn(String email, String password) async {
    UserCredential? credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error in API: ${e.code}');
      throw e; // rethrow so caller can handle
    }
    return credential;
  }

  Future<UserCredential?> signUp(String email, String password) async {
    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('Error: ${e.code}');
      }
    }

    return credential;
  }

  Future<void> signOut() async {
    print("\nSigning Out...\n");
    await _auth
        .signOut()
        .then((value) {
          print("Signed out successfully!");
        })
        .catchError((e) {
          print(e);
        });
  }
}
