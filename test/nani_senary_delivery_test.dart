import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/app.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('completes care check-in and carries summary into care execution', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.careCheckin, arguments: 'task-2');
    await tester.pumpAndSettle();

    expect(find.text('服务打卡'), findsOneWidget);

    final submitButton = find.byKey(const ValueKey('care-checkin-submit'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-checkin-submit-blocker')), findsOneWidget);

    final scanMethod = find.byKey(const ValueKey('care-checkin-method-扫码'));
    await tester.ensureVisible(scanMethod);
    await tester.tap(scanMethod, warnIfMissed: false);
    await tester.enterText(find.byKey(const ValueKey('care-checkin-location-input')), '2A-305 床旁');
    final arrivalToggle = find.byKey(const ValueKey('care-checkin-confirm-arrival'));
    await tester.ensureVisible(arrivalToggle);
    await tester.tap(arrivalToggle, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-checkin-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-checkin-open-care-execution')), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();

    final openCareExecution = find.byKey(const ValueKey('care-checkin-open-care-execution'));
    await tester.ensureVisible(openCareExecution);
    await tester.tap(openCareExecution, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-clockin-context')), findsOneWidget);
    expect(find.textContaining('以扫码完成打卡'), findsOneWidget);
  });

  testWidgets('requires exception note for manual care check-in and exposes alert follow-up', (WidgetTester tester) async {
    await tester.pumpWidget(const NaniApp());
    await tester.pumpAndSettle();

    await _signIn(tester);
    await tester.pumpAndSettle();

    Get.toNamed(AppRoutes.careCheckin, arguments: 'task-3');
    await tester.pumpAndSettle();

    final manualMethod = find.byKey(const ValueKey('care-checkin-method-手工补录'));
    await tester.ensureVisible(manualMethod);
    await tester.tap(manualMethod, warnIfMissed: false);
    await tester.enterText(find.byKey(const ValueKey('care-checkin-location-input')), '2A-308 康复训练区');
    final arrivalToggle = find.byKey(const ValueKey('care-checkin-confirm-arrival'));
    await tester.ensureVisible(arrivalToggle);
    await tester.tap(arrivalToggle, warnIfMissed: false);
    await tester.pumpAndSettle();

    final submitButton = find.byKey(const ValueKey('care-checkin-submit'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('• 手工补录时请写明原因。'), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();

    final exceptionInput = find.byKey(const ValueKey('care-checkin-exception-input'));
    await tester.ensureVisible(exceptionInput);
    await tester.enterText(exceptionInput, '现场网络异常，先由责任护工手工补录。');
    await tester.pumpAndSettle();

    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('care-checkin-summary')), findsOneWidget);
    expect(find.byKey(const ValueKey('care-checkin-open-alerts')), findsOneWidget);

    Get.closeAllSnackbars();
    await tester.pumpAndSettle();
  });
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byKey(const ValueKey('login-username-input')), 'lin.xiaowen');
  await tester.enterText(find.byKey(const ValueKey('login-password-input')), '123456');
  final submitButton = find.byKey(const ValueKey('login-submit-button'));
  await tester.ensureVisible(submitButton);
  await tester.tap(submitButton, warnIfMissed: false);
}