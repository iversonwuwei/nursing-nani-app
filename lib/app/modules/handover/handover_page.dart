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

class HandoverController extends GetxController {
  HandoverController(this._service);

  final MockNaniService _service;
  CareExecutionFollowupDraft? incomingDraft;

  @override
  void onInit() {
    syncIncomingDraft(Get.arguments);
    super.onInit();
  }

  void syncIncomingDraft(dynamic argument) {
    if (argument is CareExecutionFollowupDraft) {
      incomingDraft = argument;
      return;
    }

    if (argument is Map<String, dynamic> && argument['draft'] is CareExecutionFollowupDraft) {
      incomingDraft = argument['draft'] as CareExecutionFollowupDraft;
    }
  }

  List<HandoverItem> get items => _service.handoverItems;
  String get summary => _service.handoverSummary;
}

class HandoverView extends GetView<HandoverController> {
  const HandoverView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.syncIncomingDraft(Get.arguments);
    return Scaffold(
      body: NaniScaffold(
        title: '交接班',
        subtitle: '交接页保留重点对象、动作结果和人工确认，AI 只生成草稿。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.incomingDraft != null) ...[
              _ExecutionDraftBanner(draft: controller.incomingDraft!),
              const SizedBox(height: 16),
            ],
            SurfaceCard(
              key: const ValueKey('handover-summary-card'),
              child: Text(controller.summary, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '交接项',
              subtitle: '每条记录都要能回答“谁、何时、下一步做什么”。',
            ),
            const SizedBox(height: 14),
            if (controller.items.isEmpty)
              const _HandoverEmptyState()
            else
              ...controller.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _HandoverCard(
                    key: ValueKey('handover-card-${item.id}'),
                    item: item,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('handover-save-draft'),
              onPressed: () => Get.snackbar(
                '交接草稿已保存',
                controller.incomingDraft == null
                    ? '请由责任护工或主管完成最终确认'
                    : '已保留护理执行摘要，请由责任护工或主管完成最终确认',
              ),
              child: const Text('保存交接草稿'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExecutionDraftBanner extends StatelessWidget {
  const _ExecutionDraftBanner({required this.draft});

  final CareExecutionFollowupDraft draft;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('handover-care-execution-banner'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: AppPalette.moss),
              const SizedBox(width: 8),
              Expanded(
                child: Text('来自护理执行的交接草稿', style: Theme.of(context).textTheme.titleMedium),
              ),
              StatusChip(
                label: draft.priority,
                color: draft.priority == 'P1' ? AppPalette.danger : AppPalette.warning,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${draft.residentName} · ${draft.handoverTopic}', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text(draft.handoverDetail, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HandoverEmptyState extends StatelessWidget {
  const _HandoverEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('handover-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assignment_turned_in_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有待交接项', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('本班次暂无新增交接记录，可以直接保存空草稿或等待新的责任事项。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HandoverCard extends StatelessWidget {
  const _HandoverCard({required this.item, super.key});

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
          const SizedBox(height: 10),
          TextButton.icon(
            key: ValueKey('handover-open-detail-${item.id}'),
            onPressed: () => Get.toNamed(AppRoutes.handoff, arguments: item.id),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('查看交接详情'),
          ),
        ],
      ),
    );
  }
}