import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/modules/ai_assistant/ai_assistant_page.dart';
import 'package:nursing_nani_app/app/modules/handover/handover_page.dart';
import 'package:nursing_nani_app/app/modules/schedule/schedule_page.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('opens handover and handoff detail from home quick action', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-quick-action-handover')));
    await tester.tap(find.byKey(const ValueKey('home-quick-action-handover')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('交接班'), findsOneWidget);
    expect(find.byKey(const ValueKey('handover-summary-card')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('handover-open-detail-handover-1')));
    await tester.tap(find.byKey(const ValueKey('handover-open-detail-handover-1')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('交接详情'), findsOneWidget);
    expect(find.text('人工确认清单'), findsOneWidget);
  });

  testWidgets('saves handover draft and closes snackbar cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-quick-action-handover')));
    await tester.tap(find.byKey(const ValueKey('home-quick-action-handover')), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('handover-save-draft')));
    await tester.tap(find.byKey(const ValueKey('handover-save-draft')), warnIfMissed: false);
    await tester.pump();

    expect(find.text('交接草稿已保存'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('opens schedule from home quick action', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-quick-action-schedule')));
    await tester.tap(find.byKey(const ValueKey('home-quick-action-schedule')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('我的排班'), findsOneWidget);
    expect(find.byKey(const ValueKey('schedule-card-03-31 周二')), findsOneWidget);
  });

  testWidgets('shows AI context banner when entering from contextual route', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.aiAssist, arguments: {
      'source': 'alerts',
      'resident': '王秀兰',
    });
    await tester.pumpAndSettle();

    expect(find.text('AI 护理助手'), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-context-banner')), findsOneWidget);
    expect(find.textContaining('当前从 alerts 进入'), findsOneWidget);
    expect(find.textContaining('焦点对象为 王秀兰'), findsOneWidget);
    expect(find.byKey(const ValueKey('ai-boundary-card')), findsOneWidget);
  });

  testWidgets('shows AI empty state', (WidgetTester tester) async {
    Get.put<AiAssistantController>(_EmptyAiAssistantController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: AiAssistantView())));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ai-empty-state')), findsOneWidget);
  });

  testWidgets('shows handover empty state', (WidgetTester tester) async {
    Get.put<HandoverController>(_EmptyHandoverController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: HandoverView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('handover-empty-state')), findsOneWidget);
  });

  testWidgets('shows schedule empty state', (WidgetTester tester) async {
    Get.put<ScheduleController>(_EmptyScheduleController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: ScheduleView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('schedule-empty-state')), findsOneWidget);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-username-input')), 'lin.xiaowen');
  await tester.enterText(find.byKey(const ValueKey('login-password-input')), '123456');
  final submitButton = find.byKey(const ValueKey('login-submit-button'));
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton, warnIfMissed: false);
}

class _EmptyAiAssistantController extends AiAssistantController {
  _EmptyAiAssistantController() : super(MockNaniService());

  @override
  List<AiInsight> get insights => const [];
}

class _EmptyHandoverController extends HandoverController {
  _EmptyHandoverController() : super(MockNaniService());

  @override
  List<HandoverItem> get items => const [];
}

class _EmptyScheduleController extends ScheduleController {
  _EmptyScheduleController() : super(MockNaniService());

  @override
  List<ScheduleItem> get schedule => const [];
}