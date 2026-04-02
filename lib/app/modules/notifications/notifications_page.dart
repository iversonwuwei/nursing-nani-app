import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._service);

  final MockNaniService _service;

  List<NotificationMessage> get notifications => _service.notifications;
  int get unreadCount => _service.unreadNotificationCount;
}

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '消息中心',
        subtitle: '首页消息聚焦交接、任务和报警提醒，不把次要通知塞进主视图。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceCard(
              key: const ValueKey('notifications-summary-card'),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppPalette.sky,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.mark_chat_unread_rounded, color: AppPalette.info),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('未读消息 ${controller.unreadCount} 条', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('优先关注交接班和高优先级任务通知。', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '消息列表',
              subtitle: '按任务、交接班、报警分类展示，减少首页信息噪音。',
            ),
            const SizedBox(height: 14),
            if (controller.notifications.isEmpty)
              const _NotificationsEmptyState()
            else
              ...controller.notifications.map(
                (message) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _NotificationCard(
                    key: ValueKey('notification-card-${message.id}'),
                    message: message,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('notifications-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.mark_chat_unread_outlined, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有待处理消息', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('当交接、任务和报警都已收敛时，这里会明确显示为空态。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.message, super.key});

  final NotificationMessage message;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(message.title, style: Theme.of(context).textTheme.titleMedium)),
              StatusChip(
                label: message.isRead ? '已读' : '未读',
                color: message.isRead ? AppPalette.moss : AppPalette.danger,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${message.category} · ${message.time}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(message.body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}