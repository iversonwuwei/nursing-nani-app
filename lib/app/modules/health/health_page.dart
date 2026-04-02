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

class HealthController extends GetxController {
  HealthController(this._service);

  final MockNaniService _service;
  final selectedResidentId = ''.obs;

  List<ResidentSnapshot> get residents => _service.residents;

  @override
  void onInit() {
    final argument = Get.arguments;
    selectedResidentId.value = argument is String ? argument : residents.first.id;
    super.onInit();
  }

  void selectResident(String residentId) {
    selectedResidentId.value = residentId;
  }

  ResidentSnapshot get resident => _service.findResidentById(selectedResidentId.value);
  ResidentHealthView get healthView => _service.findResidentHealthViewById(selectedResidentId.value);
}

class HealthView extends GetView<HealthController> {
  const HealthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '健康趋势',
        subtitle: '把复测、波动和人工观察放在同一页，先判断趋势，再决定是否回到录入或升级。',
        child: Obx(() {
          final resident = controller.resident;
          final healthView = controller.healthView;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.residents.map((item) {
                  final selected = item.id == controller.selectedResidentId.value;
                  return GestureDetector(
                    key: ValueKey('health-resident-${item.id}'),
                    onTap: () => controller.selectResident(item.id),
                    child: StatusChip(
                      label: item.name,
                      color: selected ? AppPalette.white : AppPalette.moss,
                      backgroundColor: selected ? AppPalette.moss : AppPalette.mint,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _HealthHero(
                key: ValueKey('health-hero-${resident.id}'),
                resident: resident,
                healthView: healthView,
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: '趋势卡片',
                subtitle: '当前值、上次值和解释要并排出现，避免只看单个数字做决定。',
              ),
              const SizedBox(height: 14),
              if (healthView.metrics.isEmpty)
                const _HealthSectionEmptyState(
                  keyName: 'health-metrics-empty-state',
                  title: '当前没有趋势指标',
                  description: '当对象尚未生成趋势卡片时，这里会明确显示为空态。',
                  icon: Icons.show_chart_rounded,
                )
              else
                ...healthView.metrics.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HealthMetricCard(
                      key: ValueKey('health-metric-${resident.id}-${entry.key}'),
                      metric: entry.value,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: '观察重点',
                subtitle: '这部分只保留本班需要人工确认的内容，不堆历史病历。',
              ),
              const SizedBox(height: 14),
              if (healthView.watchNotes.isEmpty)
                const _HealthSectionEmptyState(
                  keyName: 'health-watch-empty-state',
                  title: '当前没有观察重点',
                  description: '当本班没有额外观察项时，这里会明确显示为空态。',
                  icon: Icons.visibility_outlined,
                )
              else
                SurfaceCard(
                  key: ValueKey('health-watch-card-${resident.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...healthView.watchNotes.asMap().entries.map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(bottom: entry.key == healthView.watchNotes.length - 1 ? 0 : 12),
                          child: _WatchNoteRow(
                            key: ValueKey('health-watch-${resident.id}-${entry.key}'),
                            content: entry.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: '下一步动作',
                subtitle: '回到录入、进入 AI 解释或切回长者详情，但不自动触发业务结论。',
              ),
              const SizedBox(height: 14),
              Column(
                children: [
                  FlowActionCard(
                    key: ValueKey('health-open-entry-${resident.id}'),
                    icon: Icons.edit_note_rounded,
                    color: AppPalette.moss,
                    title: '回到健康录入',
                    subtitle: '继续补录复测结果，并保留本次趋势判断。',
                    tag: '录入',
                    onTap: () => Get.toNamed(AppRoutes.healthEntry, arguments: resident.id),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: ValueKey('health-open-resident-${resident.id}'),
                    icon: Icons.elderly_rounded,
                    color: AppPalette.info,
                    title: '查看长者详情',
                    subtitle: '回看对象风险、照护信号和本班重点。',
                    tag: '对象',
                    onTap: () => Get.toNamed(AppRoutes.residentDetail, arguments: resident.id),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: ValueKey('health-open-ai-${resident.id}'),
                    icon: Icons.auto_awesome_rounded,
                    color: AppPalette.warning,
                    title: '查看 AI 解释与建议',
                    subtitle: '在相同对象上下文里生成趋势解释，但不自动升级。',
                    tag: 'AI',
                    onTap: () => Get.toNamed(
                      AppRoutes.aiAssist,
                      arguments: {
                        'source': 'health-trend',
                        'resident': resident.name,
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _HealthHero extends StatelessWidget {
  const _HealthHero({required this.resident, required this.healthView, super.key});

  final ResidentSnapshot resident;
  final ResidentHealthView healthView;

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
                    Text(
                      resident.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppPalette.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${resident.room} · ${healthView.nextReview}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppPalette.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: healthView.riskLevel,
                color: AppPalette.moss,
                backgroundColor: AppPalette.white,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            healthView.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppPalette.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  const _HealthMetricCard({required this.metric, super.key});

  final HealthMetricTrend metric;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(metric.label, style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(label: metric.status, color: _metricColor(metric.status)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricValue(label: '当前', value: metric.currentValue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricValue(label: '上次', value: metric.previousValue),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('变化 ${metric.deltaLabel}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _metricColor(metric.status))),
          const SizedBox(height: 8),
          Text(metric.interpretation, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.cream,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _WatchNoteRow extends StatelessWidget {
  const _WatchNoteRow({required this.content, super.key});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: AppPalette.info,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(content, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    );
  }
}

Color _metricColor(String status) {
  switch (status) {
    case '偏高':
    case '待观察':
      return AppPalette.warning;
    case '需复测确认':
      return AppPalette.danger;
    case '改善':
    case '稳定':
    case '平稳':
    case '回落中':
    case '已降强度':
      return AppPalette.moss;
    default:
      return AppPalette.info;
  }
}

class _HealthSectionEmptyState extends StatelessWidget {
  const _HealthSectionEmptyState({
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