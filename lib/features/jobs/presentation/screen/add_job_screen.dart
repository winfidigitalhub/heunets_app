import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';
import '../../../../core/shared/widgets/custom_top_snackbar.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../../core/shared/services/user_service.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';
import '../../data/constants/job_constants.dart';

class AddJobScreen extends StatefulWidget {
  final UserService? userService;
  final ImagePicker? imagePicker;

  const AddJobScreen({
    super.key,
    this.userService,
    this.imagePicker,
  });

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _jobNameController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobDescriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  
  late final ImagePicker _imagePicker;
  late final UserService _userService;

  @override
  void initState() {
    super.initState();
    _imagePicker = widget.imagePicker ?? ImagePicker();
    _userService = widget.userService ?? UserService();
    _loadCompanyName();
  }
  
  String? _jobImagePath;
  DateTime? _applicationDeadline;
  File? _jobImageFile;
  
  String? _selectedCategory;
  List<String> _selectedPrerequisites = [];
  List<String> _selectedSkills = [];
  String? _selectedCountry;
  String? _selectedState;
  
  List<String> _availableStates = [];
  bool _imageError = false;


  Future<void> _loadCompanyName() async {
    try {
      Map<String, dynamic>? userData = await _userService.getUserData();
      if (userData != null && userData.containsKey('companyName')) {
        String? companyName = userData['companyName'] as String?;
        if (companyName != null && companyName.isNotEmpty && mounted) {
          setState(() {
            _companyNameController.text = companyName;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading company name: $e');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobNameController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickJobImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          _jobImagePath = pickedFile.path;
          _jobImageFile = File(pickedFile.path);
          _imageError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomTopSnackBar.show(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _applicationDeadline = picked;
      });
    }
  }

  void _onCountryChanged(String? country) {
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _availableStates = country != null 
          ? (JobConstants.locations[country] ?? [])
          : [];
    });
  }

  void _showPrerequisitesDialog() {
    final tempSelectedPrerequisites = List<String>.from(_selectedPrerequisites);
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select Prerequisites'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: JobConstants.prerequisites.length,
                itemBuilder: (context, index) {
                  final prerequisite = JobConstants.prerequisites[index];
                  final isSelected = tempSelectedPrerequisites.contains(prerequisite);
                  return CheckboxListTile(
                    title: Text(prerequisite),
                    value: isSelected,
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedPrerequisites.add(prerequisite);
                        } else {
                          tempSelectedPrerequisites.remove(prerequisite);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    tempSelectedPrerequisites.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedPrerequisites = tempSelectedPrerequisites;
                  });
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSkillsDialog() {
    final tempSelectedSkills = List<String>.from(_selectedSkills);
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select Skills'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: JobConstants.skills.length,
                itemBuilder: (context, index) {
                  final skill = JobConstants.skills[index];
                  final isSelected = tempSelectedSkills.contains(skill);
                  return CheckboxListTile(
                    title: Text(skill),
                    value: isSelected,
                    onChanged: (value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelectedSkills.add(skill);
                        } else {
                          tempSelectedSkills.remove(skill);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    tempSelectedSkills.clear();
                  });
                },
                child: const Text('Clear All'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedSkills = tempSelectedSkills;
                  });
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitForm() {
    // Reset image error
    setState(() {
      _imageError = false;
    });

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate image upload
    if (_jobImageFile == null || _jobImagePath == null || _jobImagePath!.isEmpty) {
      setState(() {
        _imageError = true;
      });
      CustomTopSnackBar.show(context, 'Please upload a job image');
      return;
    }

    // Validate category
    if (_selectedCategory == null) {
      CustomTopSnackBar.show(context, 'Please select a category');
      return;
    }

    // Validate prerequisites
    if (_selectedPrerequisites.isEmpty) {
      CustomTopSnackBar.show(context, 'Please select at least one prerequisite');
      return;
    }

    // Validate skills
    if (_selectedSkills.isEmpty) {
      CustomTopSnackBar.show(context, 'Please select at least one skill');
      return;
    }

    // Validate location
    if (_selectedCountry == null) {
      CustomTopSnackBar.show(context, 'Please select a country');
      return;
    }
    if (_selectedState == null || _selectedState!.isEmpty) {
      CustomTopSnackBar.show(context, 'Please select a state/province');
      return;
    }

    // Validate deadline
    if (_applicationDeadline == null) {
      CustomTopSnackBar.show(context, 'Please select an application deadline');
      return;
    }
    if (_applicationDeadline!.isBefore(DateTime.now())) {
      CustomTopSnackBar.show(context, 'Application deadline cannot be in the past');
      return;
    }

    final location = '$_selectedState, $_selectedCountry';

    context.read<JobsBloc>().add(
      CreateJobEvent(
        companyName: _companyNameController.text.trim(),
        jobImagePath: _jobImagePath,
        jobName: _jobNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        jobDescription: _jobDescriptionController.text.trim(),
        category: _selectedCategory!,
        location: location,
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        prerequisites: _selectedPrerequisites,
        skillsNeeded: _selectedSkills,
        applicationDeadline: _applicationDeadline!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsBloc, JobsState>(
      listener: (context, state) {
        if (state is JobCreated) {
          CustomTopSnackBar.show(context, 'Job created successfully!');
          NavigationService.navigateToHome();
        } else if (state is JobsError) {
          CustomTopSnackBar.show(context, 'Error: ${state.message}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post a new Job'),
          backgroundColor: Colors.blue.shade50,
        ),
        body: BlocBuilder<JobsBloc, JobsState>(
          builder: (context, state) {
            final isLoading = state is JobsLoading;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Job Image Section - Full Width
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Job Image *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _imageError ? Colors.red : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickJobImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _imageError
                                    ? Colors.red
                                    : (_jobImageFile != null
                                        ? Colors.green
                                        : Colors.grey[400]!),
                                width: _imageError ? 2 : 2,
                              ),
                              color: Colors.grey[200],
                            ),
                            child: _jobImageFile != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _jobImageFile!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 50,
                                        color: _imageError
                                            ? Colors.red[300]
                                            : Colors.grey,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap to upload job image',
                                        style: TextStyle(
                                          color: _imageError
                                              ? Colors.red[300]
                                              : Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        if (_imageError) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Job image is required',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Company Name
                    TextFormField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Company Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter company name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: JobConstants.categories
                          .where((cat) => cat != 'All')
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Job Name
                    TextFormField(
                      controller: _jobNameController,
                      decoration: const InputDecoration(
                        labelText: 'Job Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter job name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Job Title
                    TextFormField(
                      controller: _jobTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Job Title *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter job title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Job Description
                    TextFormField(
                      controller: _jobDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Job Description *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter job description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location - Country Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      decoration: const InputDecoration(
                        labelText: 'Country *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.public),
                      ),
                      items: JobConstants.locations.keys
                          .map((country) => DropdownMenuItem(
                                value: country,
                                child: Text(country),
                              ))
                          .toList(),
                      onChanged: _onCountryChanged,
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Location - State Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: const InputDecoration(
                        labelText: 'State/Province *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _availableStates
                          .map((state) => DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              ))
                          .toList(),
                      onChanged: _selectedCountry == null
                          ? null
                          : (value) {
                              setState(() {
                                _selectedState = value;
                              });
                            },
                      validator: (value) {
                        if (_selectedCountry == null) {
                          return null; // Country validation will handle this
                        }
                        if (value == null || value.isEmpty) {
                          return 'Please select a state/province';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount per month *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        helperText: 'Enter the monthly salary amount',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter amount';
                        }
                        final amount = double.tryParse(value.trim());
                        if (amount == null) {
                          return 'Please enter a valid number';
                        }
                        if (amount <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prerequisites Multi-Select
                    InkWell(
                      onTap: _showPrerequisitesDialog,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Prerequisites *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.checklist),
                          suffixIcon: _selectedPrerequisites.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedPrerequisites.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedPrerequisites.isEmpty
                                    ? 'Select prerequisites'
                                    : '${_selectedPrerequisites.length} prerequisite(s) selected',
                                style: TextStyle(
                                  color: _selectedPrerequisites.isEmpty
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedPrerequisites.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedPrerequisites.take(5).map((prereq) {
                          return Chip(
                            label: Text(prereq),
                            onDeleted: () {
                              setState(() {
                                _selectedPrerequisites.remove(prereq);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedPrerequisites.length > 5)
                        Text(
                          'and ${_selectedPrerequisites.length - 5} more...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),

                    // Skills Multi-Select
                    InkWell(
                      onTap: _showSkillsDialog,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Skills Needed *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.code),
                          suffixIcon: _selectedSkills.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _selectedSkills.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _selectedSkills.isEmpty
                                    ? 'Select skills'
                                    : '${_selectedSkills.length} skill(s) selected',
                                style: TextStyle(
                                  color: _selectedSkills.isEmpty
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (_selectedSkills.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSkills.take(5).map((skill) {
                          return Chip(
                            label: Text(skill),
                            onDeleted: () {
                              setState(() {
                                _selectedSkills.remove(skill);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_selectedSkills.length > 5)
                        Text(
                          'and ${_selectedSkills.length - 5} more...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                    const SizedBox(height: 16),

                    // Application Deadline
                    InkWell(
                      onTap: _selectDeadline,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Application Deadline *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today),
                          errorText: _applicationDeadline == null
                              ? null
                              : (_applicationDeadline!.isBefore(DateTime.now())
                                  ? 'Deadline cannot be in the past'
                                  : null),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _applicationDeadline == null
                                  ? 'Select deadline'
                                  : '${_applicationDeadline!.day}/${_applicationDeadline!.month}/${_applicationDeadline!.year}',
                              style: TextStyle(
                                color: _applicationDeadline == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    if (_applicationDeadline != null &&
                        _applicationDeadline!.isBefore(DateTime.now()))
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          'Deadline cannot be in the past',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Create Job',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: const GlobalBottomNavBar(),
      ),
    );
  }
}
