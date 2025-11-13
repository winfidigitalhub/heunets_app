import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../applied_jobs/data/services/applied_jobs_services.dart';
import '../../../saved_jobs/data/services/saved_jobs_services.dart';
import '../../data/model/job_model.dart';
import '../../../../core/shared/widgets/custom_top_snackbar.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool isSaved = false;
  bool isApplied = false;
  bool isCheckingStatus = true;
  bool isApplying = false;
  final SavedJobsServices savedJobsServices = SavedJobsServices();
  final AppliedJobsServices appliedJobsServices = AppliedJobsServices();

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      isCheckingStatus = true;
    });

    await Future.wait([
      _checkIfSaved(),
      _checkIfApplied(),
    ]);

    if (mounted) {
      setState(() {
        isCheckingStatus = false;
      });
    }
  }

  Future<void> _checkIfSaved() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      DocumentSnapshot savedJobsSnapshot = await FirebaseFirestore.instance
          .collection('saved_jobs')
          .doc(userId)
          .get();

      if (savedJobsSnapshot.exists) {
        final Map<String, dynamic> savedJobsData = savedJobsSnapshot.data() as Map<String, dynamic>;
        if (savedJobsData.containsKey('jobs')) {
          final List<dynamic> jobsData = (savedJobsData['jobs'] as List<dynamic>?) ?? [];
          for (final jobData in jobsData) {
            if ((jobData as Map<String, dynamic>)['id'] == widget.job.id) {
              if (mounted) {
                setState(() {
                  isSaved = true;
                });
              }
              break;
            }
          }
        }
      }
    }
  }

  Future<void> _checkIfApplied() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final String userId = currentUser.uid;
      final DocumentSnapshot appliedSnapshot = await FirebaseFirestore.instance
          .collection('applied_jobs')
          .doc(userId)
          .get();

      if (appliedSnapshot.exists) {
        final Map<String, dynamic> appliedData = appliedSnapshot.data() as Map<String, dynamic>;
        if (appliedData.containsKey('jobs')) {
          final List<dynamic> jobsData = (appliedData['jobs'] as List<dynamic>?) ?? [];
          for (final jobData in jobsData) {
            if ((jobData as Map<String, dynamic>)['id'] == widget.job.id) {
              if (mounted) {
                setState(() {
                  isApplied = true;
                });
              }
              break;
            }
          }
        }
      }
    }
  }

  Future<void> _toggleSave() async {
    try {
      if (isSaved) {
        await savedJobsServices.removeJobFromSavedJobs(widget.job);
      } else {
        await savedJobsServices.saveJob(widget.job);
      }

      setState(() {
        isSaved = !isSaved;
      });

      if (mounted) {
        CustomTopSnackBar.show(
          context,
          isSaved ? 'Job saved' : 'Job removed from saved',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomTopSnackBar.show(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _toggleApply() async {
    setState(() {
      isApplying = true;
    });

    try {
      if (isApplied) {
        await appliedJobsServices.removeJobFromAppliedJobs(widget.job);
      } else {
        await appliedJobsServices.addJobToAppliedJobs(widget.job);
      }

      if (mounted) {
        setState(() {
          isApplied = !isApplied;
          isApplying = false;
        });

        CustomTopSnackBar.show(
          context,
          isApplied ? 'Job applied successfully!' : 'Application removed',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isApplying = false;
        });
        CustomTopSnackBar.show(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job.companyName),
        backgroundColor: Colors.blue.shade50,
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? Colors.blue.shade900 : Colors.grey,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Image
            if (widget.job.jobImageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: widget.job.jobImageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CupertinoActivityIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.work_outline, size: 64),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Name
                  Text(
                    widget.job.companyName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Job Name
                  Text(
                    widget.job.jobName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Job Title
                  Text(
                    widget.job.jobTitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (widget.job.jobDescription.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.job.jobDescription,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      widget.job.category,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: widget.job.location,
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.attach_money,
                    label: 'Salary',
                    value: '${widget.job.amount.toStringAsFixed(0)}/month',
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Application Deadline',
                    value: '${widget.job.applicationDeadline.day}/${widget.job.applicationDeadline.month}/${widget.job.applicationDeadline.year}',
                  ),
                  const SizedBox(height: 24),

                  if (widget.job.prerequisites.isNotEmpty) ...[
                    const Text(
                      'Prerequisites',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.job.prerequisites.map((prerequisite) {
                        return Chip(
                          label: Text(prerequisite),
                          backgroundColor: Colors.blue[50],
                          labelStyle: TextStyle(color: Colors.blue[700]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (widget.job.skillsNeeded.isNotEmpty) ...[
                    const Text(
                      'Skills Required',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.job.skillsNeeded.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: Colors.green[50],
                          labelStyle: TextStyle(color: Colors.green[700]),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isApplying || isCheckingStatus) ? null : _toggleApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? Colors.green[50] : Colors.blue,
                        foregroundColor: isApplied ? Colors.green[700] : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isApplied ? Colors.green[300]! : Colors.blue,
                            width: 1,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: isApplying || isCheckingStatus
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CupertinoActivityIndicator(
                                radius: 10,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isApplied ? Icons.check_circle : Icons.work_outline,
                                  color: isApplied ? Colors.green[700] : Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isApplied ? 'Applied' : 'Apply Now',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isApplied ? Colors.green[700] : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

