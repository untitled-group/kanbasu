import 'package:flutter/material.dart';
import 'package:kanbasu/screens/activities.dart';
import 'package:kanbasu/screens/courses.dart';
import 'package:kanbasu/screens/me.dart';
import 'package:provider/provider.dart';

import 'models/model.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<BottomNavigationBarItem> _buildNavigationItems() {
    final activities = BottomNavigationBarItem(
        icon: Icon(Icons.notifications_outlined),
        activeIcon: Icon(Icons.notifications),
        label: 'Activities');

    final courses = BottomNavigationBarItem(
        icon: Icon(Icons.book_outlined),
        activeIcon: Icon(Icons.book),
        label: 'Courses');

    final me = BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Me');

    return [activities, courses, me];
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return ActivitiesScreen();
      case 1:
        return CoursesScreen();
      case 2:
        return MeScreen();
    }
    throw Exception();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);
    final theme = model.theme;
    final navigationItems = _buildNavigationItems();

    return Scaffold(
      body: IndexedStack(
        index: model.activeTab,
        children: [
          for (var i = 0; i < navigationItems.length; i++) _buildScreen(i)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: theme.primary,
        items: navigationItems,
        currentIndex: model.activeTab,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          model.activeTab = index;
        },
      ),
    );
  }
}
