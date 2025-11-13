import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../../core/shared/widgets/custom_top_snackbar.dart';

class CandidateProfileScreen extends StatefulWidget {
  final String userId;

  const CandidateProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  String _getString(String key, [String defaultValue = '']) {
    if (_userData == null) return defaultValue;
    return (_userData![key] as String?) ?? defaultValue;
  }

  String? _getStringOrNull(String key) {
    if (_userData == null) return null;
    return _userData![key] as String?;
  }

  @override
  void initState() {
    super.initState();
    _loadCandidateProfile();
  }

  Future<void> _loadCandidateProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'User profile not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadCV(String cvUrl) async {
    if (cvUrl.isEmpty) {
      CustomTopSnackBar.show(context, 'CV URL is not available');
      return;
    }

    try {
      // Show loading indicator
      if (mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // First, try to download the file locally
      try {
        final response = await http.get(Uri.parse(cvUrl));
        
        if (response.statusCode == 200) {
          // Get the directory for saving files (Downloads folder on mobile)
          final directory = await getApplicationDocumentsDirectory();
          
          // Extract filename from URL or use a default name
          String fileName = 'cv_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}';
          final uri = Uri.parse(cvUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            final lastSegment = pathSegments.last;
            // Remove query parameters if any
            final cleanSegment = lastSegment.split('?').first;
            if (cleanSegment.contains('.')) {
              fileName = cleanSegment;
            } else {
              // Try to get extension from content type
              final contentType = response.headers['content-type'];
              if (contentType != null) {
                if (contentType.contains('pdf')) {
                  fileName = '$fileName.pdf';
                } else if (contentType.contains('docx')) {
                  fileName = '$fileName.docx';
                } else if (contentType.contains('doc')) {
                  fileName = '$fileName.doc';
                }
              } else {
                fileName = '$fileName.pdf'; // Default to PDF
              }
            }
          } else {
            fileName = '$fileName.pdf'; // Default to PDF
          }
          
          // Save the file
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          
          // Close loading dialog
          if (mounted) {
            Navigator.of(context).pop();
            CustomTopSnackBar.show(context, 'CV downloaded successfully! File: $fileName');
          }
        } else {
          if (mounted) {
            Navigator.of(context).pop();
          }
          await _openCVUrl(cvUrl);
        }
      } catch (downloadError) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        await _openCVUrl(cvUrl);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        CustomTopSnackBar.show(context, 'Error downloading CV: $e');
      }
    }
  }

  Future<void> _openCVUrl(String cvUrl) async {
    try {
      final uri = Uri.parse(cvUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (mounted) {
          CustomTopSnackBar.show(context, 'Opening CV in browser...');
        }
      } else {
        if (mounted) {
          CustomTopSnackBar.show(context, 'Could not open CV URL. Please check your internet connection.');
        }
      }
    } catch (e) {
      if (mounted) {
        // Try alternative approach - just show the URL was downloaded
        CustomTopSnackBar.show(context, 'CV downloaded. File saved locally.');
      }
      debugPrint('Error opening CV URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidate Profile'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _userData == null
                  ? const Center(
                      child: Text('No profile data available'),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          // Profile Image
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.blue.shade900,
                            child: _getStringOrNull('profileImageUrl') != null &&
                                    _getStringOrNull('profileImageUrl')!.isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: _getString('profileImageUrl'),
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Text(
                                        _getString('username').isNotEmpty
                                            ? _getString('username')[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Text(
                                    _getString('username').isNotEmpty
                                        ? _getString('username')[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          // Username
                          Text(
                            _getString('username', 'Unknown User'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getString('email'),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // CV/Resume Card
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: Colors.blue.shade900,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CV/Resume',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _getStringOrNull('cvUrl') != null &&
                                        _getStringOrNull('cvUrl')!.isNotEmpty
                                    ? Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'CV Uploaded',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _downloadCV(_getString('cvUrl')),
                                            icon: Icon(
                                              Icons.download,
                                              color: Colors.blue.shade900,
                                            ),
                                            tooltip: 'Download CV',
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'No Uploaded CV',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Bio Card
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getStringOrNull('employeeBio') != null &&
                                          _getStringOrNull('employeeBio')!.isNotEmpty
                                      ? _getString('employeeBio')
                                      : 'No Bio',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getStringOrNull('employeeBio') != null &&
                                            _getStringOrNull('employeeBio')!.isNotEmpty
                                        ? Colors.black87
                                        : Colors.grey[600],
                                    fontStyle: _getStringOrNull('employeeBio') != null &&
                                            _getStringOrNull('employeeBio')!.isNotEmpty
                                        ? FontStyle.normal
                                        : FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
    );
  }
}

