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

class CareCheckinController extends GetxController {
  CareCheckinController(this._service);

  final MockNaniService _service;
  final selectedMethod = ''.obs;
  final arrivalConfirmed = false.obs;
  final locationController = TextEditingController();
  final exceptionController = TextEditingController();
  final submittedDraft = Rxn<CareClockInDraft>();
  final _formVersion = 0.obs;
  late String taskId;

  int get formVersion => _formVersion.value;

  CareTask get task => _service.findTaskById(taskId);

  @override
  void onInit() {
    final argument = Get.arguments;
    if (argument is String) {
      taskId = argument;
    } else if (argument is Map<String, dynamic> && argument['taskId'] is String) {
      taskId = argument['taskId'] as String;
    } else {
      taskId = _service.todayTasks.first.id;
    }

    final existingDraft = _service.findClockInDraft(taskId);
    if (existingDraft != null) {
      selectedMethod.value = existingDraft.method;
      arrivalConfirmed.value = existingDraft.arrivalConfirmed;
      locationController.text = existingDraft.locationLabel;
      exceptionController.text = existingDraft.exceptionNote ?? '';
      submittedDraft.value = existingDraft;
    }

    locationController.addListener(_touchForm);
    exceptionController.addListener(_touchForm);
    super.onInit();
  }

  @override
  void onClose() {
    locationController.dispose();
    exceptionController.dispose();
    super.onClose();
  }

  List<String> get validationIssues {
    final issues = <String>[];

    if (selectedMethod.value.isEmpty) {
      issues.add('请选择打卡方式。');
    }

    if (!arrivalConfirmed.value) {
      issues.add('请确认已到场并完成对象核对。');
    }

    if (locationController.text.trim().isEmpty) {
      issues.add('请补充服务位置，避免后续追溯不到到场点位。');
    }

    if (selectedMethod.value == '手工补录' && exceptionController.text.trim().isEmpty) {
      issues.add('手工补录时请写明原因。');
    }

    return issues;
  }

  void selectMethod(String method) {
    selectedMethod.value = method;
    _touchForm();
  }

  void toggleArrivalConfirmed() {
    arrivalConfirmed.value = !arrivalConfirmed.value;
    _touchForm();
  }

  void submit() {
    final issues = validationIssues;
    if (issues.isNotEmpty) {
      showValidationError(issues);
      return;
    }

    final draft = CareClockInDraft(
      taskId: task.id,
      taskTitle: task.title,
      residentName: task.residentName,
      room: task.room,
      method: selectedMethod.value,
      locationLabel: locationController.text.trim(),
      checkedInAtLabel: _nowLabel(),
      arrivalConfirmed: arrivalConfirmed.value,
      exceptionNote: exceptionController.text.trim().isEmpty
          ? null
          : exceptionController.text.trim(),
    );
    submittedDraft.value = _service.saveClockInDraft(draft);
    _touchForm();

    Get.snackbar(
      '打卡已完成',
      '到场确认已保存，可继续进入护理执行或按异常说明进入跟进。',
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
      '暂不能提交打卡',
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

  String _nowLabel() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class CareCheckinView extends GetView<CareCheckinController> {
  const CareCheckinView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '服务打卡',
        subtitle: '先完成到场确认，再进入护理执行，避免只有执行备注没有服务到场留痕。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckinTaskHeader(
              key: ValueKey('care-checkin-header-${controller.task.id}'),
              task: controller.task,
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '打卡方式',
              subtitle: '选择当前实际使用的到场确认方式，手工补录需要额外说明。',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const ['扫码', 'NFC', '手工补录']
                  .map(
                    (method) => _MethodChip(
                      method: method,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('服务位置', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '记录当前到场点位或床位，方便后续主管复核和异常回放。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('care-checkin-location-input'),
                    controller: controller.locationController,
                    decoration: InputDecoration(
                      hintText: '例如 2A-305 床旁 / 康复训练区 A 点',
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
                ],
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => SurfaceCard(
                child: InkWell(
                  key: const ValueKey('care-checkin-confirm-arrival'),
                  onTap: controller.toggleArrivalConfirmed,
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Icon(
                        controller.arrivalConfirmed.value
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: controller.arrivalConfirmed.value
                            ? AppPalette.moss
                            : AppPalette.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('已到场并完成对象核对', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(
                              '确认长者、房间和当前任务一致，再进入执行。',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('异常或补录说明', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    '当扫码失败、临时改点位或需手工补录时，在这里写清原因。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('care-checkin-exception-input'),
                    controller: controller.exceptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '例如：NFC 识别失败，已由责任护工手工补录并电话通知组长。',
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
            const SizedBox(height: 12),
            Obx(() {
              controller.formVersion;
              final issues = controller.validationIssues;
              if (issues.isEmpty) {
                return const SizedBox.shrink();
              }

              return SurfaceCard(
                key: const ValueKey('care-checkin-submit-blocker'),
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
                key: const ValueKey('care-checkin-submit'),
                onPressed: () {
                  if (issues.isEmpty) {
                    controller.submit();
                  }
                },
                child: Text(issues.isEmpty ? '完成服务打卡' : '补齐后完成打卡'),
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
                    title: '打卡摘要',
                    subtitle: '当前服务到场信息已保存，可继续进入护理执行或按异常说明进入跟进。',
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    key: const ValueKey('care-checkin-summary'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fact_check_outlined, color: AppPalette.moss),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('已生成打卡摘要', style: Theme.of(context).textTheme.titleMedium),
                            ),
                            StatusChip(label: draft.method, color: AppPalette.info),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('${draft.residentName} · ${draft.taskTitle}', style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        Text(draft.summaryLabel, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: const ValueKey('care-checkin-open-care-execution'),
                    icon: Icons.play_circle_fill_rounded,
                    color: AppPalette.coral,
                    title: '继续护理执行',
                    subtitle: '把当前打卡摘要带入执行页，继续留证和结果提交。',
                    tag: '执行',
                    onTap: () => Get.toNamed(
                      AppRoutes.careExecution,
                      arguments: {
                        'taskId': draft.taskId,
                        'clockInDraft': draft,
                      },
                    ),
                  ),
                  if (draft.exceptionNote?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    FlowActionCard(
                      key: const ValueKey('care-checkin-open-alerts'),
                      icon: Icons.warning_amber_rounded,
                      color: AppPalette.danger,
                      title: '按异常说明继续跟进',
                      subtitle: '若当前打卡已出现阻断，可直接进入报警处理继续人工判断。',
                      tag: '异常',
                      onTap: () => Get.toNamed(
                        AppRoutes.alerts,
                        arguments: CareExecutionFollowupDraft(
                          taskId: draft.taskId,
                          taskTitle: draft.taskTitle,
                          residentName: draft.residentName,
                          evidenceSummary: '服务打卡已完成，等待后续护理执行。',
                          note: draft.summaryLabel,
                          priority: controller.task.priority,
                          clockInSummary: draft.summaryLabel,
                          exceptionNote: draft.exceptionNote,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CheckinTaskHeader extends StatelessWidget {
  const _CheckinTaskHeader({required this.task, super.key});

  final CareTask task;

  @override
  Widget build(BuildContext context) {
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
            children: task.tags
                .map((tag) => StatusChip(label: tag, color: AppPalette.moss))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(task.nextAction, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class _MethodChip extends GetView<CareCheckinController> {
  const _MethodChip({required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedMethod.value == method;
      return GestureDetector(
        key: ValueKey('care-checkin-method-$method'),
        onTap: () => controller.selectMethod(method),
        child: StatusChip(
          label: method,
          color: selected ? AppPalette.white : AppPalette.info,
          backgroundColor: selected ? AppPalette.info : AppPalette.white,
        ),
      );
    });
  }
}