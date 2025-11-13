import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(AuthError('Please enter both email and password.'));
        return;
      }

      final user = await authRepository.login(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Login failed. Please check your credentials.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (event.username.isEmpty ||
          event.email.isEmpty ||
          event.password.isEmpty ||
          event.confirmPassword.isEmpty) {
        emit(AuthError('Please fill in all fields.'));
        return;
      }

      if (event.password != event.confirmPassword) {
        emit(AuthError('Passwords do not match.'));
        return;
      }

      final user = await authRepository.registerUser(
        username: event.username,
        email: event.email,
        password: event.password,
        role: event.role,
        employeeBio: event.employeeBio,
      );

      if (user != null) {
        emit(AuthAuthenticated(user, role: event.role));
      } else {
        emit(AuthError('Registration failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.signOut();
      emit(AuthSignedOut());
    } catch (e) {
      emit(AuthError('Sign out failed: ${e.toString()}'));
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is invalid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}





