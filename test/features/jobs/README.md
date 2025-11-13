# Jobs Feature Tests

## Overview
This directory contains tests for the jobs feature, including BLoC tests, repository tests, model tests, and widget tests.

## Test Files

### BLoC Tests
- `test/features/jobs/presentation/bloc/jobs_bloc_test.dart`
  - Tests for `JobsBloc` including job creation, loading jobs, and filtering by category
  - Uses `mockito` for mocking `JobsRepository`
  - Uses `bloc_test` for testing BLoC events and states

### Repository Tests
- `test/features/jobs/data/repository/jobs_repository_impl_test.dart`
  - Tests for `JobsRepositoryImpl` including job creation and fetching jobs
  - Uses `mockito` for mocking `JobsServices`

### Model Tests
- `test/features/jobs/data/model/job_model_test.dart`
  - Tests for `Job` model serialization/deserialization
  - Tests null handling and default values

### Widget Tests
- `test/features/jobs/presentation/screen/add_job_screen_test.dart`
  - Tests for `AddJobScreen` widget
  - Tests UI rendering, form fields, and job creation events
  - Uses Firebase mocks for handling Firebase initialization

## Running Tests

### Run all job tests
```bash
flutter test test/features/jobs/
```

### Run specific test file
```bash
flutter test test/features/jobs/presentation/bloc/jobs_bloc_test.dart
```

### Run with coverage
```bash
flutter test --coverage test/features/jobs/
```

## Firebase Mocking

Widget tests use Firebase method channel mocks to avoid actual Firebase initialization. The `FirebaseTestMocks` class in `test/helpers/firebase_mocks.dart` sets up method channel handlers for:
- Firebase Core
- Cloud Firestore
- Firebase Auth
- Firebase Storage
- Image Picker

## Notes

- Widget tests may require Firebase to be properly mocked using method channels
- Some widget tests may fail if Firebase services are accessed before initialization
- BLoC and repository tests are isolated and don't require Firebase mocks
