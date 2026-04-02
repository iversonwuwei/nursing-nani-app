import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/modules/alert_detail/alert_detail_page.dart';
import 'package:nursing_nani_app/app/modules/handoff/handoff_page.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('opens alert detail from alerts tab and reaches ai context', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('root-nav-alerts')));
    await tester.tap(find.byKey(const ValueKey('root-nav-alerts')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('alert-open-detail-alert-1')));
    await tester.tap(find.byKey(const ValueKey('alert-open-detail-alert-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-detail-summary-alert-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('alert-timeline-0')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('alert-open-ai-alert-1')));
    await tester.tap(find.byKey(const ValueKey('alert-open-ai-alert-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('AI 护理助手'), findsOneWidget);
    expect(find.textContaining('焦点对象为 王秀兰'), findsOneWidget);
  });

  testWidgets('opens handoff detail from handover, toggles step, and reaches resident detail', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-quick-action-handover')));
    await tester.tap(find.byKey(const ValueKey('home-quick-action-handover')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('handover-open-detail-handover-1')));
    await tester.tap(find.byKey(const ValueKey('handover-open-detail-handover-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('handoff-hero-handover-1')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('handoff-step-handover-1-0')));
    await tester.tap(find.byKey(const ValueKey('handoff-step-handover-1-0')), warnIfMissed: false);
    await tester.pumpAndSettle();

    final controller = Get.find<HandoffController>();
    expect(controller.completedSteps.contains(0), isTrue);

    await tester.ensureVisible(find.byKey(const ValueKey('handoff-open-resident-handover-1')));
    await tester.tap(find.byKey(const ValueKey('handoff-open-resident-handover-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('长者详情'), findsOneWidget);
    expect(find.byKey(const ValueKey('resident-detail-hero-resident-1')), findsOneWidget);
  });

  testWidgets('shows alert detail empty state', (WidgetTester tester) async {
    Get.put<AlertDetailController>(_EmptyAlertDetailController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: AlertDetailView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-timeline-empty-state')), findsOneWidget);
  });

  testWidgets('confirms escalation owner and arrival in alert detail draft mode', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(
      AppRoutes.alertDetail,
      arguments: {
        'draft': const AlertEscalationDraft(
          source: 'health-entry',
          residentName: '王秀兰',
          title: '健康录入高风险结果',
          priority: 'P1',
          summary: '识别或回填后出现高风险体征：血压 156/98；血氧 92%。',
          traceLabel: '血压 156/98；血氧 92%',
          recommendedOwner: '值班护士 赵敏',
          recommendedArrivalBy: '10 分钟内到场',
        ),
      },
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-draft-detail-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('alert-draft-assignment-card')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('alert-draft-note-input')), '已通知护士携带血压计到场复测。');
    await tester.ensureVisible(find.byKey(const ValueKey('alert-draft-confirm-button')));
    await tester.tap(find.byKey(const ValueKey('alert-draft-confirm-button')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('alert-draft-confirmed-card')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('alert-draft-confirmed-card')),
        matching: find.textContaining('值班护士 赵敏'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('alert-draft-confirmed-card')),
        matching: find.textContaining('10 分钟内到场'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows handoff detail empty state', (WidgetTester tester) async {
    Get.put<HandoffController>(_EmptyHandoffController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: HandoffView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('handoff-steps-empty-state')), findsOneWidget);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-username-input')), 'lin.xiaowen');
  await tester.enterText(find.byKey(const ValueKey('login-password-input')), '123456');
  final submitButton = find.byKey(const ValueKey('login-submit-button'));
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton, warnIfMissed: false);
}

class _EmptyAlertDetailController extends AlertDetailController {
  _EmptyAlertDetailController() : super(MockNaniService());

  static const _alert = AlertCase(
    id: 'alert-empty',
    title: '测试报警',
    residentName: '测试长者',
    level: 'P3',
    time: '08:00',
    status: '处理中',
    description: '当前只验证报警详情空态。',
    recommendedAction: '请继续人工确认。',
    owner: '测试责任人',
  );

  @override
  AlertCase get alert => _alert;

  @override
  List<AlertTimelineEntry> get timeline => const [];
}

class _EmptyHandoffController extends HandoffController {
  _EmptyHandoffController() : super(MockNaniService());

  static const _detail = HandoffDetail(
    item: HandoverItem(
      id: 'handover-empty',
      relatedResidentId: 'resident-1',
      residentName: '测试长者',
      topic: '测试交接主题',
      detail: '当前只验证交接详情空态。',
      priority: '中',
    ),
    owner: '测试责任人',
    dueBy: '今日完成',
    lastUpdated: '刚刚更新',
    confirmationSteps: [],
    escalationNote: '当前没有升级动作。',
  );

  @override
  HandoffDetail get detail => _detail;
}