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

class HandoffController extends GetxController {
  HandoffController(this._service);

  final MockNaniService _service;
  final completedSteps = <int>{}.obs;
  late String handoffId;

  @override
  void onInit() {
    final argument = Get.arguments;
    handoffId = argument is String ? argument : _service.handoverItems.first.id;
    super.onInit();
  }

  HandoffDetail get detail => _service.findHandoffDetailById(handoffId);

  void toggleStep(int index) {
    if (completedSteps.contains(index)) {
      completedSteps.remove(index);
    } else {
      completedSteps.add(index);
    }
  }
}

class HandoffView extends GetView<HandoffController> {
  const HandoffView({super.key});

  @override
  Widget build(BuildContext context) {
    final detail = controller.detail;
    final item = detail.item;

    return Scaffold(
      body: NaniScaffold(
        title: '交接详情',
        subtitle: '把责任人、确认项和升级边界写清楚，交接结果才能真正可追踪。',
        actions: [
          StatusChip(
            label: item.priority,
            color: item.priority == '高' ? AppPalette.danger : AppPalette.warning,
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HandoffHero(
              key: ValueKey('handoff-hero-${item.id}'),
              detail: detail,
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '人工确认清单',
              subtitle: '交接完成必须对应到可勾选的动作，而不是一段模糊描述。',
            ),
            const SizedBox(height: 14),
            Obx(
              () {
                final completedCount = controller.completedSteps.length;
                if (detail.confirmationSteps.isEmpty) {
                  return const _HandoffStepsEmptyState();
                }

                return Column(
                  key: ValueKey('handoff-steps-${item.id}-$completedCount'),
                  children: List.generate(detail.confirmationSteps.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ConfirmStepCard(
                        key: ValueKey('handoff-step-${item.id}-$index'),
                        content: detail.confirmationSteps[index],
                        done: controller.completedSteps.contains(index),
                        onTap: () => controller.toggleStep(index),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '升级边界',
              subtitle: 'AI 可以起草说明，但不能替代人工确认与责任转交。',
            ),
            const SizedBox(height: 14),
            SurfaceCard(
              key: ValueKey('handoff-escalation-${item.id}'),
              child: Text(detail.escalationNote, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '下一步动作',
              subtitle: '从交接详情可以继续去看对象详情或生成 AI 草稿，但最终确认仍保留人工。',
            ),
            const SizedBox(height: 14),
            Column(
              children: [
                FlowActionCard(
                  key: ValueKey('handoff-record-confirm-${item.id}'),
                  icon: Icons.verified_rounded,
                  color: AppPalette.moss,
                  title: '记录人工确认',
                  subtitle: '保留责任护工或主管的最终口头确认结果。',
                  tag: '确认',
                  onTap: () => Get.snackbar('交接确认已记录', '请继续由责任护工或主管完成最终口头确认'),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('handoff-open-resident-${item.id}'),
                  icon: Icons.elderly_rounded,
                  color: AppPalette.info,
                  title: '查看长者详情',
                  subtitle: '回看对象风险、观察重点和关联护理动作。',
                  tag: '对象',
                  onTap: () => Get.toNamed(AppRoutes.residentDetail, arguments: item.relatedResidentId),
                ),
                const SizedBox(height: 12),
                FlowActionCard(
                  key: ValueKey('handoff-open-ai-${item.id}'),
                  icon: Icons.auto_awesome_rounded,
                  color: AppPalette.warning,
                  title: '生成 AI 交接草稿',
                  subtitle: '在当前对象上下文里补一版解释草稿，不自动结案。',
                  tag: 'AI',
                  onTap: () => Get.toNamed(
                    AppRoutes.aiAssist,
                    arguments: {
                      'source': 'handoff-detail',
                      'resident': item.residentName,
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

class _HandoffHero extends StatelessWidget {
  const _HandoffHero({required this.detail, super.key});

  final HandoffDetail detail;

  @override
  Widget build(BuildContext context) {
    final item = detail.item;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.accent,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.residentName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppPalette.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.topic,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppPalette.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            item.detail,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppPalette.white,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroMetaPill(key: const ValueKey('handoff-meta-owner'), label: detail.owner),
              _HeroMetaPill(key: const ValueKey('handoff-meta-due'), label: detail.dueBy),
              _HeroMetaPill(key: const ValueKey('handoff-meta-updated'), label: detail.lastUpdated),
            ],
          ),
        ],
      ),
    );
  }
}

class _HandoffStepsEmptyState extends StatelessWidget {
  const _HandoffStepsEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('handoff-steps-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.rule_folder_outlined, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有人工确认项', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('当交接单还未生成明确确认动作时，这里会明确显示为空态。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HeroMetaPill extends StatelessWidget {
  const _HeroMetaPill({required this.label, super.key});

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
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppPalette.white),
      ),
    );
  }
}

class _ConfirmStepCard extends StatelessWidget {
  const _ConfirmStepCard({
    required this.content,
    required this.done,
    required this.onTap,
    super.key,
  });

  final String content;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? AppPalette.moss : AppPalette.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(content, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}