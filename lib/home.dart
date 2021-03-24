import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/screens/activities.dart';
import 'package:kanbasu/screens/courses.dart';
import 'package:kanbasu/screens/me.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'models/model.dart';

enum _ScreenKind { Activities, Courses, Me }

class Home extends HookWidget {
  BottomNavigationBarItem _buildNavigationItem(_ScreenKind s) {
    switch (s) {
      case _ScreenKind.Activities:
        return BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          activeIcon: Icon(Icons.notifications),
          label: 'title.activities'.tr(),
        );
      case _ScreenKind.Courses:
        return BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'title.courses'.tr(),
        );
      case _ScreenKind.Me:
        return BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'title.me'.tr(),
        );
    }
  }

  Widget _buildScreen(_ScreenKind s) {
    switch (s) {
      case _ScreenKind.Activities:
        return ActivitiesScreen();
      case _ScreenKind.Courses:
        return CoursesScreen();
      case _ScreenKind.Me:
        return MeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems =
        _ScreenKind.values.map(_buildNavigationItem).toList();
    final screens = _ScreenKind.values.map(_buildScreen).toList();

    final model = Provider.of<Model>(context);
    model.brightness = MediaQuery.of(context).platformBrightness;
    final theme = model.theme;

    return HookBuilder(builder: (context) {
      final activeTab = useState(0);

      return Scaffold(
        body: IndexedStack(
          index: activeTab.value,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: theme.primary,
          items: navigationItems,
          currentIndex: activeTab.value,
          type: BottomNavigationBarType.fixed,
          onTap: (int index) {
            activeTab.value = index;
          },
        ),
      );
    });
  }
}
