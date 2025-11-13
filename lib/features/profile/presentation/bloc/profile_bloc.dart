import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../domain/repository/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
    on<PickImageEvent>(_onPickImage);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final userProfile = await profileRepository.getUserProfile();
      emit(ProfileLoaded(
        username: (userProfile['username'] as String?) ?? '',
        email: (userProfile['email'] as String?) ?? '',
        profileImageUrl: userProfile['profileImageUrl'] as String?,
        employeeBio: userProfile['employeeBio'] as String?,
        companyName: userProfile['companyName'] as String?,
        employerBio: userProfile['employerBio'] as String?,
        userRole: (userProfile['userRole'] as String?) ?? 'employee',
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        await profileRepository.updateProfile(
          event.username,
          event.email,
          event.profileImage,
          employeeBio: event.employeeBio,
          companyName: event.companyName,
          employerBio: event.employerBio,
        );
        add(const LoadUserProfileEvent());
        emit(ProfileUpdated('Profile updated successfully'));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateUserRole(
    UpdateUserRoleEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        await profileRepository.updateUserRole(event.role);
        GlobalBottomNavBar.refreshAll();
        add(const LoadUserProfileEvent());
        emit(ProfileUpdated('Role updated successfully'));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      try {
        final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          emit(currentState.copyWith(profileImage: File(pickedFile.path)));
        }
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }
}


