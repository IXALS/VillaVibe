import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/app_user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromFirestore(doc);
  }

  Future<AppUser?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    bool isHost = false,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        photoUrl: '',
        isHost: isHost,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(appUser.toMap());
    }
  }

  Future<void> upgradeToHost(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isHost': true});
  }

  Future<void> signInWithGoogle() async {
    try {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Once signed in, return the UserCredential
      final UserCredential userCredential =
          await _auth.signInWithProvider(googleProvider);

      // Check if user exists in Firestore, if not create
      final user = userCredential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          final appUser = AppUser(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'User',
            photoUrl: user.photoURL ?? '',
            isHost: false,
          );
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(appUser.toMap());
        }
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<bool> checkUserExists(String email) async {
    try {
      // First try to fetch sign in methods (fastest if allowed)
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) return true;
      } catch (_) {
        // Ignore error and fall back to Firestore
      }

      // Fallback: Check Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(FirebaseAuth.instance, FirebaseFirestore.instance);
}

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
Future<AppUser?> currentUser(CurrentUserRef ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getCurrentUser();
}
