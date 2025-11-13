import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/shared/widgets/custom_top_snackbar.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../../core/routing/route_names.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _employeeBioController = TextEditingController();
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _selectedRole = 'employee'; // Default to employee
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _slideAnimationController.forward();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _employeeBioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.role == 'employer') {
            // Navigate to employer onboarding screen
            NavigationService.pushNamed(RouteNames.employerOnboarding);
            CustomTopSnackBar.show(context, 'Registration successful! Please complete your profile.');
          } else {
            // Navigate to home for employees
            NavigationService.navigateToHome();
            CustomTopSnackBar.show(context, 'Registration successful! Welcome to Heunets.');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.shade100,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _header(),
                        _inputField(),
                        const SizedBox(height: 20),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return _buildLoadingWidget();
                            }
                            return _signupButton();
                          },
                        ),
                        const SizedBox(height: 10),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthError) {
                              return _buildErrorWidget(state.message);
                            }
                            return Container();
                          },
                        ),
                        _loginLink(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 40.0),
        Image.asset(
          'assets/images/heunets_logo.jpeg',
          height: 130,
          width: 130,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        const Text(
          "Easily Find your Next Hire Or Permenant Job.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _signupButton() {
    return Container(
      padding: const EdgeInsets.only(top: 3, left: 3),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<AuthBloc>().add(
                  RegisterEvent(
                    username: _usernameController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    confirmPassword: _confirmPasswordController.text.trim(),
                  role: _selectedRole,
                  employeeBio: _employeeBioController.text.trim(),
                ),
                );
          }
        },
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.only(
            right: 70,
            left: 70,
            top: 10,
            bottom: 10,
          ),
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.orange.withOpacity(0.4),
        ),
        child: const Text(
          "Sign up",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _inputField() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        TextFormField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: "Username",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.8),
            filled: true,
            prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
            errorMaxLines: 2,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.trim().length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (value.trim().length > 20) {
              return 'Username must be less than 20 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
              return 'Username can only contain letters, numbers, and underscore';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Email",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.8),
            filled: true,
            prefixIcon: Icon(Icons.email, color: Colors.blue.shade700),
            errorMaxLines: 2,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.8),
            filled: true,
            prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
            suffixIcon: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.orange.shade700,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            errorMaxLines: 3,
          ),
          obscureText: !_passwordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return 'Password must contain at least one lowercase letter';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Password must contain at least one number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            hintText: "Confirm Password",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade800),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.8),
            filled: true,
            prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
            suffixIcon: IconButton(
              icon: Icon(
                _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.orange.shade700,
              ),
              onPressed: () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
            errorMaxLines: 2,
          ),
          obscureText: !_confirmPasswordVisible,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _employeeBioController,
          decoration: InputDecoration(
            labelText: 'Bio',
            hintText: 'Tell us about yourself',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.8),
            filled: true,
            prefixIcon: Icon(Icons.description, color: Colors.blue.shade700),
            errorMaxLines: 2,
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Bio is required';
            }
            if (value.trim().length < 10) {
              return 'Bio must be at least 10 characters';
            }
            if (value.trim().length > 500) {
              return 'Bio must be less than 500 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _roleSelection(),
      ],
    );
  }

  Widget _roleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildRoleOption(
                title: 'Job Seeker',
                icon: Icons.person_outline,
                value: 'employee',
                isSelected: _selectedRole == 'employee',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRoleOption(
                title: 'Employer',
                icon: Icons.business,
                value: 'employer',
                isSelected: _selectedRole == 'employer',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleOption({
    required String title,
    required IconData icon,
    required String value,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
          // Revalidate form when role changes
          _formKey.currentState?.validate();
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.orange.shade700 
                : Colors.blue.shade200,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? Colors.orange.shade700 
                  : Colors.blue.shade600,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                    ? Colors.orange.shade700 
                    : Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return SizedBox(
      height: 40.0,
      width: 40.0,
      child: CircularProgressIndicator(
        color: Colors.orange.shade700,
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        error,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _loginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Already have an account?"),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            NavigationService.pop();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blue.shade700),
          ),
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

