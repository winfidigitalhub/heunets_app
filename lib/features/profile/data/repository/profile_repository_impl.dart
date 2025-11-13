import 'dart:io';
import '../../domain/repository/profile_repository.dart';
import '../services/profile_services.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileServices _profileServices;

  ProfileRepositoryImpl({ProfileServices? profileServices})
      : _profileServices = profileServices ?? ProfileServices();

  @override
  Future<Map<String, dynamic>> getUserProfile() async {
    return await _profileServices.getUserProfile();
  }

  @override
  Future<void> updateProfile(
    String username,
    String email,
    File? profileImage, {
    String? employeeBio,
    String? companyName,
    String? employerBio,
  }) async {
    await _profileServices.updateProfile(
      username,
      email,
      profileImage,
      employeeBio: employeeBio,
      companyName: companyName,
      employerBio: employerBio,
    );
  }

  @override
  Future<void> updateUserRole(String role) async {
    await _profileServices.updateUserRole(role);
  }
}


