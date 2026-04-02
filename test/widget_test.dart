import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('shows login first and enters app after sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    expect(find.text('护工登录'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, '账号'), 'lin.xiaowen');
    await tester.enterText(find.widgetWithText(TextFormField, '密码'), '123456');
    await _signIn(tester);
    await tester.pumpAndSettle();

    expect(find.text('护工智护台'), findsOneWidget);
    expect(find.text('任务'), findsOneWidget);
    expect(find.text('报警'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);
  });

  testWidgets('opens resident detail route after sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.residentDetail, arguments: 'resident-1');
    await tester.pumpAndSettle();

    expect(find.text('长者详情'), findsOneWidget);
    expect(find.text('本班重点'), findsOneWidget);
    expect(find.text('王秀兰'), findsOneWidget);
  });

  testWidgets('opens health trend route after sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.health, arguments: 'resident-1');
    await tester.pumpAndSettle();

    expect(find.text('健康趋势'), findsOneWidget);
    expect(find.text('趋势卡片'), findsOneWidget);
    expect(find.text('需复测确认'), findsOneWidget);
  });

  testWidgets('opens handoff detail route after sign in', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.handoff, arguments: 'handover-1');
    await tester.pumpAndSettle();

    expect(find.text('交接详情'), findsOneWidget);
    expect(find.text('人工确认清单'), findsOneWidget);
    expect(find.text('王秀兰'), findsOneWidget);
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, '账号'), 'lin.xiaowen');
  await tester.enterText(find.widgetWithText(TextFormField, '密码'), '123456');

  final signInButton = find.text('登录并进入班次');
  await tester.ensureVisible(signInButton);
  await tester.tap(signInButton, warnIfMissed: false);
}
