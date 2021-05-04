import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kanbasu/screens/activities.dart';
import 'package:kanbasu/screens/courses.dart';
import 'package:kanbasu/screens/me.dart';
import 'package:kanbasu/widgets/drawer_header.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import 'models/model.dart';

enum _ScreenKind { Activities, Courses, Me }

class _NavigationItem {
  final int id;
  final String title;
  final Icon icon;
  final Icon activeIcon;

  _NavigationItem(
    this.id,
    this.title,
    this.icon,
    this.activeIcon,
  );
}

class Home extends HookWidget {
  static final _navigationItems = {
    _ScreenKind.Activities: _NavigationItem(
      0,
      'title.activities'.tr(),
      Icon(Icons.notifications_outlined),
      Icon(Icons.notifications),
    ),
    _ScreenKind.Courses: _NavigationItem(
      1,
      'title.courses'.tr(),
      Icon(Icons.book_outlined),
      Icon(Icons.book),
    ),
    _ScreenKind.Me: _NavigationItem(
      2,
      'title.me'.tr(),
      Icon(Icons.person_outline),
      Icon(Icons.person),
    ),
  };

  BottomNavigationBarItem _buildNavigationItem(_ScreenKind s) {
    final item = _navigationItems[s]!;
    return BottomNavigationBarItem(
      label: item.title,
      icon: item.icon,
      activeIcon: item.activeIcon,
    );
  }

  Widget _buildSideTile(_ScreenKind s, ValueNotifier<int> activeTab) {
    final item = _navigationItems[s]!;
    final active = activeTab.value == item.id;

    return ListTile(
      leading: active ? item.activeIcon : item.icon,
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : null,
          fontSize: active ? 18 : null,
        ),
      ),
      onTap: () async {
        activeTab.value = item.id;
      },
      selected: active,
    );
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
    final model = Provider.of<Model>(context);
    model.brightness = MediaQuery.of(context).platformBrightness;
    final theme = model.theme;

    return HookBuilder(builder: (context) {
      final activeTab = useState(0);

      final stack = useMemoized(() {
        final screens = _navigationItems.keys.map(_buildScreen).toList();
        return IndexedStack(
          index: activeTab.value,
          children: screens,
        );
      }, [activeTab.value]);

      if (Device.get().isPhone) {
        final navigationItems =
            _navigationItems.keys.map(_buildNavigationItem).toList();

        return Scaffold(
          body: stack,
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: theme.primary,
            items: navigationItems,
            currentIndex: activeTab.value,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              HapticFeedback.mediumImpact();
              activeTab.value = index;
            },
          ),
        );
      } else {
        final sideTiles = _navigationItems.keys
            .map((s) => _buildSideTile(s, activeTab))
            .toList();

        return Row(
          children: [
            Drawer(
              child: Row(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        DrawerHeaderWidget(),
                        ...sideTiles,
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1),
                ],
              ),
            ),
            Expanded(child: stack)
          ],
        );
      }
    });
  }
}
