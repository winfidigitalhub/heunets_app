import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../../routing/navigation_service.dart';
import '../../routing/route_names.dart';
import '../../routing/route_tracker.dart';

class GlobalBottomNavBar extends StatefulWidget {
  final int? currentIndex;
  
  const GlobalBottomNavBar({
    Key? key,
    this.currentIndex,
  }) : super(key: key);

  @override
  _GlobalBottomNavBarState createState() => _GlobalBottomNavBarState();
  
  static void refreshAll() {
    _GlobalBottomNavBarState.refreshAllInstances();
  }
}

class _GlobalBottomNavBarState extends State<GlobalBottomNavBar> {
  String? _userRole;
  String? _lastRoute;
  final UserService _userService = UserService();
  
  static final List<_GlobalBottomNavBarState> _instances = [];

  @override
  void initState() {
    super.initState();
    _instances.add(this);
    _loadUserRole();
  }

  @override
  void dispose() {
    _instances.remove(this);
    super.dispose();
  }

  static void refreshAllInstances() {
    for (final instance in _instances) {
      if (instance.mounted) {
        instance.refreshRole();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final previousRoute = _lastRoute;
    if (currentRoute != _lastRoute) {
      _lastRoute = currentRoute;
      // refresh role when coming from profile screen since user might have switched
      if (currentRoute == '/profile' || previousRoute == '/profile') {
        _loadUserRole(forceRefresh: true);
      } else if (currentRoute != null) {
        _loadUserRole(forceRefresh: false);
      }
    }
  }

  Future<void> _loadUserRole({bool forceRefresh = false}) async {
    final role = await _userService.getUserRole(forceRefresh: forceRefresh);
    if (mounted) {
      setState(() {
        _userRole = role;
      });
    }
  }

  void refreshRole() {
    _loadUserRole(forceRefresh: true);
  }

  Future<void> _switchRoleAndNavigateToAddJob() async {
    try {
      await _userService.updateUserRole('employer');
      
      if (mounted) {
        setState(() {
          _userRole = 'employer';
        });
      }
      
      // small delay to let firestore sync
      await Future<void>.delayed(const Duration(milliseconds: 150));
      
      if (mounted) {
        NavigationService.navigateToAddJob();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error switching role: $e')),
        );
      }
    }
  }

  void _showSwitchToEmployerModal() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool switchValue = false;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Switch to Employer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Switch to Employer to post a new job',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Switch to Employer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: switchValue,
                        onChanged: (value) async {
                          setDialogState(() {
                            switchValue = value;
                          });
                          
                          if (value) {
                            Navigator.of(dialogContext).pop();
                            await _switchRoleAndNavigateToAddJob();
                          }
                        },
                        activeColor: Colors.blue.shade900,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    final role = _userRole ?? 'employee';
    List<String> routes = _getRoutesForRole(role);
    
    if (index >= 0 && index < routes.length) {
      String route = routes[index];
      
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == route) {
        return;
      }
      
      switch (route) {
        case RouteNames.home:
          NavigationService.pushReplacementNamed(RouteNames.home);
          break;
        case RouteNames.addJob:
          if (role == 'employee') {
            _showSwitchToEmployerModal();
          } else {
            NavigationService.navigateToAddJob();
          }
          break;
        case RouteNames.appliedJob:
          NavigationService.navigateToAppliedJob();
          break;
        case RouteNames.savedJob:
          NavigationService.navigateToSavedJob();
          break;
        case RouteNames.profile:
          NavigationService.navigateToProfile();
          break;
        case RouteNames.candidates:
          NavigationService.pushReplacementNamed(RouteNames.candidates);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final route = ModalRoute.of(context)?.settings.name;
    
    if (!RouteTracker.shouldShowBottomNavBar(route)) {
      return const SizedBox.shrink();
    }

    final role = _userRole ?? 'employee';
    final routes = _getRoutesForRole(role);
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final index = routes.indexWhere((r) => r == currentRoute);
    final currentIndex = index >= 0 ? index : 0;
    
    return BottomNavigationBar(
      key: ValueKey('bottom_nav_bar_$role'),
      currentIndex: currentIndex.clamp(0, _getItemsForRole(role).length - 1),
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepOrangeAccent,
      unselectedItemColor: Colors.grey,
      items: _getItemsForRole(role),
    );
  }

  List<String> _getRoutesForRole(String role) {
    if (role == 'employer') {
      return [
        RouteNames.home,
        RouteNames.candidates,
        RouteNames.addJob,
        RouteNames.appliedJob,
        RouteNames.profile,
      ];
    } else {
      // employee nav items
      return [
        RouteNames.home,
        RouteNames.addJob,
        RouteNames.appliedJob,
        RouteNames.profile,
      ];
    }
  }

  List<BottomNavigationBarItem> _getItemsForRole(String role) {
    if (role == 'employer') {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'All Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Candidates',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Post Job',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Applied Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      // Employee
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'All Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work),
          label: 'Post New Job',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: 'Applied Jobs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }
}
