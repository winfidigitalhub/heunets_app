import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String companyName;
  final String jobImageUrl;
  final String userId; // ID of user who added the job
  final String jobName;
  final String jobTitle;
  final String jobDescription;
  final String category;
  final String location;
  final double amount;
  final List<String> prerequisites;
  final List<String> skillsNeeded;
  final DateTime applicationDeadline;
  final DateTime createdAt;
  final List<String> applicants; // List of user IDs who applied

  Job({
    required this.id,
    required this.companyName,
    required this.jobImageUrl,
    required this.userId,
    required this.jobName,
    required this.jobTitle,
    required this.jobDescription,
    required this.category,
    required this.location,
    required this.amount,
    required this.prerequisites,
    required this.skillsNeeded,
    required this.applicationDeadline,
    required this.createdAt,
    this.applicants = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: (json['id'] as String?) ?? '',
      companyName: (json['companyName'] as String?) ?? '',
      jobImageUrl: (json['jobImageUrl'] as String?) ?? (json['userPhotoUrl'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      jobName: (json['jobName'] as String?) ?? '',
      jobTitle: (json['jobTitle'] as String?) ?? '',
      jobDescription: (json['jobDescription'] as String?) ?? '',
      category: (json['category'] as String?) ?? 'Other',
      location: (json['location'] as String?) ?? '',
      amount: ((json['amount'] as num?) ?? 0.0).toDouble(),
      prerequisites: List<String>.from((json['prerequisites'] as List<dynamic>?) ?? []),
      skillsNeeded: List<String>.from((json['skillsNeeded'] as List<dynamic>?) ?? []),
      applicationDeadline: (json['applicationDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applicants: List<String>.from((json['applicants'] as List<dynamic>?) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'jobImageUrl': jobImageUrl,
      'userId': userId,
      'jobName': jobName,
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'category': category,
      'location': location,
      'amount': amount,
      'prerequisites': prerequisites,
      'skillsNeeded': skillsNeeded,
      'applicationDeadline': Timestamp.fromDate(applicationDeadline),
      'createdAt': Timestamp.fromDate(createdAt),
      'applicants': applicants,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}

