import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/services/auth_service.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class LoginController extends GetxController {
  LoginController(this._authService);

  final AuthService _authService;
  final username = ''.obs;
  final password = ''.obs;
  final isSubmitting = false.obs;

  Future<void> signIn() async {
    if (isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    final success = await _authService.signIn(
      username: username.value,
      password: password.value,
    );
    isSubmitting.value = false;

    if (!success) {
      Get.snackbar('登录失败', '请输入账号和密码后再继续');
      return;
    }

    Get.offAllNamed('/');
  }
}

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.page),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusChip(
                        label: '班次入口',
                        color: AppPalette.info,
                      ),
                      const SizedBox(height: 16),
                      Text('护工登录', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        '进入任务闭环前先完成身份确认，登录后围绕责任、风险与交接链路展开。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppGradients.hero,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppPalette.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.badge_rounded,
                                color: AppPalette.white,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '先确认身份，再进入班次执行流。',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppPalette.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '登录成功后默认进入 2 号楼 A 区责任护工上下文，后续页面统一受路由鉴权保护。',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppPalette.white.withValues(alpha: 0.84),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _HeroTag(label: '身份确认'),
                                _HeroTag(label: '路由鉴权'),
                                _HeroTag(label: '责任闭环'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppPalette.mint,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.person_outline_rounded, color: AppPalette.moss),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('班次身份', style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(height: 4),
                                      Text(
                                        '演示环境可输入任意非空账号密码。',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              key: const ValueKey('login-username-input'),
                              onChanged: (value) => controller.username.value = value,
                              decoration: _inputDecoration('账号', '例如 lin.xiaowen'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              key: const ValueKey('login-password-input'),
                              obscureText: true,
                              onChanged: (value) => controller.password.value = value,
                              decoration: _inputDecoration('密码', '输入登录密码'),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppPalette.cream,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                '登录后默认身份为 2 号楼 A 区责任护工，可直接进入任务、健康趋势与交接详情链路。',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  key: const ValueKey('login-submit-button'),
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : controller.signIn,
                                  child: Text(
                                    controller.isSubmitting.value ? '登录中...' : '登录并进入班次',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppPalette.cream,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppPalette.moss, width: 1.4),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppPalette.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}