import 'package:firebase_auth/firebase_auth.dart';

import '../auth/auth_error.dart';

abstract interface class AuthProvider {
  String? get userId;

  Future<bool> deleteAccountAndSignOut();

  Future<void> signOut();

  Future<bool> register({
    required String email,
    required String password,
  });

  Future<bool> login({
    required String email,
    required String password,
  });
}

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<bool> deleteAccountAndSignOut() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user == null) {
      return false;
    }
    try {
      // delete the User,
      await user.delete();
      // log the user out
      await auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthError.from(e);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError.from(e);
    } catch (_) {
      rethrow;
    }
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<bool> register({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthError.from(e);
    } catch (_) {
      rethrow;
    }
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      //ignore the error
    }
  }

  @override
  String? get userId => FirebaseAuth.instance.currentUser?.uid;
}
