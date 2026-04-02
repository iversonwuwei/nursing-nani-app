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

class TasksController extends GetxController {
  TasksController(this._service);

  final MockNaniService _service;
  final selectedFilter = 'all'.obs;

  List<CareTask> get tasks => _service.todayTasks;
  List<ResidentSnapshot> get residents => _service.residents;

  List<CareTask> get visibleTasks {
    final items = [...tasks];
    items.sort((left, right) {
      final priorityDiff = _priorityRank(left.priority).compareTo(_priorityRank(right.priority));
      if (priorityDiff != 0) {
        return priorityDiff;
      }
      return _dueTimeRank(left.dueTime).compareTo(_dueTimeRank(right.dueTime));
    });

    switch (selectedFilter.value) {
      case 'p1':
        return items.where((task) => task.priority == 'P1').toList();
      case 'due-soon':
        return items.where((task) => task.status == '即将到点').toList();
      case 'pending':
        return items.where((task) => task.status == '待执行').toList();
      case 'needs-record':
        return items.where((task) => task.nextAction.contains('补录')).toList();
      default:
        return items;
    }
  }

  List<ResidentSnapshot> get visibleResidents {
    final residentNames = visibleTasks.map((task) => task.residentName).toSet();
    return residents.where((resident) => residentNames.contains(resident.name)).toList();
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  int _priorityRank(String priority) {
    switch (priority) {
      case 'P1':
        return 0;
      case 'P2':
        return 1;
      default:
        return 2;
    }
  }

  int _dueTimeRank(String dueTime) {
    final parts = dueTime.split(':');
    if (parts.length != 2) {
      return 9999;
    }

    final hour = int.tryParse(parts[0]) ?? 99;
    final minute = int.tryParse(parts[1]) ?? 99;
    return hour * 60 + minute;
  }
}

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return NaniScaffold(
      title: '任务中心',
      subtitle: '围绕优先级、到点时间和护理对象组织任务，而不是只展示静态列表。',
      child: Obx(
        () {
          final visibleTasks = controller.visibleTasks;
          final visibleResidents = controller.visibleResidents;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: '筛选视图',
                subtitle: '优先处理 P1、临近时限和需要补录的任务。',
              ),
              const SizedBox(height: 14),
              _TaskFilters(
                selectedFilter: controller.selectedFilter.value,
                onSelected: controller.selectFilter,
              ),
              const SizedBox(height: 24),
              if (visibleTasks.isEmpty)
                const _TasksEmptyState(
                  title: '当前筛选下暂无任务',
                  description: '可以切回全部任务，或等待新的任务分配进入本班次。',
                )
              else
                ...visibleTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _TaskCard(
                      key: ValueKey('task-card-${task.id}'),
                      task: task,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              const SectionHeader(
                title: '关联长者',
                subtitle: '任务和对象共用同一批长者实体，方便直接切到录入或执行流。',
              ),
              const SizedBox(height: 14),
              if (visibleResidents.isEmpty)
                const _TasksEmptyState(
                  title: '当前没有关联长者',
                  description: '当前筛选未命中任何任务对象，切换筛选后会恢复对象列表。',
                )
              else
                ...visibleResidents.map(
                  (resident) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ResidentStrip(
                      key: ValueKey('task-resident-${resident.id}'),
                      resident: resident,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskFilters extends StatelessWidget {
  const _TaskFilters({
    required this.selectedFilter,
    required this.onSelected,
  });

  final String selectedFilter;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TaskFilterChip(
          filter: 'all',
          label: '全部任务',
          selectedFilter: selectedFilter,
          onSelected: onSelected,
          color: AppPalette.moss,
        ),
        _TaskFilterChip(
          filter: 'p1',
          label: 'P1 优先',
          selectedFilter: selectedFilter,
          onSelected: onSelected,
          color: AppPalette.danger,
        ),
        _TaskFilterChip(
          filter: 'due-soon',
          label: '即将到点',
          selectedFilter: selectedFilter,
          onSelected: onSelected,
          color: AppPalette.warning,
        ),
        _TaskFilterChip(
          filter: 'needs-record',
          label: '待补录',
          selectedFilter: selectedFilter,
          onSelected: onSelected,
          color: AppPalette.info,
        ),
      ],
    );
  }
}

class _TaskFilterChip extends StatelessWidget {
  const _TaskFilterChip({
    required this.filter,
    required this.label,
    required this.selectedFilter,
    required this.onSelected,
    required this.color,
  });

  final String filter;
  final String label;
  final String selectedFilter;
  final ValueChanged<String> onSelected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final selected = filter == selectedFilter;
    return GestureDetector(
      key: ValueKey('task-filter-$filter'),
      onTap: () => onSelected(filter),
      child: StatusChip(
        label: label,
        color: selected ? AppPalette.white : color,
        backgroundColor: selected ? color : AppPalette.white,
      ),
    );
  }
}

class _TasksEmptyState extends StatelessWidget {
  const _TasksEmptyState({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inbox_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, super.key});

  final CareTask task;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      '${task.residentName} · ${task.room} · ${task.dueTime}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(label: task.priority, color: _priorityColor(task.priority)),
                  const SizedBox(height: 8),
                  StatusChip(label: task.status, color: _statusColor(task.status)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: task.tags
                .map((tag) => StatusChip(label: tag, color: AppPalette.moss))
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(task.nextAction, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  key: ValueKey('task-open-health-entry-${task.id}'),
                  onPressed: () => Get.toNamed(AppRoutes.healthEntry),
                  child: const Text('录健康'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  key: ValueKey('task-open-care-execution-${task.id}'),
                  onPressed: () => Get.toNamed(AppRoutes.careExecution, arguments: task.id),
                  child: const Text('执行任务'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResidentStrip extends StatelessWidget {
  const _ResidentStrip({required this.resident, super.key});

  final ResidentSnapshot resident;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
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
                Text(resident.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${resident.room} · ${resident.riskNote}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            key: ValueKey('task-open-resident-${resident.id}'),
            onPressed: () => Get.toNamed(AppRoutes.residentDetail, arguments: resident.id),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(String priority) {
  switch (priority) {
    case 'P1':
      return AppPalette.danger;
    case 'P2':
      return AppPalette.warning;
    default:
      return AppPalette.info;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case '即将到点':
      return AppPalette.warning;
    case '待执行':
      return AppPalette.info;
    default:
      return AppPalette.moss;
  }
}