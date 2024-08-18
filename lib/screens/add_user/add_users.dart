import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive_flutter/constants.dart';
import 'package:rive_flutter/service/alert_service.dart';
import 'package:rive_flutter/service/auth_service.dart';
import 'package:rive_flutter/model/user.dart';

enum UserRole {
  Admin,
  User,
}

class AddUsers extends StatefulWidget {
  const AddUsers({Key? key}) : super(key: key);

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  final GetIt _getIt = GetIt.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late AlertService _alertService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  UserRole _selectedRole = UserRole.User;

  @override
  void initState() {
    super.initState();
    _alertService = _getIt.get<AlertService>();
  }

  Future<bool> signup(String email, String password) async {
    try {
      // Create a new user account with email and password
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // User successfully signed up
        return true;
      } else {
        // Handle error
        return false;
      }
    } catch (e) {
      // Handle exception
      return false;
    }
  }

  Future<void> _signup(String email, String password, UserRole role) async {
    // Retrieve current admin's email and store current admin user
    User? adminUser = FirebaseAuth.instance.currentUser;
    String? adminEmail = adminUser?.email;

    if (adminEmail != null) {
      // Retrieve the stored admin password securely
      String? adminPassword = await secureStorage.read(key: 'adminPassword');

      bool success = await signup(email, password);
      if (success) {
        await _firestore.collection('users').add({
          'email': email,
          'password': password,
          'role': role == UserRole.Admin ? 'admin' : 'user',
          'disabled': false, // Initially not disabled
        });

        if (adminPassword != null) {
          // Re-authenticate the admin user
          AuthCredential adminCredential = EmailAuthProvider.credential(
            email: adminEmail,
            password: adminPassword,
          );
          await FirebaseAuth.instance.signInWithCredential(adminCredential);
        }

        _emailController.clear();
        _passwordController.clear();
        _roleController.clear();

        setState(() {
          _selectedRole = UserRole.User;
        });
      }
    }
  }

  Future<void> _toggleUserStatus(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.size > 0) {
      String userId = querySnapshot.docs[0].id;
      bool currentStatus = querySnapshot.docs[0].get('disabled') ?? false;

      await _firestore.collection('users').doc(userId).update({
        'disabled': !currentStatus, // Toggle the disabled status
      });
    } else {
      throw Exception('User not found with email $email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Add Users')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              width: 600,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  // Optional: Adds a background color
                ),
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: "required Capital,small letters and >=3 numbers",
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                // Optional: Adds a background color
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              onChanged: (UserRole? value) {
                if (value != null) {
                  setState(() {
                    _selectedRole = value;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(0),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                // Optional: Adds a background color
              ),
              items: UserRole.values.map((role) {
                return DropdownMenuItem<UserRole>(
                  value: role,
                  child: Text(role == UserRole.Admin ? 'Admin' : 'User'),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                String email = _emailController.text;
                String password = _passwordController.text;
                if (EMAIL_VALIDATION_REGEX.hasMatch(email) &&
                    PASSWORD_VALIDATION_REGEX.hasMatch(password)) {
                  _signup(email, password, _selectedRole);
                  _alertService.showToast(text: "Account created successfully");
                } else {
                  _alertService.showToast(
                      text: "Follow correct pattern for password and email");
                }
              },
              child: Text('Create User'),
            ),
            SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No users found.'));
                  }

                  List<UserModel> users = snapshot.data!.docs.map((doc) {
                    return UserModel(
                      email: doc['email'],
                      password: doc['password'],
                      role: doc['role'],
                      disabled: doc['disabled'] ?? false,
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      UserModel user = users[index];
                      return Card(
                        elevation: 4,
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          trailing: user.role == "user"
                              ? IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirm User role'),
                                          content: Text(
                                              "Are you sure you want to change this user's role?"),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Confirm'),
                                              onPressed: () {
                                                _toggleUserStatus(user.email);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              : null,
                          title: Text(user.email),
                          subtitle: Text(user.role),
                          leading: CircleAvatar(
                            backgroundColor:
                                user.disabled ? Colors.red : Colors.green,
                            child: Icon(
                              user.disabled ? Icons.block : Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
