import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class ScheduleController extends GetxController {
  ScheduleController(this._service);

  final MockNaniService _service;

  List<ScheduleItem> get schedule => _service.schedule;
}

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '我的排班',
        subtitle: '排班页既展示班次，也明确调班边界和主管确认要求。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SurfaceCard(
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppPalette.info),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('关键调班动作必须由主管人工确认，AI 只提供覆盖风险提示。', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: '未来班次',
              subtitle: '班次、楼层和特殊备注保持同屏，方便班前判断工作负荷。',
            ),
            const SizedBox(height: 14),
            if (controller.schedule.isEmpty)
              const _ScheduleEmptyState()
            else
              ...controller.schedule.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ScheduleCard(
                    key: ValueKey('schedule-card-${item.date}'),
                    item: item,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleEmptyState extends StatelessWidget {
  const _ScheduleEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('schedule-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_month_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有未来排班', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('排班数据尚未下发或已全部完成时，这里会明确显示为空态。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.item, super.key});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(item.date, style: Theme.of(context).textTheme.titleLarge)),
              StatusChip(label: item.shift, color: AppPalette.info),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.area, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 6),
          Text(item.note, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}