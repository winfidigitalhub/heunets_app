import 'dart:io';

abstract class ProfileRepository {
  Future<Map<String, dynamic>> getUserProfile();
  Future<void> updateProfile(
    String username,
    String email,
    File? profileImage, {
    String? employeeBio,
    String? companyName,
    String? employerBio,
  });
  Future<void> updateUserRole(String role);
}


