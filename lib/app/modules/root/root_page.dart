import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/modules/ai_assistant/ai_assistant_page.dart';
import 'package:nursing_nani_app/app/modules/alerts/alerts_page.dart';
import 'package:nursing_nani_app/app/modules/home/home_page.dart';
import 'package:nursing_nani_app/app/modules/profile/profile_page.dart';
import 'package:nursing_nani_app/app/modules/tasks/tasks_page.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';

class RootController extends GetxController {
  final currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}

class RootView extends GetView<RootController> {
  const RootView({super.key});

  static const _tabs = [
    HomeView(),
    TasksView(),
    AlertsView(),
    AiAssistantView(),
    ProfileView(),
  ];

  static const _items = [
    _NavItem(icon: Icons.space_dashboard_rounded, label: '首页', keyName: 'home'),
    _NavItem(icon: Icons.task_alt_rounded, label: '任务', keyName: 'tasks'),
    _NavItem(icon: Icons.notifications_active_rounded, label: '报警', keyName: 'alerts'),
    _NavItem(icon: Icons.psychology_alt_rounded, label: 'AI', keyName: 'ai'),
    _NavItem(icon: Icons.person_rounded, label: '我的', keyName: 'profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: AppGradients.page),
              ),
            ),
            IndexedStack(
              index: controller.currentIndex.value,
              children: _tabs,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _FloatingNavigationBar(
                  currentIndex: controller.currentIndex.value,
                  onSelected: controller.changeIndex,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavigationBar extends StatelessWidget {
  const _FloatingNavigationBar({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppPalette.line),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: List.generate(RootView._items.length, (index) {
          final item = RootView._items[index];
          final selected = currentIndex == index;
          return Expanded(
            child: GestureDetector(
              key: ValueKey('root-nav-${item.keyName}'),
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected ? AppGradients.accent : null,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: selected ? AppPalette.white : AppPalette.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: selected
                            ? AppPalette.white
                            : AppPalette.textSecondary,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.keyName,
  });

  final IconData icon;
  final String label;
  final String keyName;
}