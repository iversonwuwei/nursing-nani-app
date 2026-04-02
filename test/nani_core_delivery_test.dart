import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/modules/alerts/alerts_page.dart';
import 'package:nursing_nani_app/app/modules/tasks/tasks_page.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('blocks empty login submission', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    final submitButton = find.byKey(const ValueKey('login-submit-button'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pump();

    expect(find.text('登录失败'), findsOneWidget);
    expect(find.text('请输入账号和密码后再继续'), findsOneWidget);
    expect(find.text('护工登录'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });

  testWidgets('opens home entries and switches root tabs deterministically', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('home-open-notifications')));
    await tester.pumpAndSettle();
    expect(find.text('消息中心'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('home-quick-action-health')));
    await tester.tap(find.byKey(const ValueKey('home-quick-action-health')), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('健康趋势'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('root-nav-tasks')));
    await tester.pumpAndSettle();
    expect(find.text('任务中心'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('root-nav-alerts')));
    await tester.pumpAndSettle();
    expect(find.text('报警处理'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('root-nav-home')));
    await tester.pumpAndSettle();
    expect(find.text('护工智护台'), findsOneWidget);
  });

  testWidgets('filters tasks by priority and recording need', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('root-nav-tasks')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('task-filter-p1')));
    await tester.pumpAndSettle();

    expect(find.text('晨间生命体征复测'), findsOneWidget);
    expect(find.text('鼻饲护理执行'), findsOneWidget);
    expect(find.text('康复训练陪护'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('task-filter-needs-record')));
    await tester.pumpAndSettle();

    expect(find.text('鼻饲护理执行'), findsOneWidget);
    expect(find.text('晨间生命体征复测'), findsNothing);
    expect(find.text('陈国富'), findsWidgets);
  });

  testWidgets('shows task empty state when controller has no visible tasks', (WidgetTester tester) async {
    Get.put<TasksController>(_EmptyTasksController(), permanent: true);

    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: TasksView())));
    await tester.pumpAndSettle();

    expect(find.text('当前筛选下暂无任务'), findsOneWidget);
    expect(find.text('当前没有关联长者'), findsOneWidget);
  });

  testWidgets('filters alerts by status and shows alert empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('root-nav-alerts')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('alert-filter-待到场')));
    await tester.pumpAndSettle();

    expect(find.text('呼叫按钮触发'), findsOneWidget);
    expect(find.text('夜间离床复核'), findsNothing);

    Get.reset();
    Get.put<AlertsController>(_EmptyAlertsController(), permanent: true);
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold(body: AlertsView())));
    await tester.pumpAndSettle();

    expect(find.text('当前筛选下没有报警'), findsOneWidget);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-username-input')), 'lin.xiaowen');
  await tester.enterText(find.byKey(const ValueKey('login-password-input')), '123456');
  final submitButton = find.byKey(const ValueKey('login-submit-button'));
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton, warnIfMissed: false);
}

class _EmptyTasksController extends TasksController {
  _EmptyTasksController() : super(MockNaniService());

  @override
  List<CareTask> get visibleTasks => const [];

  @override
  List<ResidentSnapshot> get visibleResidents => const [];
}

class _EmptyAlertsController extends AlertsController {
  _EmptyAlertsController() : super(MockNaniService()) {
    selectedStatus.value = 'all';
  }

  @override
  List<AlertCase> get visibleAlerts => const [];
}