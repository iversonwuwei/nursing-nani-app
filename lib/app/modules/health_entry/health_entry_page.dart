import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/config/health_risk_rules.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_health_recognition_service.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/flow_action_card.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class HealthEntryController extends GetxController {
  HealthEntryController(this._service);

  final MockNaniService _service;
  final selectedResidentIndex = 0.obs;
  final Map<String, String> currentValues = <String, String>{};
  final Map<String, TextEditingController> fieldControllers = <String, TextEditingController>{};
  final Map<String, HealthImageDraft> scanDrafts = <String, HealthImageDraft>{}.obs;
  final recognitionResult = Rxn<HealthRecognitionResult>();
  final ocrTextController = TextEditingController();
  final _formVersion = 0.obs;

  List<ResidentSnapshot> get residents => _service.residents;
  List<VitalDraft> get drafts => _service.vitalDrafts;
  List<HealthScanSlot> get scanSlots => defaultHealthScanSlots;

  @override
  void onInit() {
    final argument = Get.arguments;
    if (argument is String) {
      selectedResidentIndex.value = _service.findResidentIndexById(argument);
    }
    _initializeDraftControllers();
    ocrTextController.addListener(_touchForm);
    super.onInit();
  }

  @override
  void onClose() {
    for (final controller in fieldControllers.values) {
      controller.dispose();
    }
    ocrTextController.dispose();
    super.onClose();
  }

  void _initializeDraftControllers() {
    for (final draft in drafts) {
      currentValues[draft.label] = draft.lastValue;
      fieldControllers[draft.label] = TextEditingController(text: draft.lastValue)
        ..addListener(() {
          currentValues[draft.label] = fieldControllers[draft.label]!.text;
          _touchForm();
        });
    }
  }

  void selectResident(int index) {
    selectedResidentIndex.value = index;
    clearRecognitionDrafts(resetOcr: true);
  }

  void updateValue(String label, String value) {
    currentValues[label] = value;
    _touchForm();
  }

  void captureScan(HealthScanSlot slot, String sourceLabel) {
    scanDrafts[slot.id] = HealthImageDraft(
      slotId: slot.id,
      sourceLabel: sourceLabel,
      capturedAtLabel: _nowLabel(),
    );
    _touchForm();
  }

  void removeScan(String slotId) {
    scanDrafts.remove(slotId);
    _touchForm();
  }

  void clearRecognitionDrafts({bool resetOcr = false}) {
    scanDrafts.clear();
    recognitionResult.value = null;
    if (resetOcr) {
      ocrTextController.clear();
    }
    _touchForm();
  }

  void recognizeFromImages() {
    if (scanDrafts.isEmpty && ocrTextController.text.trim().isEmpty) {
      Get.snackbar(
        '暂不能识别',
        '请先补充至少一张读数图片或一段 OCR 摘要。',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppPalette.danger,
        colorText: AppPalette.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    recognitionResult.value = simulateHealthImageRecognition(
      residentName: selectedResident,
      drafts: drafts,
      imageDrafts: scanDrafts.values.toList(),
      rawOcrText: ocrTextController.text,
    );
    _touchForm();
  }

  void applyRecognitionResult() {
    final result = recognitionResult.value;
    if (result == null) {
      return;
    }

    for (final item in result.suggestions) {
      final controller = fieldControllers[item.label];
      if (controller == null) {
        continue;
      }
      controller.text = item.value;
      currentValues[item.label] = item.value;
    }
    _touchForm();
  }

  int get formVersion => _formVersion.value;

  String get selectedResident => residents[selectedResidentIndex.value].name;

  String get selectedResidentId => residents[selectedResidentIndex.value].id;

  HealthEntryFollowupDraft? get highRiskDraft {
    final assessment = evaluateHealthRisk(currentValues);
    if (!assessment.hasRisk) {
      return null;
    }

    return HealthEntryFollowupDraft(
      residentId: selectedResidentId,
      residentName: selectedResident,
      recognitionSummary: recognitionResult.value?.summary ?? '当前录入结果命中高风险阈值，需要继续人工确认。',
      priority: assessment.priority,
      metricHighlights: assessment.metricHighlights,
      riskSignals: assessment.riskSignals,
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

class HealthEntryView extends GetView<HealthEntryController> {
  const HealthEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '健康录入',
        subtitle: '先用图片识别快速带出体征，再由护工人工复核，减少重复抄录。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: '选择对象',
              subtitle: '健康录入和异常解释围绕同一位长者展开。',
            ),
            const SizedBox(height: 14),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(controller.residents.length, (index) {
                  final resident = controller.residents[index];
                  final selected = controller.selectedResidentIndex.value == index;
                  return GestureDetector(
                    key: ValueKey('health-entry-resident-${resident.id}'),
                    onTap: () => controller.selectResident(index),
                    child: StatusChip(
                      label: resident.name,
                      color: selected ? AppPalette.white : AppPalette.moss,
                      backgroundColor: selected ? AppPalette.moss : AppPalette.mint,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '图片识别自动填入',
              subtitle: '先补读数图片或 OCR 摘要，再生成识别建议并一键回填。',
            ),
            const SizedBox(height: 14),
            Obx(() {
              controller.formVersion;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HealthScanSummary(controller: controller),
                  const SizedBox(height: 12),
                  ...controller.scanSlots.map(
                    (slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HealthScanSlotCard(
                        slot: slot,
                        draft: controller.scanDrafts[slot.id],
                        onCapture: () => controller.captureScan(slot, '现场拍照'),
                        onGallery: () => controller.captureScan(slot, '相册补传'),
                        onRemove: () => controller.removeScan(slot.id),
                      ),
                    ),
                  ),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('OCR / 读数摘要', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          '支持粘贴设备 OCR 摘要，例如：血压 128/82，心率 78，血氧 97，体温 36.6。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('health-scan-ocr-input'),
                          controller: controller.ocrTextController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: '可粘贴 OCR、监护仪截图摘要或纸质记录单识别文本。',
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
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          key: const ValueKey('health-scan-recognize'),
                          onPressed: controller.recognizeFromImages,
                          icon: const Icon(Icons.document_scanner_outlined),
                          label: const Text('生成识别建议'),
                        ),
                      ],
                    ),
                  ),
                  if (controller.recognitionResult.value != null) ...[
                    const SizedBox(height: 12),
                    _RecognitionResultCard(controller: controller, result: controller.recognitionResult.value!),
                  ],
                ],
              );
            }),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '体征录入项',
              subtitle: '默认带出上次记录值，识别结果需人工确认后再写入表单。',
            ),
            const SizedBox(height: 14),
            if (controller.drafts.isEmpty)
              const _HealthEntryEmptyState()
            else
              ...controller.drafts.map(
                (draft) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VitalInputCard(
                    key: ValueKey('health-entry-draft-${draft.label}'),
                    draft: draft,
                    controller: controller.fieldControllers[draft.label]!,
                    onChanged: (value) => controller.updateValue(draft.label, value),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Obx(
              () => SurfaceCard(
                key: ValueKey('health-entry-current-${controller.selectedResident}'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.person_pin_circle_rounded, color: AppPalette.info),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '当前准备提交 ${controller.selectedResident} 的健康录入。高风险值仍需要人工确认是否升级报警。',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              controller.formVersion;
              final draft = controller.highRiskDraft;

              if (draft == null) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const SectionHeader(
                    title: '高风险后续联动',
                    subtitle: '高风险识别结果不能只停留在录入页，需继续进入 AI 解释或异常跟进。',
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    key: const ValueKey('health-followup-summary'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.monitor_heart_rounded, color: AppPalette.danger),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('已识别高风险体征', style: Theme.of(context).textTheme.titleMedium),
                            ),
                            StatusChip(label: '需复核', color: AppPalette.danger),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(draft.metricHighlights.join('；'), style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 6),
                        Text(draft.riskSignals.join('、'), style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: const ValueKey('health-followup-ai'),
                    icon: Icons.psychology_alt_rounded,
                    color: AppPalette.info,
                    title: '查看 AI 解释',
                    subtitle: '把本次高风险体征带入 AI 助手，生成解释和建议动作，但不替代人工判断。',
                    tag: 'AI',
                    onTap: () => Get.toNamed(
                      AppRoutes.aiAssist,
                      arguments: {
                        'source': 'health-entry',
                        'resident': draft.residentName,
                        'healthDraft': draft,
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FlowActionCard(
                    key: const ValueKey('health-followup-alert'),
                    icon: Icons.warning_amber_rounded,
                    color: AppPalette.danger,
                    title: '送入异常跟进',
                    subtitle: '将本次高风险录入结果送入报警处理页，继续人工判断是否创建正式事件。',
                    tag: '异常',
                    onTap: () => Get.toNamed(AppRoutes.alerts, arguments: draft),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            Obx(
              () => OutlinedButton.icon(
                key: ValueKey('health-entry-open-health-${controller.selectedResidentId}'),
                onPressed: () => Get.toNamed(
                  AppRoutes.health,
                  arguments: controller.selectedResidentId,
                ),
                icon: const Icon(Icons.show_chart_rounded),
                label: const Text('查看健康趋势'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              key: const ValueKey('health-entry-save-button'),
              onPressed: () => Get.snackbar('录入已暂存', '识别结果与人工复核值已暂存，下一步请结合 AI 解释决定是否升级'),
              child: const Text('暂存并生成解释'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthEntryEmptyState extends StatelessWidget {
  const _HealthEntryEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('health-entry-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.monitor_heart_outlined, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有可录入体征项', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('当本班没有体征模板下发时，这里会明确提示为空态。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HealthScanSummary extends StatelessWidget {
  const _HealthScanSummary({required this.controller});

  final HealthEntryController controller;

  @override
  Widget build(BuildContext context) {
    final uploadedCount = controller.scanDrafts.length;
    return SurfaceCard(
      key: const ValueKey('health-scan-summary'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppPalette.sky.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.qr_code_scanner_rounded, color: AppPalette.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('已准备识别素材 $uploadedCount 项', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text('优先补监护仪读数照；如果设备图片不清晰，可直接粘贴 OCR 文本生成识别建议。', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthScanSlotCard extends StatelessWidget {
  const _HealthScanSlotCard({
    required this.slot,
    required this.draft,
    required this.onCapture,
    required this.onGallery,
    required this.onRemove,
  });

  final HealthScanSlot slot;
  final HealthImageDraft? draft;
  final VoidCallback onCapture;
  final VoidCallback onGallery;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: ValueKey('health-scan-slot-${slot.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(slot.title, style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(
                label: slot.isRequired ? '必传' : '选传',
                color: slot.isRequired ? AppPalette.warning : AppPalette.info,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(slot.instruction, style: Theme.of(context).textTheme.bodyMedium),
          if (draft != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppPalette.mint.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppPalette.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.image_rounded, color: AppPalette.moss),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${draft!.sourceLabel} · ${draft!.capturedAtLabel}', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  IconButton(
                    key: ValueKey('health-scan-remove-${slot.id}'),
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                key: ValueKey('health-scan-capture-${slot.id}'),
                onPressed: onCapture,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(draft == null ? '现场拍照' : '重新拍照'),
              ),
              OutlinedButton.icon(
                key: ValueKey('health-scan-gallery-${slot.id}'),
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

class _RecognitionResultCard extends StatelessWidget {
  const _RecognitionResultCard({required this.controller, required this.result});

  final HealthEntryController controller;
  final HealthRecognitionResult result;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('health-scan-result'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('识别建议', style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(label: '置信度 ${result.confidence}%', color: AppPalette.info),
            ],
          ),
          const SizedBox(height: 8),
          Text(result.summary, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ...result.suggestions.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${item.label}：${item.value}', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  StatusChip(label: item.source, color: AppPalette.moss),
                ],
              ),
            ),
          ),
          if (result.missingLabels.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('仍需人工补录：${result.missingLabels.join('、')}', style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const ValueKey('health-scan-apply'),
            onPressed: controller.applyRecognitionResult,
            icon: const Icon(Icons.input_rounded),
            label: const Text('一键填入表单'),
          ),
        ],
      ),
    );
  }
}

class _VitalInputCard extends StatelessWidget {
  const _VitalInputCard({
    required this.draft,
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final VitalDraft draft;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(draft.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('上次记录 ${draft.lastValue} ${draft.unit}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('health-entry-input-${draft.label}'),
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: draft.placeholder,
              suffixText: draft.unit,
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
    );
  }
}