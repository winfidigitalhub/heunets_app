# heunets_app

Heunets Job App
A Flutter-based job application platform built with Clean Architecture and BLoC pattern.

🚀 Features
Core Functionality:
Role Based Authentication

Job Posting: Create, edit, and manage job listings

Job Browsing: Browse available job opportunities

Save Jobs: Save Jobs for later

Advanced Search: Filter jobs by category, location, salary, etc.

Application Management: Track applied jobs and status

User Profiles: Employer and job seeker profiles



Technical Features:
Clean Architecture with clear separation of concerns

BLoC state management for predictable state handling

Responsive UI design

Local data persistence

REST API integration

Error handling and loading states

🛠️ Setup Instructions:
Prerequisites:
Flutter SDK (version 3.27.1 or higher)

Dart (version 3.6.0 or higher)

IDE (Android Studio, VS Code, or IntelliJ)



Installation:
Clone the repository:

git clone https://github.com/your-org/heunets-job-app.git

flutter pub get

flutter run



App Overview:
Heunets Job App provides a comprehensive platform for job seekers and employers to connect. The app follows modern development practices with a clean architecture that ensures scalability and maintainability.

Architecture:
The app is structured using Clean Architecture principles with three main layers:

Domain: Business logic and entities

Data: Data sources and repositories

Presentation: UI components and BLoCs

State Management
Using BLoC pattern for predictable state management across all features. Each feature module contains its own BLoCs, events, and states.

Key Screens:

Role Based Authentication

Job Listings with advanced filtering

Job Detail views

Application tracking (Candidates, Saved Jobs)

User profile management

Search and discovery
