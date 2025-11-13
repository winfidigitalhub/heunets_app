import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routing/navigation_service.dart';
import '../../../../core/shared/widgets/bottom_nav_bar.dart';
import '../bloc/jobs_bloc.dart';
import '../bloc/jobs_event.dart';
import '../bloc/jobs_state.dart';
import '../widget/jobs_widgets.dart';
import '../../data/model/job_model.dart';
import '../../data/constants/job_constants.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with TickerProviderStateMixin {
  late AnimationController _tabAnimationController;
  late Animation<Offset> _tabSlideAnimation;
  late TabController _tabController;

  final List<String> categories = JobConstants.categories;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _locationQuery = '';
  
  List<String> get _allLocations {
    final List<String> locations = [];
    JobConstants.locations.forEach((country, states) {
      locations.add(country);
      locations.addAll(states.map((state) => '$state, $country'));
    });
    return locations..sort();
  }

  @override
  void initState() {
    super.initState();

    _tabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _tabSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _tabAnimationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    _tabAnimationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<JobsBloc>().add(const LoadJobsEvent());
      }
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final selectedCategory = categories[_tabController.index];
      context.read<JobsBloc>().add(FilterJobsByCategoryEvent(selectedCategory));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _tabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Job> _filterJobs(List<Job> jobs) {
    List<Job> filtered = jobs;

    if (_locationQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        final jobLocation = job.location.toLowerCase();
        final locationQuery = _locationQuery.toLowerCase();
        return jobLocation.contains(locationQuery);
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((job) {
        final titleMatch = job.jobTitle.toLowerCase().contains(_searchQuery) ||
            job.jobName.toLowerCase().contains(_searchQuery);
        return titleMatch;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 50),
            Container(
              height: 56,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.asset(
                        'assets/images/heunets_logo.jpeg',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Heunets',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                              fontWeight: FontWeight.w800,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: IconButton(
                      onPressed: () {
                        NavigationService.navigateToSavedJob();
                      },
                      icon: const Icon(
                        Icons.bookmark_outline,
                        color: Colors.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: IconButton(
                      onPressed: () {
                        NavigationService.navigateToAppliedJob();
                      },
                      icon: const Icon(
                        Icons.work_outline,
                        color: Colors.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 28,
              color: Colors.blue.shade50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SlideTransition(
                  position: _tabSlideAnimation,
                  child: SizedBox(
                    height: 28,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.blue.shade900,
                      unselectedLabelColor: Colors.black,
                      indicator: const BoxDecoration(),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      tabs: categories.map((category) => Tab(
                        child: InkResponse(
                          onTap: () {
                            _tabController.animateTo(categories.indexOf(category));
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<JobsBloc, JobsState>(
        builder: (context, state) {
          if (state is JobsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blue.shade900,
              ),
            );
          } else if (state is JobsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<JobsBloc>().add(const LoadJobsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is JobsLoaded) {
            return Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  child: Column(
                    children: [
                      Autocomplete<String>(
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: textEditingController,
                            builder: (context, textValue, child) {
                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                onChanged: (text) {
                                  setState(() {
                                    _locationQuery = text;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Filter by Location',
                                  hintText: 'Type to search countries and states...',
                                  prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                                  suffixIcon: textValue.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, color: Colors.grey),
                                          onPressed: () {
                                            textEditingController.clear();
                                            setState(() {
                                              _locationQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              );
                            },
                          );
                        },
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _allLocations.take(20);
                          }
                          return _allLocations.where((location) {
                            return location
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String location) {
                          setState(() {
                            _locationQuery = location;
                          });
                        },
                        displayStringForOption: (String option) => option,
                      ),
                      const SizedBox(height: 12),
                      // Search Bar for Job Title
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search by job title or name...',
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
                // Jobs List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: categories.map((category) {
                      // Filter jobs based on the current tab category
                      List<Job> categoryFilteredJobs = state.jobs.where((job) {
                        if (category == 'All') {
                          return true;
                        } else {
                          return job.category.toLowerCase() == category.toLowerCase();
                        }
                      }).toList();

                      // Apply location and search filters
                      List<Job> filteredJobs = _filterJobs(categoryFilteredJobs);

                      if (filteredJobs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty || _locationQuery.isNotEmpty
                                    ? 'No jobs found matching your filters'
                                    : 'No jobs available in this category',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredJobs.length,
                        itemBuilder: (context, index) {
                          return JobCard(job: filteredJobs[index]);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue.shade900,
            ),
          );
        },
      ),
      bottomNavigationBar: const GlobalBottomNavBar(),
    );
  }
}
