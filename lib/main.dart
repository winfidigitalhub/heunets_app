import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heunets_app/core/shared/theme/app_theme.dart';
import 'package:heunets_app/core/routing/app_router.dart';
import 'package:heunets_app/core/routing/navigation_service.dart';
import 'package:heunets_app/features/auth/presentation/screen/login_screen.dart';
import 'package:heunets_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:heunets_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:heunets_app/core/routing/route_names.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: AuthRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Heunets App',
        onGenerateRoute: AppRouter.generateRoute,
        routes: AppRouter.getRoutes(),
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // User is not signed in, reset navigation flag
      if (_hasNavigated) {
        setState(() {
          _hasNavigated = false;
        });
      }
      return;
    }
    
    if (!mounted || _hasNavigated) return;
    
    // Navigate immediately - no need to load role since both go to home
    // Use a small delay to ensure the navigator is ready
    await Future<void>.delayed(const Duration(milliseconds: 50));
    
    if (!mounted || _hasNavigated) return;
    
    setState(() {
      _hasNavigated = true;
    });
    
    // Navigate to All Jobs (home) for both employers and employees
    // This is the default active tab for both roles
    // Ensure navigation happens on the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NavigationService.pushAndRemoveUntil(RouteNames.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            // User is not signed in - reset navigation flag
            if (_hasNavigated) {
              // Reset the flag
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _hasNavigated = false;
                  });
                  // Clear navigation stack and go to login
                  NavigationService.pushAndRemoveUntil(RouteNames.login);
                }
              });
            }
            
            // Show login screen
            return BlocProvider(
              create: (context) => AuthBloc(
                authRepository: AuthRepositoryImpl(),
              ),
              child: const LoginScreen(),
            );
          } else {
            // User is signed in - check if we need to navigate
            if (!_hasNavigated) {
              _checkAuthAndNavigate();
            }
            // Show a blank white screen while navigation happens
            // This prevents any flash or loading indicator
            return const Scaffold(
              backgroundColor: Colors.white,
              body: SizedBox.shrink(),
            );
          }
        }

        // Show blank screen while checking authentication state
        return const Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox.shrink(),
        );
      },
    );
  }
}
