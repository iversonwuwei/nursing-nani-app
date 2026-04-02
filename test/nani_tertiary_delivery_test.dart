import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/modules/care_execution/care_execution_page.dart';
import 'package:nursing_nani_app/app/modules/health_entry/health_entry_page.dart';
import 'package:nursing_nani_app/app/modules/residents/residents_page.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('opens residents page from home and reaches resident detail', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-quick-action-residents')));
    await tester.tap(find.byKey(const ValueKey('home-quick-action-residents')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('重点长者'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('resident-open-detail-resident-1')));
    await tester.tap(find.byKey(const ValueKey('resident-open-detail-resident-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('长者详情'), findsOneWidget);
    expect(find.byKey(const ValueKey('resident-detail-hero-resident-1')), findsOneWidget);
  });

  testWidgets('opens health entry and care execution from residents page', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.residents);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('resident-open-health-entry-resident-1')));
    await tester.tap(find.byKey(const ValueKey('resident-open-health-entry-resident-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('健康录入'), findsOneWidget);
    expect(find.textContaining('当前准备提交 王秀兰 的健康录入'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('resident-open-care-execution-resident-1')));
    await tester.tap(find.byKey(const ValueKey('resident-open-care-execution-resident-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('护理执行'), findsOneWidget);
    expect(find.text('晨间生命体征复测'), findsOneWidget);
  });

  testWidgets('opens health entry and ai from resident detail actions', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.residentDetail, arguments: 'resident-1');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('resident-open-health-entry-resident-1')));
    await tester.tap(find.byKey(const ValueKey('resident-open-health-entry-resident-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('健康录入'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('resident-open-ai-resident-1')));
    await tester.tap(find.byKey(const ValueKey('resident-open-ai-resident-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('AI 护理助手'), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-context-banner')), findsOneWidget);
    expect(find.textContaining('焦点对象为 王秀兰'), findsOneWidget);
  });

  testWidgets('switches resident and saves health entry', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.healthEntry, arguments: 'resident-1');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('health-entry-resident-resident-2')));
    await tester.pumpAndSettle();

    expect(find.textContaining('当前准备提交 陈国富 的健康录入'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('health-entry-input-血压')), '132/84');
    final saveButton = find.byKey(const ValueKey('health-entry-save-button'));
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton, warnIfMissed: false);
    await tester.pump();

    expect(find.text('录入已暂存'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('recognizes health values from image flow and applies them', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.healthEntry, arguments: 'resident-2');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('health-scan-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('health-scan-slot-monitor-photo')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('health-scan-capture-monitor-photo')));
    await tester.tap(find.byKey(const ValueKey('health-scan-capture-monitor-photo')), warnIfMissed: false);
    await tester.enterText(
      find.byKey(const ValueKey('health-scan-ocr-input')),
      '血压 128/82\n心率 78\n血氧 97\n体温 36.6',
    );
    await tester.pumpAndSettle();

    final recognizeButton = find.byKey(const ValueKey('health-scan-recognize'));
    await tester.ensureVisible(recognizeButton);
    await tester.tap(recognizeButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    final controller = Get.find<HealthEntryController>();
    expect(controller.recognitionResult.value, isNotNull);
    expect(find.byKey(const ValueKey('health-scan-result')), findsOneWidget);
    expect(find.textContaining('已从图片和 OCR 摘要中识别 4 项体征'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('health-scan-apply')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(controller.fieldControllers['血压']!.text, '128/82');
    expect(controller.fieldControllers['心率']!.text, '78');
    expect(controller.fieldControllers['血氧']!.text, '97');
    expect(controller.fieldControllers['体温']!.text, '36.6');
  });

  testWidgets('shows health high-risk follow-up and opens AI assistant context', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.healthEntry, arguments: 'resident-2');
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('health-entry-input-血压')), '156/98');
    await tester.enterText(find.byKey(const ValueKey('health-entry-input-血氧')), '92');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('health-followup-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('health-followup-ai')), findsOneWidget);
    expect(find.byKey(const ValueKey('health-followup-alert')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('health-followup-ai')));
    await tester.tap(find.byKey(const ValueKey('health-followup-ai')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ai-health-context-card')), findsOneWidget);
    expect(find.textContaining('已带入健康录入高风险上下文'), findsOneWidget);
    expect(find.textContaining('血压 156/98'), findsOneWidget);
  });

  testWidgets('opens alerts with health entry high-risk draft context', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.alerts, arguments: const HealthEntryFollowupDraft(
      residentId: 'resident-2',
      residentName: '陈国富',
      recognitionSummary: '识别结果提示血压和血氧异常，需要继续评估。',
      priority: 'P1',
      metricHighlights: ['血压 156/98', '血氧 92%'],
      riskSignals: ['血压偏高需复测确认', '血氧偏低需评估是否升级'],
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-health-entry-banner')), findsOneWidget);
    expect(find.textContaining('来自健康录入的异常跟进草稿'), findsOneWidget);
    expect(find.textContaining('陈国富 · 健康录入高风险结果'), findsOneWidget);
    expect(find.textContaining('血压偏高需复测确认'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('alert-draft-promote')));
    await tester.tap(find.byKey(const ValueKey('alert-draft-promote')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-draft-detail-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('alert-draft-assignment-card')), findsOneWidget);
    expect(find.textContaining('健康录入升级草稿'), findsOneWidget);
  });

  testWidgets('toggles care execution checklist and submits', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.careExecution, arguments: 'task-1');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('care-step-0')), warnIfMissed: false);
    await tester.tap(find.byKey(const ValueKey('care-step-1')), warnIfMissed: false);
    await tester.tap(find.byKey(const ValueKey('care-step-2')), warnIfMissed: false);
    await tester.pumpAndSettle();

    final controller = Get.find<CareExecutionController>();
    expect(controller.completedSteps.contains(0), isTrue);
    expect(controller.completedSteps.contains(1), isTrue);
    expect(controller.completedSteps.contains(2), isTrue);

    await tester.enterText(find.byKey(const ValueKey('care-note-input')), '已完成首步并观察无不适。');
    final submitButton = find.byKey(const ValueKey('care-submit-button'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pump();

    expect(find.text('任务已提交'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('blocks care execution submit until required evidence is provided', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.careExecution, arguments: 'task-2');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-evidence-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-evidence-slot-feeding-position')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-evidence-slot-feeding-supplies')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('care-step-0')), warnIfMissed: false);
    await tester.tap(find.byKey(const ValueKey('care-step-1')), warnIfMissed: false);
    await tester.tap(find.byKey(const ValueKey('care-step-2')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('care-note-input')), '鼻饲后耐受良好，准备补齐留证。');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-submit-blocker')), findsOneWidget);
    expect(find.text('• 缺少必传留证：体位确认照、器具结果照。'), findsOneWidget);

    final captureButton = find.byKey(const ValueKey('care-evidence-capture-feeding-position'));
    final galleryButton = find.byKey(const ValueKey('care-evidence-gallery-feeding-supplies'));
    await tester.ensureVisible(captureButton);
    await tester.tap(captureButton, warnIfMissed: false);
    await tester.ensureVisible(galleryButton);
    await tester.tap(galleryButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    final controller = Get.find<CareExecutionController>();
    expect(controller.evidenceDrafts.containsKey('feeding-position'), isTrue);
    expect(controller.evidenceDrafts.containsKey('feeding-supplies'), isTrue);
    expect(find.byKey(const ValueKey('care-evidence-preview-feeding-position')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-evidence-preview-feeding-supplies')), findsOneWidget);

    final submitButton = find.byKey(const ValueKey('care-submit-button'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pump();

    expect(find.text('任务已提交'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('shows follow-up actions after care execution submit and opens handover draft', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.careExecution, arguments: 'task-2');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('care-step-0')), warnIfMissed: false);
    await tester.tap(find.byKey(const ValueKey('care-step-1')), warnIfMissed: false);
    await tester.tap(find.byKey(const ValueKey('care-step-2')), warnIfMissed: false);
    await tester.enterText(find.byKey(const ValueKey('care-note-input')), '鼻饲后耐受平稳，已准备交接。');

    await tester.ensureVisible(find.byKey(const ValueKey('care-evidence-capture-feeding-position')));
    await tester.tap(find.byKey(const ValueKey('care-evidence-capture-feeding-position')), warnIfMissed: false);
    await tester.ensureVisible(find.byKey(const ValueKey('care-evidence-gallery-feeding-supplies')));
    await tester.tap(find.byKey(const ValueKey('care-evidence-gallery-feeding-supplies')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('care-submit-button')));
    await tester.tap(find.byKey(const ValueKey('care-submit-button')), warnIfMissed: false);
    await tester.pump();

    expect(find.byKey(const ValueKey('care-followup-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-followup-handover')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-followup-alert')), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('care-followup-handover')));
    await tester.tap(find.byKey(const ValueKey('care-followup-handover')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('handover-care-execution-banner')), findsOneWidget);
    expect(find.textContaining('来自护理执行的交接草稿'), findsOneWidget);
  });

  testWidgets('opens alerts with care execution draft context', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.alerts, arguments: const CareExecutionFollowupDraft(
      taskId: 'task-2',
      taskTitle: '鼻饲护理执行',
      residentName: '陈国富',
      evidenceSummary: '已补留证 2 / 3 项',
      note: '出现轻微呛咳，需要继续观察。',
      priority: 'P1',
      exceptionNote: '执行后出现轻微呛咳，待人工判断是否升级。',
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-care-execution-banner')), findsOneWidget);
    expect(find.textContaining('来自护理执行的异常跟进草稿'), findsOneWidget);
    expect(find.text('陈国富 · 鼻饲护理执行'), findsOneWidget);
    expect(find.textContaining('待人工判断：执行后出现轻微呛咳'), findsOneWidget);
    expect(find.byKey(const ValueKey('alert-draft-promote')), findsOneWidget);
    expect(find.byKey(const ValueKey('alert-draft-observe')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('alert-draft-promote')));
    await tester.tap(find.byKey(const ValueKey('alert-draft-promote')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-draft-detail-summary')), findsOneWidget);
    expect(find.textContaining('护理执行升级草稿'), findsOneWidget);
    expect(find.byKey(const ValueKey('alert-draft-confirm-button')), findsOneWidget);
  });

  testWidgets('keeps care execution draft under observation explicitly', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.alerts, arguments: const CareExecutionFollowupDraft(
      taskId: 'task-4',
      taskTitle: '午前翻身巡视',
      residentName: '李福安',
      evidenceSummary: '已补留证 1 / 1 项',
      note: '当前皮肤完整，继续观察。',
      priority: 'P2',
      exceptionNote: '当前无需升级正式事件，但需继续观察皮肤状态。',
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('alert-draft-observe')));
    await tester.tap(find.byKey(const ValueKey('alert-draft-observe')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-draft-decision-card')), findsOneWidget);
    expect(find.text('已保留为观察项'), findsOneWidget);
  });

  testWidgets('shows residents empty state', (WidgetTester tester) async {
    Get.put<ResidentsController>(_EmptyResidentsController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: ResidentsView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('residents-empty-state')), findsOneWidget);
  });

  testWidgets('shows health entry empty state', (WidgetTester tester) async {
    Get.put<HealthEntryController>(_EmptyHealthEntryController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: HealthEntryView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('health-entry-empty-state')), findsOneWidget);
  });

  testWidgets('shows care execution empty state', (WidgetTester tester) async {
    Get.put<CareExecutionController>(_EmptyCareExecutionController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: CareExecutionView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-empty-state')), findsOneWidget);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-username-input')), 'lin.xiaowen');
  await tester.enterText(find.byKey(const ValueKey('login-password-input')), '123456');
  final submitButton = find.byKey(const ValueKey('login-submit-button'));
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton, warnIfMissed: false);
}

class _EmptyResidentsController extends ResidentsController {
  _EmptyResidentsController() : super(MockNaniService());

  @override
  List<ResidentSnapshot> get residents => const [];
}

class _EmptyHealthEntryController extends HealthEntryController {
  _EmptyHealthEntryController() : super(MockNaniService());

  @override
  List<VitalDraft> get drafts => const [];
}

class _EmptyCareExecutionController extends CareExecutionController {
  _EmptyCareExecutionController() : super(MockNaniService());

  @override
  List<String> get steps => const [];
}