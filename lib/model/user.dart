import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String password;
  final String role;
  final bool disabled;

  UserModel({
    required this.email,
    required this.password,
    required this.role,
    required this.disabled,
  });

  factory UserModel.fromFirestore(QueryDocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
        email: data['email'],
        password: data['password'],
        role: data['role'],
        disabled: data['disabled']);
  }
}
