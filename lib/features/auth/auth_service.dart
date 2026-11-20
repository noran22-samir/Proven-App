import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proven/features/auth/signup.dart';
import 'package:proven/features/auth/role_selection_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createAccount(SignUpData data) async {
    // Create account in Firebase Authentication
    final credential = await _auth.createUserWithEmailAndPassword(
      email: data.email,
      password: data.password,
    );

    final user = credential.user!;

    try {
      // Save user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': data.email,
        'phone': data.phone,
        'role': data.role.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        // Creator information
        if (data.role == UserRole.creator) ...{
          'firstName': data.firstName,
          'lastName': data.lastName,
          'gender': data.gender?.name,
          'university': data.university,
          'faculty': data.faculty,
          'graduationYear': data.graduationYear,
          'specialization': data.specialization,
        },

        // Company information
        if (data.role == UserRole.company) ...{
          'companyName': data.companyName,
          'industry': data.industry,
          'foundedYear': data.foundedYear,
          'location': data.location,
          'description': data.description,
        },
      });
    } catch (e) {
      // if saving the data failed, delete the account so we don't leave
      // a user in Auth without data in Firestore
      await user.delete();
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();
}