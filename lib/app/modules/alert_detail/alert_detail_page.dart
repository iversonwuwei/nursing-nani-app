import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class AlertDetailController extends GetxController {
  AlertDetailController(this._service);

  final MockNaniService _service;
  String? alertId;
  AlertEscalationDraft? incomingDraft;
  final selectedOwner = ''.obs;
  final selectedArrivalBy = ''.obs;
  final draftConfirmed = false.obs;
  final confirmationNoteController = TextEditingController();

  @override
  void onInit() {
    syncArguments(Get.arguments);
    super.onInit();
  }

  @override
  void onClose() {
    confirmationNoteController.dispose();
    super.onClose();
  }

  void syncArguments(dynamic argument) {
    if (argument is Map<String, dynamic> && argument['draft'] is AlertEscalationDraft) {
      _assignIncomingDraft(argument['draft'] as AlertEscalationDraft);
      return;
    }

    incomingDraft = null;
    alertId = argument is String ? argument : _service.alerts.first.id;
    draftConfirmed.value = false;
  }

  void _assignIncomingDraft(AlertEscalationDraft draft) {
    final draftChanged = incomingDraft?.residentName != draft.residentName || incomingDraft?.title != draft.title;
    incomingDraft = draft;
    alertId = null;
    if (draftChanged) {
      selectedOwner.value = draft.recommendedOwner;
      selectedArrivalBy.value = draft.recommendedArrivalBy;
      confirmationNoteController.clear();
      draftConfirmed.value = false;
    }
  }

  bool get hasIncomingDraft => incomingDraft != null;

  List<String> get ownerOptions => const ['责任护工 林晓雯', '值班护士 赵敏', '护理主管 何倩'];

  List<String> get arrivalOptions => const ['10 分钟内到场', '30 分钟内到场', '本班持续观察'];

  void selectOwner(String owner) {
    selectedOwner.value = owner;
  }

  void selectArrivalBy(String arrivalBy) {
    selectedArrivalBy.value = arrivalBy;
  }

  void confirmDraftEscalation() {
    if (incomingDraft == null) {
      return;
    }

    if (selectedOwner.value.isEmpty || selectedArrivalBy.value.isEmpty) {
      Get.snackbar(
        '还不能提交',
        '请先确认责任人和到场时限。',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppPalette.danger,
        colorText: AppPalette.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    draftConfirmed.value = true;
  }

  AlertCase get alert => _service.findAlertById(alertId ?? _service.alerts.first.id);
  List<AlertTimelineEntry> get timeline => alertId == null ? const [] : _service.findAlertTimeline(alertId!);
}

class AlertDetailView extends GetView<AlertDetailController> {
  const AlertDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.syncArguments(Get.arguments);
    final draft = controller.incomingDraft;
    final alert = controller.alert;
    return Scaffold(
      body: NaniScaffold(
        title: '报警详情',
        subtitle: '详情页展示责任人、处理动作和时间线，保证事件链路可追踪。',
        child: draft != null ? _DraftDetailBody(controller: controller, draft: draft) : _AlertDetailBody(controller: controller, alert: alert),
      ),
    );
  }
}

class _DraftDetailBody extends StatelessWidget {
  const _DraftDetailBody({required this.controller, required this.draft});

  final AlertDetailController controller;
  final AlertEscalationDraft draft;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            key: const ValueKey('alert-draft-detail-summary'),
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
                          Text('${draft.sourceLabel}升级草稿', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 6),
                          Text(
                            '${draft.residentName} · ${draft.title}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    StatusChip(label: draft.priority, color: _alertLevelColor(draft.priority)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(draft.summary, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 12),
                Container(
                  key: const ValueKey('alert-draft-trace-card'),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppPalette.cream,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text('上游证据：${draft.traceLabel}', style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '责任人和到场时限确认',
            subtitle: '正式事件进入责任链前，必须明确由谁处理、何时到场。',
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            key: const ValueKey('alert-draft-assignment-card'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('责任人', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.ownerOptions
                      .map(
                        (owner) => GestureDetector(
                          key: ValueKey('alert-draft-owner-$owner'),
                          onTap: () => controller.selectOwner(owner),
                          child: StatusChip(
                            label: owner,
                            color: controller.selectedOwner.value == owner ? AppPalette.white : AppPalette.info,
                            backgroundColor: controller.selectedOwner.value == owner ? AppPalette.info : AppPalette.white,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('到场时限', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.arrivalOptions
                      .map(
                        (arrivalBy) => GestureDetector(
                          key: ValueKey('alert-draft-arrival-$arrivalBy'),
                          onTap: () => controller.selectArrivalBy(arrivalBy),
                          child: StatusChip(
                            label: arrivalBy,
                            color: controller.selectedArrivalBy.value == arrivalBy ? AppPalette.white : AppPalette.warning,
                            backgroundColor: controller.selectedArrivalBy.value == arrivalBy ? AppPalette.warning : AppPalette.white,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const ValueKey('alert-draft-note-input'),
                  controller: controller.confirmationNoteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: '补充人工说明，例如已联系护士、需携带设备或复测前置条件。',
                    filled: true,
                    fillColor: AppPalette.cream,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppPalette.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: AppPalette.info, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  key: const ValueKey('alert-draft-confirm-button'),
                  onPressed: controller.confirmDraftEscalation,
                  icon: const Icon(Icons.assignment_turned_in_rounded),
                  label: const Text('确认正式事件责任链'),
                ),
              ],
            ),
          ),
          if (controller.draftConfirmed.value) ...[
            const SizedBox(height: 14),
            SurfaceCard(
              key: const ValueKey('alert-draft-confirmed-card'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('已确认责任链', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    '${draft.residentName} 由 ${controller.selectedOwner.value} 负责，要求 ${controller.selectedArrivalBy.value}；${controller.confirmationNoteController.text.trim().isEmpty ? '当前未补充额外说明。' : controller.confirmationNoteController.text.trim()}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: const ValueKey('alert-draft-open-ai'),
                  onPressed: () => Get.toNamed(
                    AppRoutes.aiAssist,
                    arguments: {
                      'source': 'alert-detail',
                      'resident': draft.residentName,
                    },
                  ),
                  child: const Text('查看 AI 解释'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertDetailBody extends StatelessWidget {
  const _AlertDetailBody({required this.controller, required this.alert});

  final AlertDetailController controller;
  final AlertCase alert;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SurfaceCard(
          key: ValueKey('alert-detail-summary-${alert.id}'),
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
                        Text(alert.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          '${alert.residentName} · ${alert.time} · 责任人 ${alert.owner}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StatusChip(label: alert.level, color: _alertLevelColor(alert.level)),
                      const SizedBox(height: 8),
                      StatusChip(label: alert.status, color: _alertStatusColor(alert.status)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(alert.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              Container(
                key: ValueKey('alert-detail-action-${alert.id}'),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppPalette.cream,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(alert.recommendedAction, style: Theme.of(context).textTheme.bodyMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(
          title: '处理时间线',
          subtitle: '时间线必须保留触发、分派、人工确认和结案过程。',
        ),
        const SizedBox(height: 14),
        if (controller.timeline.isEmpty)
          const _AlertTimelineEmptyState()
        else
          ...controller.timeline.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TimelineCard(
                key: ValueKey('alert-timeline-${entry.key}'),
                entry: entry.value,
                isLast: entry.key == controller.timeline.length - 1,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: ValueKey('alert-open-ai-${alert.id}'),
                onPressed: () => Get.toNamed(
                  AppRoutes.aiAssist,
                  arguments: {
                    'source': 'alert-detail',
                    'resident': alert.residentName,
                  },
                ),
                child: const Text('查看 AI 解释'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                key: ValueKey('alert-manual-result-${alert.id}'),
                onPressed: () => Get.snackbar('人工处理保留', '当前示例不自动结案，请继续人工确认'),
                child: const Text('补充处理结果'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AlertTimelineEmptyState extends StatelessWidget {
  const _AlertTimelineEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('alert-timeline-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.timeline_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有处理时间线', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('当事件还未生成触发到结案链路时，这里会明确显示为空态。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.entry, required this.isLast, super.key});

  final AlertTimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppPalette.moss,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 64,
                color: isLast ? Colors.transparent : AppPalette.line,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('${entry.time} · ${entry.actor}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(entry.detail, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _alertLevelColor(String level) {
  switch (level) {
    case 'P1':
      return AppPalette.danger;
    case 'P2':
      return AppPalette.warning;
    default:
      return AppPalette.info;
  }
}

Color _alertStatusColor(String status) {
  switch (status) {
    case '处理中':
      return AppPalette.warning;
    case '待到场':
      return AppPalette.danger;
    default:
      return AppPalette.moss;
  }
}