import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/flow_action_card.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class HomeController extends GetxController {
  HomeController(this._service);

  final MockNaniService _service;

  ShiftOverview get overview => _service.shiftOverview;
  List<ShiftKpi> get kpis => _service.shiftKpis;
  List<CareTask> get tasks => _service.todayTasks.take(3).toList();
  List<AlertCase> get alerts => _service.alerts.take(2).toList();
  List<ResidentSnapshot> get residents => _service.residents.take(2).toList();
  List<NotificationMessage> get messages => _service.notifications.take(2).toList();
  int get unreadMessageCount => _service.unreadNotificationCount;
}

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return NaniScaffold(
      title: '护工智护台',
      subtitle: '围绕任务闭环组织首页，优先显示到点任务、报警和重点长者。',
      actions: [
        _HeaderActionButton(
          key: const ValueKey('home-open-notifications'),
          icon: Icons.mark_chat_unread_rounded,
          badge: controller.unreadMessageCount,
          onTap: () => Get.toNamed(AppRoutes.notifications),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShiftHeroCard(overview: controller.overview),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '班次驾驶舱',
            subtitle: '把任务、风险和责任范围压缩成可在 30 秒内完成判断的总览。',
          ),
          const SizedBox(height: 14),
          ...controller.kpis.map(
            (kpi) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _KpiCard(kpi: kpi),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(
            title: '消息中心',
            subtitle: '只把当前班次真正需要关注的消息放在首页，其余进入消息页查看。',
            trailing: TextButton(
              onPressed: () => Get.toNamed(AppRoutes.notifications),
              child: const Text('查看全部'),
            ),
          ),
          const SizedBox(height: 14),
          ...controller.messages.map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MessageCard(message: message),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '快捷动作',
            subtitle: '把最常用流程直接挂到首页，避免在多层菜单里来回切换。',
          ),
          const SizedBox(height: 14),
          const _QuickActionGrid(),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '即将到点任务',
            subtitle: '先把 P1 和临近时限任务拉到前面，保障交付顺序。',
          ),
          const SizedBox(height: 14),
          ...controller.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TaskPreviewCard(
                key: ValueKey('home-task-${task.id}'),
                task: task,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '风险提醒',
            subtitle: '报警处理和历史关注点保持同屏，避免只看实时事件。',
          ),
          const SizedBox(height: 14),
          ...controller.alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AlertPreviewCard(
                key: ValueKey('home-alert-${alert.id}'),
                alert: alert,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '重点长者',
            subtitle: '把今天真正需要重点照护的人放在固定位置，减少漏看。',
          ),
          const SizedBox(height: 14),
          ...controller.residents.map(
            (resident) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ResidentFocusCard(
                key: ValueKey('home-resident-${resident.id}'),
                resident: resident,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftHeroCard extends StatelessWidget {
  const _ShiftHeroCard({required this.overview});

  final ShiftOverview overview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatusChip(
                      label: overview.checkInTime,
                      color: AppPalette.white,
                      backgroundColor: AppPalette.white.withValues(alpha: 0.18),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      overview.caregiverName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppPalette.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${overview.station} · ${overview.shiftLabel}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppPalette.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
              _CompletionBadge(value: overview.completionRate),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            overview.focusSummary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppPalette.white,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroMeta(label: '高优先级', value: '${overview.urgentAlerts} 条'),
              const _HeroMeta(label: '护理边界', value: 'AI 只建议不执行'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppPalette.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppPalette.line),
            ),
            child: Icon(icon, color: AppPalette.info),
          ),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPalette.danger,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$badge',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppPalette.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppPalette.white,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '班次完成度',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppPalette.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppPalette.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});

  final ShiftKpi kpi;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppPalette.mint,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.stacked_line_chart_rounded, color: AppPalette.moss),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kpi.label, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(kpi.caption, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text(
            kpi.value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final NotificationMessage message;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(message.title, style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(
                label: message.isRead ? '已读' : '未读',
                color: message.isRead ? AppPalette.moss : AppPalette.danger,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${message.category} · ${message.time}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(message.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    const actions = [
      (
        'residents',
        '重点长者',
        '查看对象详情、风险和下一步护理动作',
        '对象',
        Icons.elderly_rounded,
        AppPalette.moss,
        AppRoutes.residents,
      ),
      (
        'health',
        '健康趋势',
        '查看复测波动，再决定是否回到录入',
        '趋势',
        Icons.show_chart_rounded,
        AppPalette.info,
        AppRoutes.health,
      ),
      (
        'handover',
        '交接详情',
        '核对责任人、确认项和升级边界',
        '交接',
        Icons.swap_horiz_rounded,
        AppPalette.warning,
        AppRoutes.handover,
      ),
      (
        'schedule',
        '我的排班',
        '查看班次区域、备注和后续安排',
        '排班',
        Icons.calendar_month_rounded,
        AppPalette.coral,
        AppRoutes.schedule,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        final cardHeight = cardWidth <= 150 ? 172.0 : 164.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return FlowActionCard(
              key: ValueKey('home-quick-action-${action.$1}'),
              icon: action.$5,
              color: action.$6,
              title: action.$2,
              subtitle: action.$3,
              tag: action.$4,
              onTap: () => Get.toNamed(action.$7),
            );
          },
        );
      },
    );
  }
}

class _TaskPreviewCard extends StatelessWidget {
  const _TaskPreviewCard({required this.task, super.key});

  final CareTask task;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(task.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(label: task.priority, color: _priorityColor(task.priority)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${task.residentName} · ${task.room} · ${task.dueTime}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: task.tags
                .map((tag) => StatusChip(label: tag, color: AppPalette.info))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(task.nextAction, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          FilledButton(
            key: ValueKey('home-open-care-task-${task.id}'),
            onPressed: () => Get.toNamed(AppRoutes.careExecution, arguments: task.id),
            child: const Text('进入执行页'),
          ),
        ],
      ),
    );
  }
}

class _AlertPreviewCard extends StatelessWidget {
  const _AlertPreviewCard({required this.alert, super.key});

  final AlertCase alert;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(label: alert.level, color: _priorityColor(alert.level)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${alert.residentName} · ${alert.time} · ${alert.status}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Text(alert.description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ResidentFocusCard extends StatelessWidget {
  const _ResidentFocusCard({required this.resident, super.key});

  final ResidentSnapshot resident;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(resident.name, style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(label: resident.careLevel, color: AppPalette.moss),
            ],
          ),
          const SizedBox(height: 8),
          Text('${resident.room} · ${resident.lastVitals}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(resident.riskNote, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(resident.focusTask, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          TextButton.icon(
            key: ValueKey('home-open-resident-${resident.id}'),
            onPressed: () => Get.toNamed(AppRoutes.residentDetail, arguments: resident.id),
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text('查看详情'),
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(String priority) {
  switch (priority) {
    case 'P1':
      return AppPalette.danger;
    case 'P2':
      return AppPalette.warning;
    default:
      return AppPalette.info;
  }
}