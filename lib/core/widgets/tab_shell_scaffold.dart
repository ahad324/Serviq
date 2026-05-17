import 'package:flutter/material.dart';
import 'package:serviq/features/input/presentation/screens/input_screen.dart';
import 'package:serviq/features/booking/presentation/screens/booking_history_screen.dart';
import 'package:serviq/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:serviq/features/common/presentation/screens/profile_screen.dart';
import 'package:serviq/core/widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';

class TabShellScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const TabShellScaffold({super.key, required this.navigationShell});

  @override
  State<TabShellScaffold> createState() => _TabShellScaffoldState();
}

class _TabShellScaffoldState extends State<TabShellScaffold> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.navigationShell.currentIndex);
  }

  @override
  void didUpdateWidget(covariant TabShellScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != _pageController.page?.round()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(widget.navigationShell.currentIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
          _pageController.jumpToPage(0);
        } else {
          // If already on home, let the app exit or handle as needed
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => widget.navigationShell.goBranch(index),
          children: const [
            InputScreen(),
            BookingHistoryScreen(),
            TrackingScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentRoute: _getRouteForIndex(widget.navigationShell.currentIndex),
        ),
      ),
    );
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0: return '/home';
      case 1: return '/booking-history';
      case 2: return '/tracking';
      case 3: return '/profile';
      default: return '/home';
    }
  }
}
