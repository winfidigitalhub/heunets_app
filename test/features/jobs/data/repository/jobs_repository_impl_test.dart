import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:heunets_app/features/jobs/data/repository/jobs_repository_impl.dart';
import 'package:heunets_app/features/jobs/data/services/jobs_services.dart';
import 'package:heunets_app/features/jobs/data/model/job_model.dart';
import 'package:matcher/matcher.dart';

import 'jobs_repository_impl_test.mocks.dart';

@GenerateMocks([JobsServices])
void main() {
  late MockJobsServices mockJobsServices;
  late JobsRepositoryImpl jobsRepositoryImpl;

  setUp(() {
    mockJobsServices = MockJobsServices();
    jobsRepositoryImpl = JobsRepositoryImpl(jobsServices: mockJobsServices);
  });

  group('JobsRepositoryImpl - createJob', () {
    test('creates job with image path', () async {
      const testJobId = 'test-job-id-123';
      const imagePath = '/path/to/image.jpg';
      final testApplicationDeadline = DateTime.now().add(const Duration(days: 30));

      when(mockJobsServices.createJob(
        companyName: anyNamed('companyName'),
        jobImage: anyNamed('jobImage'),
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

      final result = await jobsRepositoryImpl.createJob(
        companyName: 'Test Company',
        jobImagePath: imagePath,
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

      expect(result, testJobId);
      verify(mockJobsServices.createJob(
        companyName: 'Test Company',
        jobImage: argThat(isA<File>(), named: 'jobImage'),
        jobName: 'Software Developer',
        jobTitle: 'Senior Software Developer',
        jobDescription: 'We are looking for a senior software developer...',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree', '5+ years experience'],
        skillsNeeded: ['Flutter', 'Dart', 'Firebase'],
        applicationDeadline: testApplicationDeadline,
      )).called(1);
    });

    test('creates job without image path', () async {
      const testJobId = 'test-job-id-123';
      final testApplicationDeadline = DateTime.now().add(const Duration(days: 30));

      when(mockJobsServices.createJob(
        companyName: anyNamed('companyName'),
        jobImage: anyNamed('jobImage'),
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

      final result = await jobsRepositoryImpl.createJob(
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

      expect(result, testJobId);
      verify(mockJobsServices.createJob(
        companyName: 'Test Company',
        jobImage: null,
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
    });

    test('creates job with empty image path string', () async {
      const testJobId = 'test-job-id-123';
      final testApplicationDeadline = DateTime.now().add(const Duration(days: 30));

      when(mockJobsServices.createJob(
        companyName: anyNamed('companyName'),
        jobImage: anyNamed('jobImage'),
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

      final result = await jobsRepositoryImpl.createJob(
        companyName: 'Test Company',
        jobImagePath: '',
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

      expect(result, testJobId);
      verify(mockJobsServices.createJob(
        companyName: 'Test Company',
        jobImage: null,
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
    });

    test('throws error when createJob fails', () async {
      final testApplicationDeadline = DateTime.now().add(const Duration(days: 30));

      when(mockJobsServices.createJob(
        companyName: anyNamed('companyName'),
        jobImage: anyNamed('jobImage'),
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

      expect(
        () => jobsRepositoryImpl.createJob(
          companyName: 'Test Company',
          jobImagePath: '/path/to/image.jpg',
          jobName: 'Software Developer',
          jobTitle: 'Senior Software Developer',
          jobDescription: 'Description',
          category: 'Technology',
          location: 'Lagos, Nigeria',
          amount: 5000.0,
          prerequisites: ['Bachelor\'s Degree'],
          skillsNeeded: ['Flutter'],
          applicationDeadline: testApplicationDeadline,
        ),
        throwsException,
      );
    });
  });

  group('JobsRepositoryImpl - getJobs', () {
    test('returns list of jobs', () async {
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

      when(mockJobsServices.fetchJobs()).thenAnswer((_) async => testJobs);

      final result = await jobsRepositoryImpl.getJobs();

      expect(result, testJobs);
      expect(result.length, 2);
      verify(mockJobsServices.fetchJobs()).called(1);
    });

    test('returns empty list when no jobs exist', () async {
      when(mockJobsServices.fetchJobs()).thenAnswer((_) async => <Job>[]);

      final result = await jobsRepositoryImpl.getJobs();

      expect(result, isEmpty);
      verify(mockJobsServices.fetchJobs()).called(1);
    });

    test('throws error when getJobs fails', () async {
      when(mockJobsServices.fetchJobs()).thenThrow(Exception('Failed to fetch jobs'));

      expect(() => jobsRepositoryImpl.getJobs(), throwsException);
    });
  });
}

