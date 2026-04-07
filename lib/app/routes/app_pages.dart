import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/middleware/auth_middleware.dart';
import 'package:nursing_nani_app/app/modules/ai_assistant/ai_assistant_page.dart';
import 'package:nursing_nani_app/app/modules/alert_detail/alert_detail_page.dart';
import 'package:nursing_nani_app/app/modules/alerts/alerts_page.dart';
import 'package:nursing_nani_app/app/modules/care_checkin/care_checkin_page.dart';
import 'package:nursing_nani_app/app/modules/care_execution/care_execution_page.dart';
import 'package:nursing_nani_app/app/modules/elder_detail/elder_detail_page.dart';
import 'package:nursing_nani_app/app/modules/handoff/handoff_page.dart';
import 'package:nursing_nani_app/app/modules/handover/handover_page.dart';
import 'package:nursing_nani_app/app/modules/health/health_page.dart';
import 'package:nursing_nani_app/app/modules/health_entry/health_entry_page.dart';
import 'package:nursing_nani_app/app/modules/login/login_page.dart';
import 'package:nursing_nani_app/app/modules/notifications/notifications_page.dart';
import 'package:nursing_nani_app/app/modules/residents/residents_page.dart';
import 'package:nursing_nani_app/app/modules/root/root_page.dart';
import 'package:nursing_nani_app/app/modules/schedule/schedule_page.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

class AppPages {
  static GetPage<dynamic> _protectedPage({
    required String name,
    required GetPageBuilder page,
  }) {
    return GetPage(
      name: name,
      page: page,
      middlewares: [AuthRequiredMiddleware()],
    );
  }

  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      middlewares: [GuestOnlyMiddleware()],
    ),
    _protectedPage(name: AppRoutes.root, page: () => const RootView()),
    _protectedPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
    ),
    _protectedPage(
      name: AppRoutes.alerts,
      page: () => const Scaffold(body: AlertsView()),
    ),
    _protectedPage(
      name: AppRoutes.alertDetail,
      page: () => const AlertDetailView(),
    ),
    _protectedPage(name: AppRoutes.residents, page: () => const ResidentsView()),
    _protectedPage(
      name: AppRoutes.residentDetail,
      page: () => const ResidentDetailView(),
    ),
    _protectedPage(name: AppRoutes.health, page: () => const HealthView()),
    _protectedPage(name: AppRoutes.schedule, page: () => const ScheduleView()),
    _protectedPage(name: AppRoutes.handover, page: () => const HandoverView()),
    _protectedPage(name: AppRoutes.handoff, page: () => const HandoffView()),
    _protectedPage(
      name: AppRoutes.careCheckin,
      page: () => const CareCheckinView(),
    ),
    _protectedPage(
      name: AppRoutes.healthEntry,
      page: () => const HealthEntryView(),
    ),
    _protectedPage(
      name: AppRoutes.careExecution,
      page: () => const CareExecutionView(),
    ),
    _protectedPage(name: AppRoutes.aiAssist, page: () => const AiAssistantView()),
  ];
}