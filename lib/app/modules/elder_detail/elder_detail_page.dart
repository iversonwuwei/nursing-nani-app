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

class ResidentDetailController extends GetxController {
  ResidentDetailController(this._service);

  final MockNaniService _service;
  late String residentId;

  @override
  void onInit() {
    final argument = Get.arguments;
    residentId = argument is String ? argument : _service.residents.first.id;
    super.onInit();
  }

  ResidentDetail get detail => _service.findResidentDetailById(residentId);
}

class ResidentDetailView extends GetView<ResidentDetailController> {
  const ResidentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = controller.detail;
    final resident = detail.snapshot;

    return Scaffold(
      body: NaniScaffold(
        title: '长者详情',
        subtitle: '把风险、观察重点和下一步动作收拢到同一页，减少在任务与录入之间来回切换。',
        actions: [
          StatusChip(label: resident.careLevel, color: AppPalette.moss),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResidentHero(
              key: ValueKey('resident-detail-hero-${resident.id}'),
              detail: detail,
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '本班重点',
              subtitle: '先确认必须观察和必须留痕的事项，再进入具体执行流。',
            ),
            const SizedBox(height: 14),
            ...detail.watchItems.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WatchItemCard(
                  key: ValueKey('resident-watch-${resident.id}-${entry.key}'),
                  index: entry.key + 1,
                  content: entry.value,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '照护信号',
              subtitle: '把最常查的信息拆成稳定的卡片，避免依赖口头记忆。',
            ),
            const SizedBox(height: 14),
            _SignalCard(
              key: ValueKey('resident-signal-vitals-${resident.id}'),
              icon: Icons.monitor_heart_rounded,
              color: AppPalette.info,
              title: '最新指标',
              content: resident.lastVitals,
            ),
            const SizedBox(height: 12),
            _SignalCard(
              key: ValueKey('resident-signal-mobility-${resident.id}'),
              icon: Icons.accessibility_new_rounded,
              color: AppPalette.moss,
              title: '活动与认知',
              content: '${detail.mobility}；${detail.cognition}',
            ),
            const SizedBox(height: 12),
            _SignalCard(
              key: ValueKey('resident-signal-diet-${resident.id}'),
              icon: Icons.restaurant_rounded,
              color: AppPalette.warning,
              title: '饮食与观察',
              content: detail.dietNote,
            ),
            const SizedBox(height: 12),
            _SignalCard(
              key: ValueKey('resident-signal-family-${resident.id}'),
              icon: Icons.family_restroom_rounded,
              color: AppPalette.coral,
              title: '家属关注',
              content: detail.familyPreference,
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '执行提醒',
              subtitle: '保持人工确认边界，避免把 AI 建议误当成自动结论。',
            ),
            const SizedBox(height: 14),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...detail.careNotes.asMap().entries.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: entry.key == detail.careNotes.length - 1 ? 0 : 12),
                      child: _CareNoteRow(content: entry.value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '下一步动作',
              subtitle: '从详情页直接进入录入、执行和 AI 解释，但不自动替代人工确认。',
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                SurfaceCard(
                  key: ValueKey('resident-focus-task-${resident.id}'),
                  child: Text(resident.focusTask, style: Theme.of(context).textTheme.bodyLarge),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('resident-open-health-${resident.id}'),
                  icon: Icons.show_chart_rounded,
                  color: AppPalette.info,
                  title: '查看健康趋势',
                  subtitle: '先看复测与波动，再决定是否回到录入。',
                  tag: '趋势',
                  onTap: () => Get.toNamed(
                    AppRoutes.health,
                    arguments: resident.id,
                  ),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('resident-open-health-entry-${resident.id}'),
                  icon: Icons.edit_note_rounded,
                  color: AppPalette.moss,
                  title: '进入健康录入',
                  subtitle: '基于当前对象直接补录体征与复测结果。',
                  tag: '录入',
                  onTap: () => Get.toNamed(
                    AppRoutes.healthEntry,
                    arguments: resident.id,
                  ),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('resident-open-care-execution-${resident.id}'),
                  icon: Icons.play_circle_fill_rounded,
                  color: AppPalette.coral,
                  title: '进入护理执行',
                  subtitle: '继续当前对象关联任务，并保留人工留痕。',
                  tag: '执行',
                  onTap: () => Get.toNamed(
                    AppRoutes.careExecution,
                    arguments: detail.linkedTaskId,
                  ),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('resident-open-handover-${resident.id}'),
                  icon: Icons.swap_horiz_rounded,
                  color: AppPalette.warning,
                  title: '查看交接班摘要',
                  subtitle: '回看本班交接项与后续责任转交。',
                  tag: '交接',
                  onTap: () => Get.toNamed(AppRoutes.handover),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('resident-open-ai-${resident.id}'),
                  icon: Icons.auto_awesome_rounded,
                  color: AppPalette.info,
                  title: '查看 AI 解释与建议',
                  subtitle: '围绕同一对象生成解释和建议，但不自动执行。',
                  tag: 'AI',
                  onTap: () => Get.toNamed(
                    AppRoutes.aiAssist,
                    arguments: {
                      'source': 'resident-detail',
                      'resident': resident.name,
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResidentHero extends StatelessWidget {
  const _ResidentHero({required this.detail, super.key});

  final ResidentDetail detail;

  @override
  Widget build(BuildContext context) {
    final resident = detail.snapshot;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppPalette.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.elderly_rounded, color: AppPalette.white, size: 28),
              ),
              const SizedBox(width: 14),
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
                      '${resident.room} · ${detail.age}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppPalette.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroPill(label: detail.mobility),
              _HeroPill(label: detail.dietNote),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              resident.riskNote,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppPalette.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppPalette.white,
        ),
      ),
    );
  }
}

class _WatchItemCard extends StatelessWidget {
  const _WatchItemCard({required this.index, required this.content, super.key});

  final int index;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppPalette.mint,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppPalette.moss,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(content, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(content, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CareNoteRow extends StatelessWidget {
  const _CareNoteRow({required this.content});

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
            color: AppPalette.moss,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(content, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}