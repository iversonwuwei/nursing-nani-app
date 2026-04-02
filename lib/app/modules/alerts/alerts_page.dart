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

class AlertsController extends GetxController {
  AlertsController(this._service);

  final MockNaniService _service;
  final selectedStatus = 'all'.obs;
  final draftDecision = RxnString();
  Object? incomingDraft;

  @override
  void onInit() {
    syncIncomingDraft(Get.arguments);
    super.onInit();
  }

  void syncIncomingDraft(dynamic argument) {
    if (argument is CareExecutionFollowupDraft) {
      _assignIncomingDraft(argument);
      return;
    }

    if (argument is HealthEntryFollowupDraft) {
      _assignIncomingDraft(argument);
      return;
    }

    if (argument is Map<String, dynamic> && argument['draft'] is CareExecutionFollowupDraft) {
      _assignIncomingDraft(argument['draft'] as CareExecutionFollowupDraft);
      return;
    }

    if (argument is Map<String, dynamic> && argument['draft'] is HealthEntryFollowupDraft) {
      _assignIncomingDraft(argument['draft'] as HealthEntryFollowupDraft);
    }
  }

  void _assignIncomingDraft(Object nextDraft) {
    final draftChanged = incomingDraftIdentity != _draftIdentity(nextDraft);
    incomingDraft = nextDraft;
    if (draftChanged) {
      draftDecision.value = null;
    }
  }

  String? get incomingDraftIdentity => _draftIdentity(incomingDraft);

  String? _draftIdentity(Object? draft) {
    if (draft is CareExecutionFollowupDraft) {
      return 'care-${draft.taskId}';
    }
    if (draft is HealthEntryFollowupDraft) {
      return 'health-${draft.residentId}-${draft.metricHighlights.join('|')}';
    }
    return null;
  }

  void promoteIncomingDraft() {
    draftDecision.value = 'promoted';
    selectedStatus.value = '待到场';
  }

  AlertEscalationDraft? buildEscalationDraft() {
    final draft = incomingDraft;
    if (draft is CareExecutionFollowupDraft) {
      final owner = draft.priority == 'P1' ? '值班护士 赵敏' : '责任护工 林晓雯';
      final arrivalBy = draft.priority == 'P1' ? '10 分钟内到场' : '30 分钟内到场';
      return AlertEscalationDraft(
        source: 'care-execution',
        residentName: draft.residentName,
        title: draft.taskTitle,
        priority: draft.priority,
        summary: draft.alertDetail,
        traceLabel: draft.evidenceSummary,
        recommendedOwner: owner,
        recommendedArrivalBy: arrivalBy,
      );
    }

    if (draft is HealthEntryFollowupDraft) {
      final owner = draft.priority == 'P1' ? '值班护士 赵敏' : '责任护工 林晓雯';
      final arrivalBy = draft.priority == 'P1' ? '10 分钟内到场' : '30 分钟内到场';
      return AlertEscalationDraft(
        source: 'health-entry',
        residentName: draft.residentName,
        title: '健康录入高风险结果',
        priority: draft.priority,
        summary: draft.alertDetail,
        traceLabel: draft.metricHighlights.join('；'),
        recommendedOwner: owner,
        recommendedArrivalBy: arrivalBy,
      );
    }

    return null;
  }

  void keepIncomingDraftUnderObservation() {
    draftDecision.value = 'observed';
    selectedStatus.value = '处理中';
  }

  bool get hasDraftDecision => draftDecision.value != null;

  String get draftDecisionTitle {
    if (draftDecision.value == 'promoted') {
      return '已转为正式事件草稿';
    }

    return '已保留为观察项';
  }

  String get draftDecisionSummary {
    final draft = incomingDraft;
    if (draft is CareExecutionFollowupDraft) {
      if (draftDecision.value == 'promoted') {
        return '${draft.residentName} 的 ${draft.taskTitle} 已进入正式事件草稿，下一步应由值班护士或主管确认责任人与到场时限。';
      }

      return '${draft.residentName} 的 ${draft.taskTitle} 暂不升级正式事件，当前保留在观察链路中，需继续巡视并同步交接班。';
    }

    if (draft is HealthEntryFollowupDraft) {
      if (draftDecision.value == 'promoted') {
        return '${draft.residentName} 的健康录入异常已进入正式事件草稿，下一步应由值班护士确认是否需要现场评估与升级处理。';
      }

      return '${draft.residentName} 的健康录入异常暂保留为观察项，需继续复测并在交接班中同步风险变化。';
    }

    if (draft == null) {
      return '';
    }
    return '';
  }

  List<AlertCase> get alerts => _service.alerts;

  List<AlertCase> get visibleAlerts {
    final items = [...alerts];
    items.sort((left, right) {
      final statusDiff = _statusRank(left.status).compareTo(_statusRank(right.status));
      if (statusDiff != 0) {
        return statusDiff;
      }
      return _levelRank(left.level).compareTo(_levelRank(right.level));
    });

    if (selectedStatus.value == 'all') {
      return items;
    }

    return items.where((alert) => alert.status == selectedStatus.value).toList();
  }

  void selectStatus(String status) {
    selectedStatus.value = status;
  }

  int _statusRank(String status) {
    switch (status) {
      case '待到场':
        return 0;
      case '处理中':
        return 1;
      default:
        return 2;
    }
  }

  int _levelRank(String level) {
    switch (level) {
      case 'P1':
        return 0;
      case 'P2':
        return 1;
      default:
        return 2;
    }
  }
}

class AlertsView extends GetView<AlertsController> {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.syncIncomingDraft(Get.arguments);
    return NaniScaffold(
      title: '报警处理',
      subtitle: '报警只建议处理动作，不自动结案，责任人和时间点必须保留。',
      child: Obx(
        () {
          final visibleAlerts = controller.visibleAlerts;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.incomingDraft != null) ...[
                _DraftAlertBanner(controller: controller, draft: controller.incomingDraft!),
                const SizedBox(height: 16),
              ],
              SurfaceCard(
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppPalette.coral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppPalette.danger,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('当前存在 2 条需要人工跟进的事件', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('先到场确认，再决定是否升级为正式事件。', style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: '报警列表',
                subtitle: '保持待处理、处理中、已结案状态清晰，并带出 AI 的建议边界。',
              ),
              const SizedBox(height: 14),
              _AlertFilters(
                selectedStatus: controller.selectedStatus.value,
                onSelected: controller.selectStatus,
              ),
              const SizedBox(height: 24),
              if (visibleAlerts.isEmpty)
                const _AlertsEmptyState()
              else
                ...visibleAlerts.map(
                  (alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AlertCaseCard(
                      key: ValueKey('alert-card-${alert.id}'),
                      alert: alert,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DraftAlertBanner extends StatelessWidget {
  const _DraftAlertBanner({required this.controller, required this.draft});

  final AlertsController controller;
  final Object draft;

  @override
  Widget build(BuildContext context) {
    final isCareDraft = draft is CareExecutionFollowupDraft;
    final careDraft = isCareDraft ? draft as CareExecutionFollowupDraft : null;
    final healthDraft = draft is HealthEntryFollowupDraft ? draft as HealthEntryFollowupDraft : null;

    return SurfaceCard(
      key: ValueKey(isCareDraft ? 'alert-care-execution-banner' : 'alert-health-entry-banner'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_share_rounded, color: AppPalette.danger),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCareDraft ? '来自护理执行的异常跟进草稿' : '来自健康录入的异常跟进草稿',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusChip(
                label: careDraft?.priority ?? healthDraft?.priority ?? '健康异常',
                color: (careDraft?.priority ?? healthDraft?.priority) == 'P1'
                    ? AppPalette.danger
                    : AppPalette.warning,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isCareDraft
                ? '${careDraft!.residentName} · ${careDraft.taskTitle}'
                : '${healthDraft!.residentName} · 健康录入高风险结果',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 6),
          Text(
            isCareDraft ? careDraft!.evidenceSummary : healthDraft!.metricHighlights.join('；'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            isCareDraft ? '待人工判断：${careDraft!.alertDetail}' : '待人工判断：${healthDraft!.riskSignals.join('、')}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              FlowActionCard(
                key: const ValueKey('alert-draft-promote'),
                icon: Icons.notification_important_rounded,
                color: AppPalette.danger,
                title: '创建正式事件',
                subtitle: '进入正式报警责任链，后续由值班护士或主管确认到场时限与责任人。',
                tag: '升级',
                onTap: () {
                  controller.promoteIncomingDraft();
                  final escalationDraft = controller.buildEscalationDraft();
                  if (escalationDraft != null) {
                    Get.toNamed(
                      AppRoutes.alertDetail,
                      arguments: {'draft': escalationDraft},
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              FlowActionCard(
                key: const ValueKey('alert-draft-observe'),
                icon: Icons.visibility_rounded,
                color: AppPalette.warning,
                title: '仅保留观察',
                subtitle: '暂不升级正式事件，继续在观察链路中跟进并同步交接班。',
                tag: '观察',
                onTap: controller.keepIncomingDraftUnderObservation,
              ),
            ],
          ),
          Obx(() {
            controller.draftDecision.value;
            if (!controller.hasDraftDecision) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                key: const ValueKey('alert-draft-decision-card'),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: controller.draftDecision.value == 'promoted'
                      ? AppPalette.coral.withValues(alpha: 0.14)
                      : AppPalette.sky.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppPalette.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.draftDecisionTitle, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(controller.draftDecisionSummary, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AlertFilters extends StatelessWidget {
  const _AlertFilters({
    required this.selectedStatus,
    required this.onSelected,
  });

  final String selectedStatus;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _AlertFilterChip(
          filter: 'all',
          label: '全部报警',
          selectedStatus: selectedStatus,
          onSelected: onSelected,
          color: AppPalette.moss,
        ),
        _AlertFilterChip(
          filter: '待到场',
          label: '待到场',
          selectedStatus: selectedStatus,
          onSelected: onSelected,
          color: AppPalette.danger,
        ),
        _AlertFilterChip(
          filter: '处理中',
          label: '处理中',
          selectedStatus: selectedStatus,
          onSelected: onSelected,
          color: AppPalette.warning,
        ),
        _AlertFilterChip(
          filter: '已结案',
          label: '已结案',
          selectedStatus: selectedStatus,
          onSelected: onSelected,
          color: AppPalette.moss,
        ),
      ],
    );
  }
}

class _AlertFilterChip extends StatelessWidget {
  const _AlertFilterChip({
    required this.filter,
    required this.label,
    required this.selectedStatus,
    required this.onSelected,
    required this.color,
  });

  final String filter;
  final String label;
  final String selectedStatus;
  final ValueChanged<String> onSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final selected = filter == selectedStatus;
    return GestureDetector(
      key: ValueKey('alert-filter-$filter'),
      onTap: () => onSelected(filter),
      child: StatusChip(
        label: label,
        color: selected ? AppPalette.white : color,
        backgroundColor: selected ? color : AppPalette.white,
      ),
    );
  }
}

class _AlertsEmptyState extends StatelessWidget {
  const _AlertsEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_off_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前筛选下没有报警', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '可以切回全部报警继续查看，或等待新的事件进入本班次责任范围。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AlertCaseCard extends StatelessWidget {
  const _AlertCaseCard({required this.alert, super.key});

  final AlertCase alert;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
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
                    Text(alert.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      '${alert.residentName} · ${alert.time}',
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppPalette.cream,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_alt_rounded, color: AppPalette.info),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(alert.recommendedAction, style: Theme.of(context).textTheme.bodyMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: ValueKey('alert-open-detail-${alert.id}'),
                  onPressed: () => Get.toNamed(AppRoutes.alertDetail, arguments: alert.id),
                  child: const Text('查看详情'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  key: ValueKey('alert-open-ai-${alert.id}'),
                  onPressed: () => Get.toNamed(
                    AppRoutes.aiAssist,
                    arguments: {
                      'source': 'alerts',
                      'resident': alert.residentName,
                    },
                  ),
                  child: const Text('查看 AI 建议'),
                ),
              ),
            ],
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