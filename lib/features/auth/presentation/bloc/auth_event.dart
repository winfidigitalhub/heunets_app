import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final String employeeBio;

  const RegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    required this.employeeBio,
  });

  @override
  List<Object> get props => [username, email, password, confirmPassword, role, employeeBio];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}





