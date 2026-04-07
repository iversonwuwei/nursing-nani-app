import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/routes/app_routes.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class ResidentsController extends GetxController {
  ResidentsController(this._service);

  final MockNaniService _service;

  List<ResidentSnapshot> get residents => _service.residents;

  String linkedTaskIdFor(String residentId) {
    return _service.findResidentDetailById(residentId).linkedTaskId;
  }
}

class ResidentsView extends GetView<ResidentsController> {
  const ResidentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaniScaffold(
        title: '重点长者',
        subtitle: '长者详情聚焦今日风险、最新指标和下一步护理动作。',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: '照护对象列表',
              subtitle: '通过相同对象模型串起任务、健康录入和护理执行。',
            ),
            const SizedBox(height: 14),
            if (controller.residents.isEmpty)
              const _ResidentsEmptyState()
            else
              ...controller.residents.map(
                (resident) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResidentCard(
                    key: ValueKey('resident-card-${resident.id}'),
                    resident: resident,
                    linkedTaskId: controller.linkedTaskIdFor(resident.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResidentsEmptyState extends StatelessWidget {
  const _ResidentsEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('residents-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.elderly_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有重点长者', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('本班次暂无重点对象时，这里会明确显示为空态而不是空白列表。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ResidentCard extends StatelessWidget {
  const _ResidentCard({
    required this.resident,
    required this.linkedTaskId,
    super.key,
  });

  final ResidentSnapshot resident;
  final String linkedTaskId;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(resident.name, style: Theme.of(context).textTheme.titleLarge)),
              StatusChip(label: resident.careLevel, color: AppPalette.moss),
            ],
          ),
          const SizedBox(height: 8),
          Text('${resident.room} · ${resident.lastVitals}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Text(resident.riskNote, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(resident.focusTask, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          TextButton.icon(
            key: ValueKey('resident-open-detail-${resident.id}'),
            onPressed: () => Get.toNamed(AppRoutes.residentDetail, arguments: resident.id),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('查看长者详情'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: ValueKey('resident-open-health-entry-${resident.id}'),
                  onPressed: () => Get.toNamed(AppRoutes.healthEntry, arguments: resident.id),
                  child: const Text('健康录入'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  key: ValueKey('resident-open-care-execution-${resident.id}'),
                  onPressed: () => Get.toNamed(
                    AppRoutes.careCheckin,
                    arguments: linkedTaskId,
                  ),
                  child: const Text('服务打卡'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}