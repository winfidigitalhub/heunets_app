import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfileEvent extends ProfileEvent {
  const LoadUserProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String username;
  final String email;
  final File? profileImage;
  final String? employeeBio;
  final String? companyName;
  final String? employerBio;

  const UpdateProfileEvent({
    required this.username,
    required this.email,
    this.profileImage,
    this.employeeBio,
    this.companyName,
    this.employerBio,
  });

  @override
  List<Object> get props => [
        username,
        email,
        profileImage ?? '',
        employeeBio ?? '',
        companyName ?? '',
        employerBio ?? '',
      ];
}

class UpdateUserRoleEvent extends ProfileEvent {
  final String role;

  const UpdateUserRoleEvent({required this.role});

  @override
  List<Object> get props => [role];
}

class PickImageEvent extends ProfileEvent {
  const PickImageEvent();
}


