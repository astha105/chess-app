import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static Future<void> createUserIfNotExists(String provider) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        "uid": user.uid,
        "email": user.email,
        "name": user.displayName ?? "Guest",
        "provider": provider,
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }
}
