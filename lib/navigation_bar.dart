import 'package:flutter/material.dart';
import 'package:qr_generator/pages/generator_page.dart';
import 'package:qr_generator/pages/scanner_page.dart';
import 'package:qr_generator/pages/settings_page.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class CustomScrollPhysics extends ScrollPhysics {
  final double threshold;

  const CustomScrollPhysics({this.threshold = 0.0, super.parent});

  @override
  double get dragStartDistanceMotionThreshold => threshold;

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(threshold: threshold, parent: buildParent(ancestor));
  }
}

class _NavigationMenuState extends State<NavigationMenu> {
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = const <Widget>[
    GeneratorPage(),
    ScannerPage(),
    SettingsPage(),
  ];

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const CustomScrollPhysics(threshold: 15.0),
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          FocusScope.of(context).unfocus();
        },
      ),
      bottomNavigationBar: _CustomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}

class _CustomNavigationBar extends StatelessWidget {
  final Color backgroundColor;
  final Color indicatorColor;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _CustomNavigationBar({
    required this.backgroundColor,
    required this.indicatorColor,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: backgroundColor,
      indicatorColor: indicatorColor,
      elevation: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.qr_code),
          label: "Generator",
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner),
          label: "Scanner",
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
    );
  }
}