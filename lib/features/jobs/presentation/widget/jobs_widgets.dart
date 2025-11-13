import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/job_model.dart';
import '../../../saved_jobs/data/services/saved_jobs_services.dart';
import '../../../applied_jobs/data/services/applied_jobs_services.dart';
import '../../../../core/routing/navigation_service.dart';

class JobCard extends StatefulWidget {
  final Job job;

  const JobCard({
    super.key,
    required this.job,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApplied ? 'Job applied!' : 'Application removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isApplying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 180,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            NavigationService.navigateToJobDetails(job: widget.job);
          },
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: widget.job.jobImageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.job.jobImageUrl,
                            placeholder: (context, url) => Container(
                              width: 140,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.deepOrangeAccent,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 140,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.work_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                            width: 140,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 140,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.work_outline,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.job.companyName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.job.jobName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 11,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.job.location,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Skills
                          if (widget.job.skillsNeeded.isNotEmpty)
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Wrap(
                                    spacing: 3,
                                    runSpacing: 3,
                                    children: widget.job.skillsNeeded.take(2).map((skill) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50],
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.blue[200]!,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Text(
                                          skill,
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  if (widget.job.skillsNeeded.length > 2)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        '+ ${widget.job.skillsNeeded.length - 2} other skills',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(height: 6),
                          // Apply Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (isApplying || isCheckingStatus) ? null : _toggleApply,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isApplied
                                    ? Colors.green[50]
                                    : Colors.blue,
                                foregroundColor: isApplied
                                    ? Colors.green[700]
                                    : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isApplied
                                        ? Colors.green[300]!
                                        : Colors.blue,
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: isApplying || isCheckingStatus
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CupertinoActivityIndicator(
                                        radius: 8,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isApplied ? Icons.check_circle : Icons.work_outline,
                                          size: 13,
                                          color: isApplied ? Colors.green[700] : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isApplied ? 'Applied' : 'Apply',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isApplied ? Colors.green[700] : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Save Icon at top right
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _toggleSave,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? Colors.deepOrangeAccent : Colors.grey[700],
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
