import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';
import '../bloc/candidates_bloc.dart';
import '../bloc/candidates_event.dart';
import '../bloc/candidates_state.dart';
import '../../../jobs/data/services/jobs_services.dart';
import '../../../jobs/data/model/job_model.dart';
import '../widget/job_candidates_card.dart';
import '../screen/candidate_profile_screen.dart';
import '../../data/model/candidate_model.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  final JobsServices _jobsServices = JobsServices();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadCandidates();
      }
    });
  }

  Future<void> _loadCandidates() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<CandidatesBloc>().add(LoadCandidatesEvent(user.uid));
    }
  }

  Future<Job?> _getJobById(String jobId) async {
    try {
      return await _jobsServices.getJobById(jobId);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, List<Candidate>>> _groupCandidatesByJob(
      List<Candidate> candidates) async {
    Map<String, List<Candidate>> jobCandidatesMap = {};

    for (var candidate in candidates) {
      for (var jobId in candidate.appliedJobIds) {
        if (!jobCandidatesMap.containsKey(jobId)) {
          jobCandidatesMap[jobId] = [];
        }
        if (!jobCandidatesMap[jobId]!
            .any((c) => c.userId == candidate.userId)) {
          jobCandidatesMap[jobId]!.add(candidate);
        }
      }
    }

    return jobCandidatesMap;
  }

  void _navigateToCandidateProfile(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CandidateProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidates'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: BlocBuilder<CandidatesBloc, CandidatesState>(
        builder: (context, state) {
          if (state is CandidatesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          } else if (state is CandidatesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCandidates,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is CandidatesLoaded) {
            final candidates = state.candidates;

            if (candidates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No candidates yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Candidates who apply to your jobs will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return FutureBuilder<Map<String, List<Candidate>>>(
              future: _groupCandidatesByJob(candidates),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No job applications yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final jobCandidatesMap = snapshot.data!;
                final jobIds = jobCandidatesMap.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobIds.length,
                  itemBuilder: (context, index) {
                    final jobId = jobIds[index];
                    final jobCandidates = jobCandidatesMap[jobId]!;

                    return FutureBuilder<Job?>(
                      future: _getJobById(jobId),
                      builder: (context, jobSnapshot) {
                        if (jobSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            ),
                          );
                        }

                        final job = jobSnapshot.data;
                        if (job == null) {
                          return const SizedBox.shrink();
                        }

                        return JobCandidatesCard(
                          job: job,
                          candidates: jobCandidates,
                          onViewCandidateProfile: _navigateToCandidateProfile,
                        );
                      },
                    );
                  },
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: const GlobalBottomNavBar(),
    );
  }
}
