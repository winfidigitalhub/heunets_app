
import 'package:flutter/material.dart';

import 'bottom_nav_bar.dart';
class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool showBottomNavBar;
  final int currentIndex;

  const AppScaffold({
    Key? key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.showBottomNavBar = true,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null || actions != null || leading != null || bottom != null
          ? AppBar(
              title: title != null ? Text(title!) : null,
              actions: actions,
              leading: leading,
              bottom: bottom,
            )
          : null,
      body: body,
      bottomNavigationBar: showBottomNavBar
          ? GlobalBottomNavBar(currentIndex: currentIndex)
          : null,
    );
  }
}




