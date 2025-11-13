import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:heunets_app/features/jobs/presentation/bloc/jobs_bloc.dart';
import 'package:heunets_app/features/jobs/presentation/bloc/jobs_event.dart';
import 'package:heunets_app/features/jobs/presentation/bloc/jobs_state.dart';
import 'package:heunets_app/features/jobs/domain/repository/jobs_repository.dart';
import 'package:heunets_app/features/jobs/data/model/job_model.dart';

import 'jobs_bloc_test.mocks.dart';

@GenerateMocks([JobsRepository])
void main() {
  late MockJobsRepository mockJobsRepository;
  late JobsBloc jobsBloc;

  setUp(() {
    mockJobsRepository = MockJobsRepository();
    jobsBloc = JobsBloc(jobsRepository: mockJobsRepository);
  });

  tearDown(() {
    jobsBloc.close();
  });

  group('JobsBloc - CreateJobEvent', () {
    const testJobId = 'test-job-id-123';
    final testApplicationDeadline = DateTime.now().add(const Duration(days: 30));
    final testCreateJobEvent = CreateJobEvent(
      companyName: 'Test Company',
      jobImagePath: '/path/to/image.jpg',
      jobName: 'Software Developer',
      jobTitle: 'Senior Software Developer',
      jobDescription: 'We are looking for a senior software developer...',
      category: 'Technology',
      location: 'Lagos, Nigeria',
      amount: 5000.0,
      prerequisites: ['Bachelor\'s Degree', '5+ years experience'],
      skillsNeeded: ['Flutter', 'Dart', 'Firebase'],
      applicationDeadline: testApplicationDeadline,
    );

    test('initial state is JobsInitial', () {
      expect(jobsBloc.state, isA<JobsInitial>());
    });

    blocTest<JobsBloc, JobsState>(
      'emits [JobsLoading, JobCreated] when CreateJobEvent is successful',
      build: () {
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
        return jobsBloc;
      },
      act: (bloc) => bloc.add(testCreateJobEvent),
      expect: () => [
        isA<JobsLoading>(),
        isA<JobCreated>().having((s) => s.jobId, 'jobId', testJobId),
      ],
      verify: (_) {
        verify(mockJobsRepository.createJob(
          companyName: testCreateJobEvent.companyName,
          jobImagePath: testCreateJobEvent.jobImagePath,
          jobName: testCreateJobEvent.jobName,
          jobTitle: testCreateJobEvent.jobTitle,
          jobDescription: testCreateJobEvent.jobDescription,
          category: testCreateJobEvent.category,
          location: testCreateJobEvent.location,
          amount: testCreateJobEvent.amount,
          prerequisites: testCreateJobEvent.prerequisites,
          skillsNeeded: testCreateJobEvent.skillsNeeded,
          applicationDeadline: testCreateJobEvent.applicationDeadline,
        )).called(1);
      },
    );

    blocTest<JobsBloc, JobsState>(
      'emits [JobsLoading, JobsError] when CreateJobEvent fails',
      build: () {
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
        )).thenThrow(Exception('Failed to create job'));
        return jobsBloc;
      },
      act: (bloc) => bloc.add(testCreateJobEvent),
      expect: () => [
        isA<JobsLoading>(),
        isA<JobsError>().having((s) => s.message, 'message', contains('Failed to create job')),
      ],
    );

    blocTest<JobsBloc, JobsState>(
      'creates job without image path',
      build: () {
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
        return jobsBloc;
      },
      act: (bloc) {
        final event = CreateJobEvent(
          companyName: 'Test Company',
          jobImagePath: null,
          jobName: 'Software Developer',
          jobTitle: 'Senior Software Developer',
          jobDescription: 'We are looking for a senior software developer...',
          category: 'Technology',
          location: 'Lagos, Nigeria',
          amount: 5000.0,
          prerequisites: ['Bachelor\'s Degree'],
          skillsNeeded: ['Flutter'],
          applicationDeadline: testApplicationDeadline,
        );
        bloc.add(event);
      },
      expect: () => [
        isA<JobsLoading>(),
        isA<JobCreated>().having((s) => s.jobId, 'jobId', testJobId),
      ],
      verify: (_) {
        verify(mockJobsRepository.createJob(
          companyName: 'Test Company',
          jobImagePath: null,
          jobName: 'Software Developer',
          jobTitle: 'Senior Software Developer',
          jobDescription: 'We are looking for a senior software developer...',
          category: 'Technology',
          location: 'Lagos, Nigeria',
          amount: 5000.0,
          prerequisites: ['Bachelor\'s Degree'],
          skillsNeeded: ['Flutter'],
          applicationDeadline: testApplicationDeadline,
        )).called(1);
      },
    );
  });

  group('JobsBloc - LoadJobsEvent', () {
    final testJobs = [
      Job(
        id: 'job1',
        companyName: 'Company 1',
        jobImageUrl: 'https://example.com/image1.jpg',
        userId: 'user1',
        jobName: 'Developer',
        jobTitle: 'Senior Developer',
        jobDescription: 'Description 1',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Flutter'],
        applicationDeadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      ),
      Job(
        id: 'job2',
        companyName: 'Company 2',
        jobImageUrl: 'https://example.com/image2.jpg',
        userId: 'user2',
        jobName: 'Designer',
        jobTitle: 'UI/UX Designer',
        jobDescription: 'Description 2',
        category: 'Design',
        location: 'Abuja, Nigeria',
        amount: 4000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Figma'],
        applicationDeadline: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<JobsBloc, JobsState>(
      'emits [JobsLoading, JobsLoaded] when LoadJobsEvent is successful',
      build: () {
        when(mockJobsRepository.getJobs()).thenAnswer((_) async => testJobs);
        return jobsBloc;
      },
      act: (bloc) => bloc.add(const LoadJobsEvent()),
      expect: () => [
        isA<JobsLoading>(),
        isA<JobsLoaded>()
            .having((s) => s.jobs.length, 'jobs length', 2)
            .having((s) => s.selectedCategory, 'selectedCategory', 'All'),
      ],
    );

    blocTest<JobsBloc, JobsState>(
      'emits [JobsLoading, JobsError] when LoadJobsEvent fails',
      build: () {
        when(mockJobsRepository.getJobs()).thenThrow(Exception('Failed to load jobs'));
        return jobsBloc;
      },
      act: (bloc) => bloc.add(const LoadJobsEvent()),
      expect: () => [
        isA<JobsLoading>(),
        isA<JobsError>().having((s) => s.message, 'message', contains('Failed to load jobs')),
      ],
    );
  });

  group('JobsBloc - FilterJobsByCategoryEvent', () {
    final testJobs = [
      Job(
        id: 'job1',
        companyName: 'Company 1',
        jobImageUrl: 'https://example.com/image1.jpg',
        userId: 'user1',
        jobName: 'Developer',
        jobTitle: 'Senior Developer',
        jobDescription: 'Description 1',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Flutter'],
        applicationDeadline: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      ),
      Job(
        id: 'job2',
        companyName: 'Company 2',
        jobImageUrl: 'https://example.com/image2.jpg',
        userId: 'user2',
        jobName: 'Designer',
        jobTitle: 'UI/UX Designer',
        jobDescription: 'Description 2',
        category: 'Design',
        location: 'Abuja, Nigeria',
        amount: 4000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Figma'],
        applicationDeadline: DateTime.now().add(const Duration(days: 45)),
        createdAt: DateTime.now(),
      ),
    ];

    blocTest<JobsBloc, JobsState>(
      'filters jobs by category when FilterJobsByCategoryEvent is added',
      build: () {
        when(mockJobsRepository.getJobs()).thenAnswer((_) async => testJobs);
        return jobsBloc;
      },
      act: (bloc) {
        bloc.add(const LoadJobsEvent());
        bloc.add(const FilterJobsByCategoryEvent('Technology'));
      },
      expect: () => [
        isA<JobsLoading>(),
        isA<JobsLoaded>().having((s) => s.selectedCategory, 'selectedCategory', 'All'),
        isA<JobsLoaded>().having((s) => s.selectedCategory, 'selectedCategory', 'Technology'),
      ],
    );
  });
}

