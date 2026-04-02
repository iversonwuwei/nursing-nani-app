import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/nani_binding.dart';
import 'package:nursing_nani_app/app/routes/app_pages.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';

class NaniApp extends StatelessWidget {
  const NaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '护工 APP + AI',
      debugShowCheckedModeBanner: false,
      initialBinding: NaniBinding(),
      initialRoute: AppRoutes.root,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme,
    );
  }
}