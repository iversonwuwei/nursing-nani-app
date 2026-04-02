import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/modules/health/health_page.dart';
import 'package:nursing_nani_app/app/modules/notifications/notifications_page.dart';
import 'package:nursing_nani_app/app/modules/profile/profile_page.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('opens notifications from home and shows summary plus messages', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-open-notifications')));
    await tester.tap(find.byKey(const ValueKey('home-open-notifications')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('消息中心'), findsOneWidget);
    expect(find.byKey(const ValueKey('notifications-summary-card')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-card-msg-1')), findsOneWidget);
  });

  testWidgets('switches resident in health page and opens ai context', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.health, arguments: 'resident-1');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('health-hero-resident-1')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('health-resident-resident-2')));
    await tester.tap(find.byKey(const ValueKey('health-resident-resident-2')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('health-hero-resident-2')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('health-open-ai-resident-2')));
    await tester.tap(find.byKey(const ValueKey('health-open-ai-resident-2')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('AI 护理助手'), findsOneWidget);
    expect(find.textContaining('焦点对象为 陈国富'), findsOneWidget);
  });

  testWidgets('opens schedule and handover from profile then signs out', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('root-nav-profile')));
    await tester.tap(find.byKey(const ValueKey('root-nav-profile')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-summary-card')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('profile-open-schedule')));
    await tester.tap(find.byKey(const ValueKey('profile-open-schedule')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('我的排班'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('profile-open-handover')));
    await tester.tap(find.byKey(const ValueKey('profile-open-handover')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('交接班'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('profile-logout-button')));
    await tester.tap(find.byKey(const ValueKey('profile-logout-button')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('护工登录'), findsOneWidget);
    expect(find.byKey(const ValueKey('login-submit-button')), findsOneWidget);
  });

  testWidgets('shows notifications empty state', (WidgetTester tester) async {
    Get.put<NotificationsController>(_EmptyNotificationsController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: NotificationsView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('notifications-empty-state')), findsOneWidget);
  });

  testWidgets('shows health empty states', (WidgetTester tester) async {
    Get.put<HealthController>(_EmptyHealthController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: HealthView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('health-metrics-empty-state')), findsOneWidget);
    expect(find.byKey(const ValueKey('health-watch-empty-state')), findsOneWidget);
  });

  testWidgets('shows profile empty states', (WidgetTester tester) async {
    Get.put<ProfileController>(_EmptyProfileController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: ProfileView()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-schedule-empty-state')), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-handover-empty-state')), findsOneWidget);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-username-input')), 'lin.xiaowen');
  await tester.enterText(find.byKey(const ValueKey('login-password-input')), '123456');
  final submitButton = find.byKey(const ValueKey('login-submit-button'));
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton, warnIfMissed: false);
}

class _EmptyNotificationsController extends NotificationsController {
  _EmptyNotificationsController() : super(MockNaniService());

  @override
  List<NotificationMessage> get notifications => const [];

  @override
  int get unreadCount => 0;
}

class _EmptyHealthController extends HealthController {
  _EmptyHealthController() : super(MockNaniService());

  static const _resident = ResidentSnapshot(
    id: 'resident-empty',
    name: '测试长者',
    room: '测试房间',
    careLevel: 'L2',
    riskNote: '当前无风险',
    lastVitals: '暂无',
    focusTask: '暂无任务',
  );

  static const _healthView = ResidentHealthView(
    residentId: 'resident-empty',
    summary: '当前暂无趋势摘要。',
    riskLevel: '稳定',
    nextReview: '暂无复测安排',
    metrics: [],
    watchNotes: [],
  );

  @override
  List<ResidentSnapshot> get residents => const [_resident];

  @override
  ResidentSnapshot get resident => _resident;

  @override
  ResidentHealthView get healthView => _healthView;
}

class _EmptyProfileController extends ProfileController {
  _EmptyProfileController() : super(MockNaniService());

  @override
  List<ScheduleItem> get schedule => const [];

  @override
  List<HandoverItem> get handovers => const [];

  @override
  String get handoverSummary => '当前没有待交接重点。';

  @override
  ShiftOverview get overview => const ShiftOverview(
        caregiverName: '测试护工',
        station: '测试站点',
        shiftLabel: '白班',
        checkInTime: '07:30',
        focusSummary: '当前仅验证个人页空态。',
        completionRate: 0,
        urgentAlerts: 0,
      );
}