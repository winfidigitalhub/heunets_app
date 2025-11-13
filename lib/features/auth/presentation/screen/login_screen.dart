import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/shared/widgets/custom_top_snackbar.dart';
import '../../../../core/routing/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _passwordVisible = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          NavigationService.navigateToHome();
          CustomTopSnackBar.show(context, 'Login successful! Welcome back.');
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
                      children: [
                        _header(context),
                        _inputField(context),
                        const SizedBox(height: 20),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return _buildLoadingWidget();
                            }
                            return _loginButton();
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
                        _signup(context),
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

  Widget _header(context) {
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

  Widget _inputField(context) {
    return Column(
      children: <Widget>[
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
            return null;
          },
        ),
      ],
    );
  }

  Widget _loginButton() {
    return Container(
      padding: const EdgeInsets.only(top: 3, left: 3),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            context.read<AuthBloc>().add(
                  LoginEvent(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
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
          "Login",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("Don't have an account yet?"),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () {
            NavigationService.navigateToSignup();
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blue.shade700),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
}

