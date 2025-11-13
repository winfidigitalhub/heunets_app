import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heunets_app/features/jobs/presentation/screen/add_job_screen.dart';
import 'package:heunets_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:heunets_app/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:heunets_app/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:heunets_app/features/jobs/domain/repository/jobs_repository.dart';
import 'package:heunets_app/core/routing/navigation_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../../../helpers/firebase_mocks.dart';
import '../../../../helpers/mock_services.mocks.dart';
import 'add_job_screen_test.mocks.dart';

@GenerateMocks([JobsRepository])
void main() {
  late MockJobsRepository mockJobsRepository;
  late MockUserService mockUserService;
  late MockImagePicker mockImagePicker;
  late JobsBloc jobsBloc;

  setUpAll(() async {
    // Set up Firebase mocks and wait for initialization to complete
    await FirebaseTestMocks.setupFirebaseMocks();
    // Give Firebase time to initialize completely
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });

  setUp(() {
    mockJobsRepository = MockJobsRepository();
    mockUserService = MockUserService();
    mockImagePicker = MockImagePicker();
    jobsBloc = JobsBloc(jobsRepository: mockJobsRepository);
    
    // Set up default mock behavior for UserService
    when(mockUserService.getUserData()).thenAnswer((_) async => <String, dynamic>{
      'companyName': 'Test Company',
    });
    when(mockUserService.getUserRole()).thenAnswer((_) async => 'employer');
  });

  tearDown(() {
    jobsBloc.close();
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      routes: {
        '/home': (context) => const Scaffold(body: Text('Home')),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => BlocProvider<JobsBloc>.value(
              value: jobsBloc,
              child: child,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Text('Route: ${settings.name}')),
        );
      },
      home: BlocProvider<JobsBloc>.value(
        value: jobsBloc,
        child: child,
      ),
    );
  }

  group('AddJobScreen Widget Tests', () {
    testWidgets('renders screen with app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AddJobScreen(
            userService: mockUserService,
            imagePicker: mockImagePicker,
          ),
        ),
      );

      // Allow time for async operations and handle Firebase errors
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Post a new Job'), findsOneWidget);
      expect(find.text('Create Job'), findsOneWidget);
    });

    testWidgets('displays job image upload section', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AddJobScreen(
            userService: mockUserService,
            imagePicker: mockImagePicker,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Job Image *'), findsOneWidget);
    });

    testWidgets('shows loading indicator when job is being created', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AddJobScreen(
            userService: mockUserService,
            imagePicker: mockImagePicker,
          ),
        ),
      );

      await tester.pump();

      jobsBloc.emit(JobsLoading());

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Create Job button is disabled when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AddJobScreen(
            userService: mockUserService,
            imagePicker: mockImagePicker,
          ),
        ),
      );

      await tester.pump();

      jobsBloc.emit(JobsLoading());

      await tester.pump();

      final createJobButton = find.byType(ElevatedButton);
      expect(createJobButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(createJobButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('displays all required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          AddJobScreen(
            userService: mockUserService,
            imagePicker: mockImagePicker,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Company Name *'), findsOneWidget);
      expect(find.text('Category *'), findsOneWidget);
      expect(find.text('Job Name *'), findsOneWidget);
      expect(find.text('Job Title *'), findsOneWidget);
      expect(find.text('Job Description *'), findsOneWidget);
    });

    testWidgets('handles job creation event', (WidgetTester tester) async {
      const testJobId = 'test-job-id';
      final testDeadline = DateTime.now().add(const Duration(days: 30));

      when(mockJobsRepository.createJob(
        companyName: anyNamed('companyName'),
        jobImagePath: anyNamed('jobImagePath'),
        jobName: anyNamed('jobName'),
        jobTitle: anyNamed('jobTitle'),
        jobDescription: anyNamed('jobDescription'),
        category: anyNamed('category'),
        location: anyNamed('location'),
        amount: anyNamed('amount'),
        prerequisites: anyNamed('prerequisites'),
        skillsNeeded: anyNamed('skillsNeeded'),
        applicationDeadline: anyNamed('applicationDeadline'),
      )).thenAnswer((_) async => testJobId);

      await tester.pumpWidget(
        createTestWidget(
          AddJobScreen(
            userService: mockUserService,
            imagePicker: mockImagePicker,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      jobsBloc.add(CreateJobEvent(
        companyName: 'Test Company',
        jobImagePath: '/test/path.jpg',
        jobName: 'Test Job',
        jobTitle: 'Test Title',
        jobDescription: 'Test Description',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Flutter'],
        applicationDeadline: testDeadline,
      ));

      await tester.pump();

      verify(mockJobsRepository.createJob(
        companyName: 'Test Company',
        jobImagePath: '/test/path.jpg',
        jobName: 'Test Job',
        jobTitle: 'Test Title',
        jobDescription: 'Test Description',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Flutter'],
        applicationDeadline: testDeadline,
      )).called(1);
    });
  });
}
