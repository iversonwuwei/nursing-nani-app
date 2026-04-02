import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/auth_service.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class ProfileController extends GetxController {
  ProfileController(this._service);

  final MockNaniService _service;

  ShiftOverview get overview => _service.shiftOverview;
  List<ScheduleItem> get schedule => _service.schedule.take(2).toList();
  List<HandoverItem> get handovers => _service.handoverItems.take(2).toList();
  String get handoverSummary => _service.handoverSummary;
}

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return NaniScaffold(
      title: '我的班次',
      subtitle: '把排班、交接班和个人责任范围收束在一个页面里，便于班前准备。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            key: const ValueKey('profile-summary-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppPalette.mint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.badge_rounded, color: AppPalette.moss),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(controller.overview.caregiverName, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(controller.overview.station, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    StatusChip(label: controller.overview.shiftLabel, color: AppPalette.info),
                  ],
                ),
                const SizedBox(height: 14),
                Text(controller.overview.focusSummary, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: '我的排班',
            subtitle: '未来两班先看清所在楼层和调班风险。',
            trailing: TextButton(
              key: const ValueKey('profile-open-schedule'),
              onPressed: () => Get.toNamed(AppRoutes.schedule),
              child: const Text('查看全部'),
            ),
          ),
          const SizedBox(height: 14),
          if (controller.schedule.isEmpty)
            const _ProfileEmptyState(
              keyName: 'profile-schedule-empty-state',
              title: '当前没有未来排班',
              description: '排班未下发或当前没有后续班次时，这里会明确显示为空态。',
              icon: Icons.calendar_month_rounded,
            )
          else
            ...controller.schedule.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SchedulePreviewCard(
                  key: ValueKey('profile-schedule-${item.date}'),
                  item: item,
                ),
              ),
            ),
          const SizedBox(height: 24),
          SectionHeader(
            title: '交接班重点',
            subtitle: '高风险事项在下班前必须转成明确的交接信息。',
            trailing: TextButton(
              key: const ValueKey('profile-open-handover'),
              onPressed: () => Get.toNamed(AppRoutes.handover),
              child: const Text('进入交接班'),
            ),
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            key: const ValueKey('profile-handover-summary'),
            child: Text(controller.handoverSummary, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(height: 12),
          if (controller.handovers.isEmpty)
            const _ProfileEmptyState(
              keyName: 'profile-handover-empty-state',
              title: '当前没有交接班重点',
              description: '当高风险事项都已闭环时，这里会明确显示为空态。',
              icon: Icons.swap_horiz_rounded,
            )
          else
            ...controller.handovers.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HandoverPreviewCard(
                  key: ValueKey('profile-handover-${item.id}'),
                  item: item,
                ),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const ValueKey('profile-logout-button'),
            onPressed: () {
              Get.find<AuthService>().signOut();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }
}

class _SchedulePreviewCard extends StatelessWidget {
  const _SchedulePreviewCard({required this.item, super.key});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.date, style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(label: item.shift, color: AppPalette.moss),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.area, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text(item.note, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HandoverPreviewCard extends StatelessWidget {
  const _HandoverPreviewCard({required this.item, super.key});

  final HandoverItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.residentName, style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(label: item.priority, color: item.priority == '高' ? AppPalette.danger : AppPalette.warning),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.topic, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text(item.detail, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState({
    required this.keyName,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String keyName;
  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: ValueKey(keyName),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}