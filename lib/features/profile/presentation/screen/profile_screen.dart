import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/shared/widgets/custom_top_snackbar.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';
import '../../../../core/shared/services/user_service.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../../core/routing/route_names.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _employeeBioController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _employerBioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(const LoadUserProfileEvent());
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _employeeBioController.dispose();
    _companyNameController.dispose();
    _employerBioController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Clear the user service cache first
      UserService.clearCache();
      
      // Try to get AuthBloc from context
      try {
        final authBloc = context.read<AuthBloc>();
        // Dispatch sign out event
        authBloc.add(const SignOutEvent());
      } catch (e) {
        // If AuthBloc is not available in context, sign out directly from Firebase
        await FirebaseAuth.instance.signOut();
      }
      
      // Wait a moment for the sign out to complete
      await Future<void>.delayed(const Duration(milliseconds: 150));
      
      // Force navigation to login screen
      if (mounted) {
        NavigationService.pushAndRemoveUntil(RouteNames.login);
      }
    } catch (e) {
      // Fallback: Sign out directly from Firebase
      try {
        await FirebaseAuth.instance.signOut();
        UserService.clearCache();
        if (mounted) {
          NavigationService.pushAndRemoveUntil(RouteNames.login);
        }
      } catch (firebaseError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    Icon icon, {
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade800),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.blue.shade700,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.blue.shade700,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.blue.shade700,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        prefixIcon: icon,
      ),
    );
  }

  Widget _buildProfileImage(String? profileImageUrl, File? profileImage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundColor: Colors.orange.withOpacity(0.2),
          child: profileImage != null
              ? ClipOval(
                  child: Image.file(
                    profileImage,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                )
              : profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profileImageUrl,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 140,
                          );
                        },
                      ),
                    )
                  : ClipOval(
                      child: Image.asset(
                        'assets/images/user.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              context.read<ProfileBloc>().add(const PickImageEvent());
            },
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.camera_alt,
                size: 25,
                color: Colors.deepOrangeAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          CustomTopSnackBar.show(context, state.message);
        } else if (state is ProfileError) {
          CustomTopSnackBar.show(context, 'Error: ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.blue.shade50,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrangeAccent,
                ),
              );
            } else if (state is ProfileLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _nameController.text != state.username) {
                  _nameController.text = state.username;
                }
                if (mounted && _emailController.text != state.email) {
                  _emailController.text = state.email;
                }
                if (mounted && _employeeBioController.text != (state.employeeBio ?? '')) {
                  _employeeBioController.text = state.employeeBio ?? '';
                }
                if (mounted && _companyNameController.text != (state.companyName ?? '')) {
                  _companyNameController.text = state.companyName ?? '';
                }
                if (mounted && _employerBioController.text != (state.employerBio ?? '')) {
                  _employerBioController.text = state.employerBio ?? '';
                }
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildProfileImage(state.profileImageUrl, state.profileImage),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.userRole == 'employer' 
                                    ? 'Switch to Job Seeker' 
                                    : 'Switch to Employer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.userRole == 'employer' ? 'Currently: Employer' : 'Currently: Job Seeker',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: state.userRole == 'employer',
                            onChanged: (value) {
                              final newRole = value ? 'employer' : 'employee';
                              context.read<ProfileBloc>().add(
                                    UpdateUserRoleEvent(role: newRole),
                                  );
                              // Immediately refresh bottom nav bar
                              GlobalBottomNavBar.refreshAll();
                            },
                            activeColor: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _nameController,
                      'Name',
                      const Icon(Icons.person, color: Colors.deepOrangeAccent),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _emailController,
                      'Email',
                      const Icon(Icons.email, color: Colors.deepOrangeAccent),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    // Employee Bio (shown for all users)
                    _buildTextField(
                      _employeeBioController,
                      'Employee Bio',
                      const Icon(Icons.description, color: Colors.deepOrangeAccent),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    // Company Name (shown for employers)
                    if (state.userRole == 'employer') ...[
                      _buildTextField(
                        _companyNameController,
                        'Company Name',
                        const Icon(Icons.business, color: Colors.deepOrangeAccent),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Employer Bio (shown for employers)
                    if (state.userRole == 'employer') ...[
                      _buildTextField(
                        _employerBioController,
                        'Employer Bio',
                        const Icon(Icons.description, color: Colors.deepOrangeAccent),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                              UpdateProfileEvent(
                                username: _nameController.text,
                                email: _emailController.text,
                                profileImage: state.profileImage,
                                employeeBio: _employeeBioController.text.trim().isEmpty
                                    ? null
                                    : _employeeBioController.text.trim(),
                                companyName: state.userRole == 'employer' &&
                                        _companyNameController.text.trim().isNotEmpty
                                    ? _companyNameController.text.trim()
                                    : null,
                                employerBio: state.userRole == 'employer' &&
                                        _employerBioController.text.trim().isNotEmpty
                                    ? _employerBioController.text.trim()
                                    : null,
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 70,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              );
            } else if (state is ProfileError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepOrangeAccent,
              ),
            );
          },
        ),
        bottomNavigationBar: const GlobalBottomNavBar(),
      ),
    );
  }
}


