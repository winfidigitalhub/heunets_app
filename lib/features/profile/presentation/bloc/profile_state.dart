import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String username;
  final String email;
  final String? profileImageUrl;
  final File? profileImage;
  final String? employeeBio;
  final String? companyName;
  final String? employerBio;
  final String userRole;

  const ProfileLoaded({
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.profileImage,
    this.employeeBio,
    this.companyName,
    this.employerBio,
    this.userRole = 'employee',
  });

  @override
  List<Object> get props => [
        username,
        email,
        profileImageUrl ?? '',
        profileImage ?? '',
        employeeBio ?? '',
        companyName ?? '',
        employerBio ?? '',
        userRole,
      ];

  ProfileLoaded copyWith({
    String? username,
    String? email,
    String? profileImageUrl,
    File? profileImage,
    String? employeeBio,
    String? companyName,
    String? employerBio,
    String? userRole,
  }) {
    return ProfileLoaded(
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImage: profileImage ?? this.profileImage,
      employeeBio: employeeBio ?? this.employeeBio,
      companyName: companyName ?? this.companyName,
      employerBio: employerBio ?? this.employerBio,
      userRole: userRole ?? this.userRole,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileUpdated extends ProfileState {
  final String message;

  const ProfileUpdated(this.message);

  @override
  List<Object> get props => [message];
}


