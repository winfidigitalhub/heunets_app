import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:heunets_app/features/jobs/data/model/job_model.dart';

void main() {
  group('Job Model', () {
    test('fromJson creates Job instance correctly', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 30));
      final createdAt = Timestamp.fromDate(now);
      final applicationDeadline = Timestamp.fromDate(deadline);

      final json = {
        'id': 'job123',
        'companyName': 'Test Company',
        'jobImageUrl': 'https://example.com/image.jpg',
        'userId': 'user123',
        'jobName': 'Software Developer',
        'jobTitle': 'Senior Software Developer',
        'jobDescription': 'We are looking for a senior software developer...',
        'category': 'Technology',
        'location': 'Lagos, Nigeria',
        'amount': 5000.0,
        'prerequisites': ['Bachelor\'s Degree', '5+ years experience'],
        'skillsNeeded': ['Flutter', 'Dart', 'Firebase'],
        'applicationDeadline': applicationDeadline,
        'createdAt': createdAt,
        'applicants': ['applicant1', 'applicant2'],
      };

      final job = Job.fromJson(json);

      expect(job.id, 'job123');
      expect(job.companyName, 'Test Company');
      expect(job.jobImageUrl, 'https://example.com/image.jpg');
      expect(job.userId, 'user123');
      expect(job.jobName, 'Software Developer');
      expect(job.jobTitle, 'Senior Software Developer');
      expect(job.jobDescription, 'We are looking for a senior software developer...');
      expect(job.category, 'Technology');
      expect(job.location, 'Lagos, Nigeria');
      expect(job.amount, 5000.0);
      expect(job.prerequisites, ['Bachelor\'s Degree', '5+ years experience']);
      expect(job.skillsNeeded, ['Flutter', 'Dart', 'Firebase']);
      expect(job.applicationDeadline, deadline);
      expect(job.createdAt, now);
      expect(job.applicants, ['applicant1', 'applicant2']);
    });

    test('fromJson handles null values with defaults', () {
      final json = <String, dynamic>{
        'id': 'job123',
      };

      final job = Job.fromJson(json);

      expect(job.id, 'job123');
      expect(job.companyName, '');
      expect(job.jobImageUrl, '');
      expect(job.userId, '');
      expect(job.jobName, '');
      expect(job.jobTitle, '');
      expect(job.jobDescription, '');
      expect(job.category, 'Other');
      expect(job.location, '');
      expect(job.amount, 0.0);
      expect(job.prerequisites, isEmpty);
      expect(job.skillsNeeded, isEmpty);
      expect(job.applicants, isEmpty);
    });

    test('fromJson handles userPhotoUrl as fallback for jobImageUrl', () {
      final json = {
        'id': 'job123',
        'userPhotoUrl': 'https://example.com/photo.jpg',
      };

      final job = Job.fromJson(json);

      expect(job.jobImageUrl, 'https://example.com/photo.jpg');
    });

    test('toJson converts Job to map correctly', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 30));

      final job = Job(
        id: 'job123',
        companyName: 'Test Company',
        jobImageUrl: 'https://example.com/image.jpg',
        userId: 'user123',
        jobName: 'Software Developer',
        jobTitle: 'Senior Software Developer',
        jobDescription: 'We are looking for a senior software developer...',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree', '5+ years experience'],
        skillsNeeded: ['Flutter', 'Dart', 'Firebase'],
        applicationDeadline: deadline,
        createdAt: now,
        applicants: ['applicant1', 'applicant2'],
      );

      final json = job.toJson();

      expect(json['id'], 'job123');
      expect(json['companyName'], 'Test Company');
      expect(json['jobImageUrl'], 'https://example.com/image.jpg');
      expect(json['userId'], 'user123');
      expect(json['jobName'], 'Software Developer');
      expect(json['jobTitle'], 'Senior Software Developer');
      expect(json['jobDescription'], 'We are looking for a senior software developer...');
      expect(json['category'], 'Technology');
      expect(json['location'], 'Lagos, Nigeria');
      expect(json['amount'], 5000.0);
      expect(json['prerequisites'], ['Bachelor\'s Degree', '5+ years experience']);
      expect(json['skillsNeeded'], ['Flutter', 'Dart', 'Firebase']);
      expect(json['applicationDeadline'], isA<Timestamp>());
      expect(json['createdAt'], isA<Timestamp>());
      expect(json['applicants'], ['applicant1', 'applicant2']);
    });

    test('toMap returns same result as toJson', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 30));

      final job = Job(
        id: 'job123',
        companyName: 'Test Company',
        jobImageUrl: 'https://example.com/image.jpg',
        userId: 'user123',
        jobName: 'Software Developer',
        jobTitle: 'Senior Software Developer',
        jobDescription: 'Description',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Flutter'],
        applicationDeadline: deadline,
        createdAt: now,
      );

      expect(job.toMap(), job.toJson());
    });

    test('Job with empty applicants list', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 30));

      final job = Job(
        id: 'job123',
        companyName: 'Test Company',
        jobImageUrl: 'https://example.com/image.jpg',
        userId: 'user123',
        jobName: 'Software Developer',
        jobTitle: 'Senior Software Developer',
        jobDescription: 'Description',
        category: 'Technology',
        location: 'Lagos, Nigeria',
        amount: 5000.0,
        prerequisites: ['Bachelor\'s Degree'],
        skillsNeeded: ['Flutter'],
        applicationDeadline: deadline,
        createdAt: now,
      );

      expect(job.applicants, isEmpty);
    });

    test('Job round-trip: fromJson -> toJson maintains data integrity', () {
      final now = DateTime.now();
      final deadline = now.add(const Duration(days: 30));
      final createdAt = Timestamp.fromDate(now);
      final applicationDeadline = Timestamp.fromDate(deadline);

      final originalJson = {
        'id': 'job123',
        'companyName': 'Test Company',
        'jobImageUrl': 'https://example.com/image.jpg',
        'userId': 'user123',
        'jobName': 'Software Developer',
        'jobTitle': 'Senior Software Developer',
        'jobDescription': 'We are looking for a senior software developer...',
        'category': 'Technology',
        'location': 'Lagos, Nigeria',
        'amount': 5000.0,
        'prerequisites': ['Bachelor\'s Degree', '5+ years experience'],
        'skillsNeeded': ['Flutter', 'Dart', 'Firebase'],
        'applicationDeadline': applicationDeadline,
        'createdAt': createdAt,
        'applicants': ['applicant1', 'applicant2'],
      };

      final job = Job.fromJson(originalJson);
      final convertedJson = job.toJson();

      expect(convertedJson['id'], originalJson['id']);
      expect(convertedJson['companyName'], originalJson['companyName']);
      expect(convertedJson['jobImageUrl'], originalJson['jobImageUrl']);
      expect(convertedJson['userId'], originalJson['userId']);
      expect(convertedJson['jobName'], originalJson['jobName']);
      expect(convertedJson['jobTitle'], originalJson['jobTitle']);
      expect(convertedJson['jobDescription'], originalJson['jobDescription']);
      expect(convertedJson['category'], originalJson['category']);
      expect(convertedJson['location'], originalJson['location']);
      expect(convertedJson['amount'], originalJson['amount']);
      expect(convertedJson['prerequisites'], originalJson['prerequisites']);
      expect(convertedJson['skillsNeeded'], originalJson['skillsNeeded']);
      expect(convertedJson['applicants'], originalJson['applicants']);
    });
  });
}

