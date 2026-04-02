import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/services/auth_service.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';

class AuthRequiredMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (!authService.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

class GuestOnlyMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    if (authService.isAuthenticated) {
      return const RouteSettings(name: AppRoutes.root);
    }
    return null;
  }
}