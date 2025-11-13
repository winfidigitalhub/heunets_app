import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/screen/login_screen.dart';
import '../../features/auth/presentation/screen/signup_screen.dart';
import '../../features/auth/presentation/screen/employer_onboarding_screen.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/jobs/presentation/screen/jobs_screen.dart';
import '../../features/jobs/presentation/screen/add_job_screen.dart';
import '../../features/jobs/presentation/screen/job_details_screen.dart';
import '../../features/candidates/presentation/screen/candidates_screen.dart';
import '../../features/candidates/presentation/bloc/candidates_bloc.dart';
import '../../features/candidates/data/repository/candidates_repository_impl.dart';
import '../../features/jobs/presentation/bloc/jobs_bloc.dart';
import '../../features/jobs/presentation/bloc/jobs_event.dart';
import '../../features/jobs/data/repository/jobs_repository_impl.dart';
import '../../features/jobs/data/model/job_model.dart';
import '../../features/applied_jobs/presentation/screen/applied_jobs_screen.dart';
import '../../features/applied_jobs/presentation/bloc/applied_jobs_bloc.dart';
import '../../features/applied_jobs/data/repository/applied_jobs_repository_impl.dart';
import '../../features/saved_jobs/presentation/screen/saved_jobs_screen.dart';
import '../../features/saved_jobs/presentation/bloc/saved_jobs_bloc.dart';
import '../../features/saved_jobs/data/repository/saved_jobs_repository_impl.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/data/repository/profile_repository_impl.dart';
import 'route_names.dart';

class AppRouter {

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => JobsBloc(
              jobsRepository: JobsRepositoryImpl(),
            )..add(const LoadJobsEvent()),
            child: const JobsScreen(),
          ),
        );

      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthBloc(
              authRepository: AuthRepositoryImpl(),
            ),
            child: const LoginScreen(),
          ),
        );

      case RouteNames.signup:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthBloc(
              authRepository: AuthRepositoryImpl(),
            ),
            child: const SignupScreen(),
          ),
        );

      case RouteNames.appliedJob:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AppliedJobsBloc(
              appliedJobsRepository: AppliedJobsRepositoryImpl(),
            ),
            child: const AppliedJobsScreen(),
          ),
        );

      case RouteNames.savedJob:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => SavedJobsBloc(
              savedJobsRepository: SavedJobsRepositoryImpl(),
            ),
            child: const SavedJobsScreen(),
          ),
        );

      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => ProfileBloc(
              profileRepository: ProfileRepositoryImpl(),
            ),
            child: const ProfileScreen(),
          ),
        );


      case RouteNames.addJob:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => JobsBloc(
              jobsRepository: JobsRepositoryImpl(),
            ),
            child: const AddJobScreen(),
          ),
        );

      case RouteNames.jobDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('job')) {
          return MaterialPageRoute(
            builder: (_) => JobDetailsScreen(
              job: args['job'] as Job,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Job details not available')),
          ),
        );

      case RouteNames.candidates:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteNames.candidates),
          builder: (_) => BlocProvider(
            create: (context) => CandidatesBloc(
              candidatesRepository: CandidatesRepositoryImpl(),
            ),
            child: const CandidatesScreen(),
          ),
        );

      case RouteNames.employerOnboarding:
        return MaterialPageRoute(
          settings: const RouteSettings(name: RouteNames.employerOnboarding),
          builder: (_) => const EmployerOnboardingScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthBloc(
              authRepository: AuthRepositoryImpl(),
            ),
            child: const LoginScreen(),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      RouteNames.home: (context) => BlocProvider(
            create: (context) => JobsBloc(
              jobsRepository: JobsRepositoryImpl(),
            )..add(const LoadJobsEvent()),
            child: const JobsScreen(),
          ),
      RouteNames.login: (context) => BlocProvider(
            create: (context) => AuthBloc(
              authRepository: AuthRepositoryImpl(),
            ),
            child: const LoginScreen(),
          ),
      RouteNames.signup: (context) => BlocProvider(
            create: (context) => AuthBloc(
              authRepository: AuthRepositoryImpl(),
            ),
            child: const SignupScreen(),
          ),
      RouteNames.appliedJob: (context) => BlocProvider(
            create: (context) => AppliedJobsBloc(
              appliedJobsRepository: AppliedJobsRepositoryImpl(),
            ),
            child: const AppliedJobsScreen(),
          ),
      RouteNames.savedJob: (context) => BlocProvider(
            create: (context) => SavedJobsBloc(
              savedJobsRepository: SavedJobsRepositoryImpl(),
            ),
            child: const SavedJobsScreen(),
          ),
      RouteNames.profile: (context) => BlocProvider(
            create: (context) => ProfileBloc(
              profileRepository: ProfileRepositoryImpl(),
            ),
            child: const ProfileScreen(),
          ),
      RouteNames.addJob: (context) => BlocProvider(
            create: (context) => JobsBloc(
              jobsRepository: JobsRepositoryImpl(),
            ),
            child: const AddJobScreen(),
          ),
    };
  }
}

