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

class CareExecutionController extends GetxController {
  CareExecutionController(this._service);

  final MockNaniService _service;
  final completedSteps = <int>{}.obs;
  final evidenceDrafts = <String, CareEvidenceDraft>{}.obs;
  final noteController = TextEditingController();
  final evidenceExceptionController = TextEditingController();
  final _formVersion = 0.obs;
  final submittedDraft = Rxn<CareExecutionFollowupDraft>();
  late String taskId;

  final List<String> steps = const [
    '到场核对长者身份与任务目标',
    '执行护理动作并观察即时反应',
    '确认留证、备注和交接提示已补全',
  ];

  @override
  void onInit() {
    final argument = Get.arguments;
    taskId = argument is String ? argument : _service.todayTasks.first.id;
    noteController.addListener(_touchForm);
    evidenceExceptionController.addListener(_touchForm);
    super.onInit();
  }

  @override
  void onClose() {
    noteController.dispose();
    evidenceExceptionController.dispose();
    super.onClose();
  }

  CareTask get task => _service.findTaskById(taskId);

  List<CareEvidenceRequirement> get evidenceRequirements => task.evidenceRequirements;

  int get requiredEvidenceCount =>
      evidenceRequirements.where((item) => item.isRequired).length;

  int get completedEvidenceCount =>
      evidenceRequirements.where((item) => evidenceDrafts.containsKey(item.id)).length;

  List<CareEvidenceRequirement> get missingRequiredEvidence => evidenceRequirements
      .where((item) => item.isRequired && !evidenceDrafts.containsKey(item.id))
      .toList();

  List<String> get validationIssues {
    final issues = <String>[];

    if (steps.isNotEmpty && completedSteps.length != steps.length) {
      issues.add('请先完成全部执行步骤，再提交结果。');
    }

    if (missingRequiredEvidence.isNotEmpty && evidenceExceptionController.text.trim().isEmpty) {
      issues.add('缺少必传留证：${missingRequiredEvidence.map((item) => item.title).join('、')}。');
    }

    if (evidenceRequirements.isNotEmpty && noteController.text.trim().isEmpty) {
      issues.add('请补充执行结果备注，说明耐受情况或异常处理。');
    }

    return issues;
  }

  int get formVersion => _formVersion.value;

  void toggleStep(int index) {
    if (completedSteps.contains(index)) {
      completedSteps.remove(index);
    } else {
      completedSteps.add(index);
    }
    _touchForm();
  }

  void captureEvidence(CareEvidenceRequirement requirement, String sourceLabel) {
    evidenceDrafts[requirement.id] = CareEvidenceDraft(
      slotId: requirement.id,
      sourceLabel: sourceLabel,
      capturedAtLabel: _nowLabel(),
    );
    _touchForm();
  }

  void removeEvidence(String slotId) {
    evidenceDrafts.remove(slotId);
    _touchForm();
  }

  void applySuggestedNote(String value) {
    final current = noteController.text.trim();
    if (current.contains(value)) {
      return;
    }

    final nextValue = current.isEmpty ? value : '$current；$value';
    noteController
      ..text = nextValue
      ..selection = TextSelection.collapsed(offset: nextValue.length);
  }

  void submit() {
    final issues = validationIssues;
    if (issues.isNotEmpty) {
      showValidationError(issues);
      return;
    }

    submittedDraft.value = CareExecutionFollowupDraft(
      taskId: task.id,
      taskTitle: task.title,
      residentName: task.residentName,
      evidenceSummary: evidenceSummary,
      note: noteController.text.trim(),
      priority: task.priority,
      exceptionNote: evidenceExceptionController.text.trim().isEmpty
          ? null
          : evidenceExceptionController.text.trim(),
    );
    _touchForm();

    Get.snackbar(
      '任务已提交',
      '留证与执行结果已保存，请确认是否需要同步到交接班或报警链路',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppPalette.ink,
      colorText: AppPalette.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void showValidationError(List<String> issues) {
    if (issues.isEmpty) {
      return;
    }

    Get.snackbar(
      '暂不能提交',
      issues.first,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppPalette.danger,
      colorText: AppPalette.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _touchForm() {
    _formVersion.value++;
  }

  String get evidenceSummary {
    if (evidenceRequirements.isEmpty) {
      return '本次任务无需图片留证';
    }

    final completed = completedEvidenceCount;
    final total = evidenceRequirements.length;
    final exception = evidenceExceptionController.text.trim();
    final base = '已补留证 $completed / $total 项';

    if (exception.isEmpty) {
      return base;
    }

    return '$base，异常说明：$exception';
  }

  String _nowLabel() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class CareExecutionView extends GetView<CareExecutionController> {
  const CareExecutionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '护理执行',
        subtitle: '执行页先确认步骤和留证要求，再补执行结果，避免只有“已完成”没有证据链。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskHeader(
              key: ValueKey('care-task-header-${controller.task.id}'),
              task: controller.task,
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '执行步骤',
              subtitle: '每一步都应可确认，确保留痕和下一班可追踪。',
            ),
            const SizedBox(height: 14),
            Obx(() {
              final completedSteps = controller.completedSteps.toSet();

              if (controller.steps.isEmpty) {
                return const _CareExecutionEmptyState();
              }

              return Column(
                children: List.generate(controller.steps.length, (index) {
                  final step = controller.steps[index];
                  final done = completedSteps.contains(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChecklistCard(
                      key: ValueKey('care-step-$index'),
                      step: step,
                      done: done,
                      onTap: () => controller.toggleStep(index),
                    ),
                  );
                }),
              );
            }),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '留证上传',
              subtitle: '先看本任务需要拍什么，再选择现场拍照或相册补传。',
            ),
            const SizedBox(height: 14),
            Obx(() {
              controller.formVersion;

              if (controller.evidenceRequirements.isEmpty) {
                return const _NoEvidenceRequiredCard();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EvidenceSummaryCard(controller: controller),
                  const SizedBox(height: 12),
                  ...controller.evidenceRequirements.map(
                    (requirement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EvidenceSlotCard(
                        requirement: requirement,
                        draft: controller.evidenceDrafts[requirement.id],
                        onCapture: () => controller.captureEvidence(requirement, '现场拍照'),
                        onGallery: () => controller.captureEvidence(requirement, '相册补传'),
                        onRemove: () => controller.removeEvidence(requirement.id),
                      ),
                    ),
                  ),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.rule_rounded, color: AppPalette.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '留证异常说明',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.task.evidenceFallbackHint,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('care-evidence-exception-input'),
                          controller: controller.evidenceExceptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: '例如：长者拒绝拍照，仅允许文字留痕；已由责任护工和护士共同复核。',
                            filled: true,
                            fillColor: AppPalette.cream,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: AppPalette.line),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: AppPalette.warning, width: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),
            SurfaceCard(
              key: const ValueKey('care-note-card'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('执行结果备注', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '补充耐受情况、处理结果和下一班关注点。留证任务不建议只写“已完成”。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  if (controller.task.suggestedNotes.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(controller.task.suggestedNotes.length, (index) {
                        final note = controller.task.suggestedNotes[index];
                        return ActionChip(
                          key: ValueKey('care-note-suggestion-$index'),
                          label: Text(note),
                          onPressed: () => controller.applySuggestedNote(note),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    key: const ValueKey('care-note-input'),
                    controller: controller.noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '记录执行结果、耐受情况、异常处理与是否需要下一班继续观察。',
                      filled: true,
                      fillColor: AppPalette.cream,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppPalette.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppPalette.moss, width: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              controller.formVersion;
              final issues = controller.validationIssues;

              if (issues.isEmpty) {
                return const SizedBox.shrink();
              }

              return SurfaceCard(
                key: const ValueKey('care-submit-blocker'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppPalette.danger),
                        const SizedBox(width: 8),
                        Text('提交前仍缺少以下信息', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...issues.map(
                      (issue) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $issue', style: Theme.of(context).textTheme.bodyMedium),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              controller.formVersion;
              final issues = controller.validationIssues;

              return FilledButton(
                key: const ValueKey('care-submit-button'),
                onPressed: () {
                  if (issues.isEmpty) {
                    controller.submit();
                    return;
                  }

                  controller.showValidationError(issues);
                },
                child: Text(issues.isEmpty ? '提交执行结果' : '补齐后提交执行结果'),
              );
            }),
            Obx(() {
              controller.formVersion;
              final draft = controller.submittedDraft.value;

              if (draft == null) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: '后续联动',
                    subtitle: '本次护理执行已形成草稿，可继续送入交接班或异常跟进链路。',
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    key: const ValueKey('care-followup-summary'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: AppPalette.moss),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('已生成执行摘要', style: Theme.of(context).textTheme.titleMedium),
                            ),
                            StatusChip(
                              label: draft.priority,
                              color: draft.priority == 'P1' ? AppPalette.danger : AppPalette.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${draft.residentName} · ${draft.taskTitle}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        Text(draft.evidenceSummary, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Text('执行备注：${draft.note}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: const ValueKey('care-followup-handover'),
                    icon: Icons.how_to_reg_rounded,
                    color: AppPalette.moss,
                    title: '送入交接班草稿',
                    subtitle: '把本次留证和备注带到交接班页，补充下一班关注点。',
                    tag: '交接',
                    onTap: () => Get.toNamed(AppRoutes.handover, arguments: draft),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: const ValueKey('care-followup-alert'),
                    icon: Icons.warning_amber_rounded,
                    color: AppPalette.danger,
                    title: '升级为异常跟进',
                    subtitle: '把本次执行摘要带入报警处理页，继续人工判断是否创建正式事件。',
                    tag: '异常',
                    onTap: () => Get.toNamed(AppRoutes.alerts, arguments: draft),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CareExecutionEmptyState extends StatelessWidget {
  const _CareExecutionEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('care-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.play_circle_outline_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有待执行步骤', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '当任务步骤未下发时，这里会明确提示为空态，避免误判为加载失败。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _NoEvidenceRequiredCard extends StatelessWidget {
  const _NoEvidenceRequiredCard();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('care-evidence-summary'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppPalette.sky.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.image_not_supported_outlined, color: AppPalette.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本任务无需上传图片', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  '当前任务只需完成步骤和执行结果备注，不要求额外图片留证。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceSummaryCard extends StatelessWidget {
  const _EvidenceSummaryCard({required this.controller});

  final CareExecutionController controller;

  @override
  Widget build(BuildContext context) {
    final requiredCount = controller.requiredEvidenceCount;
    final completedCount = controller.completedEvidenceCount;
    final coverageLabel = requiredCount == 0
        ? '无需必传项'
        : '$completedCount / $requiredCount 项已补齐';

    return SurfaceCard(
      key: const ValueKey('care-evidence-summary'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppPalette.mint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.photo_camera_back_outlined, color: AppPalette.moss),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('本任务需留证 ${controller.evidenceRequirements.length} 项', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(coverageLabel, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              StatusChip(
                label: completedCount >= requiredCount ? '可提交' : '待补齐',
                color: completedCount >= requiredCount ? AppPalette.moss : AppPalette.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '优先完成必传图；现场无法拍照时，在下方补异常说明并写清原因、执行结果和复核人。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  const _TaskHeader({required this.task, super.key});

  final CareTask task;

  @override
  Widget build(BuildContext context) {
    final requiredEvidenceCount =
        task.evidenceRequirements.where((item) => item.isRequired).length;

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(task.title, style: Theme.of(context).textTheme.titleLarge)),
              StatusChip(
                label: task.priority,
                color: task.priority == 'P1' ? AppPalette.danger : AppPalette.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${task.residentName} · ${task.room} · ${task.dueTime}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...task.tags.map((tag) => StatusChip(label: tag, color: AppPalette.moss)),
              if (requiredEvidenceCount > 0)
                StatusChip(label: '必传留证 $requiredEvidenceCount 项', color: AppPalette.info),
            ],
          ),
          const SizedBox(height: 12),
          Text(task.nextAction, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.step,
    required this.done,
    required this.onTap,
    super.key,
  });

  final String step;
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
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: done ? AppPalette.moss : AppPalette.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(step, style: Theme.of(context).textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}

class _EvidenceSlotCard extends StatelessWidget {
  const _EvidenceSlotCard({
    required this.requirement,
    required this.draft,
    required this.onCapture,
    required this.onGallery,
    required this.onRemove,
  });

  final CareEvidenceRequirement requirement;
  final CareEvidenceDraft? draft;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: ValueKey('care-evidence-slot-${requirement.id}'),
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
                    Text(requirement.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(requirement.instruction, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(
                label: requirement.isRequired ? '必传' : '选传',
                color: requirement.isRequired ? AppPalette.warning : AppPalette.info,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (draft != null) ...[
            Container(
              key: ValueKey('care-evidence-preview-${requirement.id}'),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppPalette.mint.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppPalette.line),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.image_rounded, color: AppPalette.moss),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${draft!.sourceLabel}已完成', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('留证时间 ${draft!.capturedAtLabel}', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    key: ValueKey('care-evidence-remove-${requirement.id}'),
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: ValueKey('care-evidence-capture-${requirement.id}'),
                onPressed: onCapture,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(draft == null ? '现场拍照' : '重新拍照'),
              ),
              OutlinedButton.icon(
                key: ValueKey('care-evidence-gallery-${requirement.id}'),
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(draft == null ? '相册补传' : '改用相册'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CareEvidenceDraft {
  const CareEvidenceDraft({
    required this.slotId,
    required this.sourceLabel,
    required this.capturedAtLabel,
  });

  final String slotId;
  final String sourceLabel;
  final String capturedAtLabel;
}