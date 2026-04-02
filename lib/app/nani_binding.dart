import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/services/auth_service.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/modules/ai_assistant/ai_assistant_page.dart';
import 'package:nursing_nani_app/app/modules/alert_detail/alert_detail_page.dart';
import 'package:nursing_nani_app/app/modules/alerts/alerts_page.dart';
import 'package:nursing_nani_app/app/modules/care_execution/care_execution_page.dart';
import 'package:nursing_nani_app/app/modules/elder_detail/elder_detail_page.dart';
import 'package:nursing_nani_app/app/modules/handoff/handoff_page.dart';
import 'package:nursing_nani_app/app/modules/handover/handover_page.dart';
import 'package:nursing_nani_app/app/modules/health/health_page.dart';
import 'package:nursing_nani_app/app/modules/health_entry/health_entry_page.dart';
import 'package:nursing_nani_app/app/modules/home/home_page.dart';
import 'package:nursing_nani_app/app/modules/login/login_page.dart';
import 'package:nursing_nani_app/app/modules/notifications/notifications_page.dart';
import 'package:nursing_nani_app/app/modules/profile/profile_page.dart';
import 'package:nursing_nani_app/app/modules/residents/residents_page.dart';
import 'package:nursing_nani_app/app/modules/root/root_page.dart';
import 'package:nursing_nani_app/app/modules/schedule/schedule_page.dart';
import 'package:nursing_nani_app/app/modules/tasks/tasks_page.dart';

class NaniBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MockNaniService(), permanent: true);
    Get.put(AuthService(Get.find()), permanent: true);

    Get.lazyPut(() => LoginController(Get.find()), fenix: true);
    Get.lazyPut(() => RootController(), fenix: true);
    Get.lazyPut(() => HomeController(Get.find()), fenix: true);
    Get.lazyPut(() => TasksController(Get.find()), fenix: true);
    Get.lazyPut(() => AlertsController(Get.find()), fenix: true);
    Get.lazyPut(() => AlertDetailController(Get.find()), fenix: true);
    Get.lazyPut(() => AiAssistantController(Get.find()), fenix: true);
    Get.lazyPut(() => NotificationsController(Get.find()), fenix: true);
    Get.lazyPut(() => ProfileController(Get.find()), fenix: true);
    Get.lazyPut(() => ResidentsController(Get.find()), fenix: true);
    Get.lazyPut(() => ResidentDetailController(Get.find()), fenix: true);
    Get.lazyPut(() => HealthController(Get.find()), fenix: true);
    Get.lazyPut(() => ScheduleController(Get.find()), fenix: true);
    Get.lazyPut(() => HandoverController(Get.find()), fenix: true);
    Get.lazyPut(() => HandoffController(Get.find()), fenix: true);
    Get.lazyPut(() => HealthEntryController(Get.find()), fenix: true);
    Get.lazyPut(() => CareExecutionController(Get.find()), fenix: true);
  }
}