import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/auth_repository.dart';
import '../services/auth_services.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthServices _authServices;

  AuthRepositoryImpl({AuthServices? authServices})
      : _authServices = authServices ?? AuthServices();

  @override
  Future<User?> login(String email, String password) async {
    return await _authServices.login(email, password);
  }

  @override
  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
    required String role,
    required String employeeBio,
  }) async {
    return await _authServices.registerUser(
      username: username,
      email: email,
      password: password,
      role: role,
      employeeBio: employeeBio,
    );
  }

  @override
  Future<void> signOut() async {
    await _authServices.signOut();
  }
}





