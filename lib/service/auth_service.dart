import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive_flutter/model/user.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  User? _user;
  String? _role;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  User? get user {
    return _user;
  }

  String? get role {
    return _role;
  }

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authStateChangesStreamListener);
  }

  Future<bool> login(String email, String password) async {
    try {
      await secureStorage.write(key: 'adminPassword', value: password);
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _user = credential.user;
      }
      fetchUserRole();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void fetchUserRole() async {
    print("It's called the fetchUserRole");
    String? userEmail = _user!.email;

    if (userEmail != null) {
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get()
          .then((snapshot) => snapshot.docs.first);

      // Return the role from the user document
      _role = userDoc['role'];
    }
  }

  // Future<bool> signup(String email, String password) async {
  //   try {
  //     // Create a new user account with email and password
  //     final credential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     if (credential.user != null) {
  //       // User successfully signed up
  //       return true;
  //     } else {
  //       // Handle error
  //       return false;
  //     }
  //   } catch (e) {
  //     // Handle exception
  //     return false;
  //   }
  // }

  Future<List<UserModel>> fetchUsers() async {
    List<UserModel> users = [];
    try {
      // Assuming you have a 'users' collection in Firestore
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        users.add(UserModel.fromFirestore(doc));
      }
    } catch (e) {
      print(e);
    }
    return users;
  }

  Future<bool> logout() async {
    try {
      await _firebaseAuth.signOut();

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void authStateChangesStreamListener(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }
  //it determines in  initial route which page they will go .if it becomes null then backto login page
}
