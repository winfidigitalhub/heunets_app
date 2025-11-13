class RouteTracker {
  static int getIndexForRoute(String? routeName, bool isEmployer) {
    if (routeName == null) return 0;

    if (isEmployer) {
      switch (routeName) {
        case '/home':
          return 0;
        case '/candidates':
          return 1;
        case '/add-job':
          return 2;
        case '/applied-job':
          return 3;
        case '/profile':
          return 4;
        default:
          return 0;
      }
    } else {
      switch (routeName) {
        case '/home':
          return 0;
        case '/add-job':
          return 1;
        case '/applied-job':
          return 2;
        case '/profile':
          return 3;
        default:
          return 0;
      }
    }
  }

  static bool shouldShowBottomNavBar(String? routeName) {
    if (routeName == null) return false;

    final hideNavBarRoutes = [
      '/login',
      '/signup',
      '/job-details',
    ];

    return !hideNavBarRoutes.contains(routeName);
  }
}


