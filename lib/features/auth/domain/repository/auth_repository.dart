import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> login(String email, String password);
  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
    required String employeeBio,
  });
  Future<void> signOut();
}





