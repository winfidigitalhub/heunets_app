import 'package:cloud_firestore/cloud_firestore.dart';

class Candidate {
  final String userId;
  final String username;
  final String email;
  final String? profileImageUrl;
  final List<String> appliedJobIds; // List of job IDs the candidate applied to
  final DateTime? createdAt;

  Candidate({
    required this.userId,
    required this.username,
    required this.email,
    this.profileImageUrl,
    required this.appliedJobIds,
    this.createdAt,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      userId: (json['userId'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      profileImageUrl: json['profileImageUrl'] as String?,
      appliedJobIds: List<String>.from((json['appliedJobIds'] as List<dynamic>?) ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'appliedJobIds': appliedJobIds,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}

