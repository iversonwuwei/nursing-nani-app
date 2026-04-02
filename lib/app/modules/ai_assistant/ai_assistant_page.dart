import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nursing_nani_app/app/data/models/nani_models.dart';
import 'package:nursing_nani_app/app/data/services/mock_nani_service.dart';
import 'package:nursing_nani_app/app/theme/app_theme.dart';
import 'package:nursing_nani_app/app/widgets/nani_scaffold.dart';
import 'package:nursing_nani_app/app/widgets/section_header.dart';
import 'package:nursing_nani_app/app/widgets/status_chip.dart';
import 'package:nursing_nani_app/app/widgets/surface_card.dart';

class AiAssistantController extends GetxController {
  AiAssistantController(this._service);

  final MockNaniService _service;

  List<AiInsight> get insights => _service.aiInsights;
  String get boundary => _service.aiBoundary;
}

class AiAssistantView extends GetView<AiAssistantController> {
  const AiAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final source = arguments is Map ? arguments['source'] as String? : null;
    final resident = arguments is Map ? arguments['resident'] as String? : null;
    final healthDraft = arguments is Map ? arguments['healthDraft'] as HealthEntryFollowupDraft? : null;

    return NaniScaffold(
      title: 'AI 护理助手',
      subtitle: '只做摘要、解释和建议，把最终确认权留给一线护工和主管。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (source != null || resident != null) ...[
            _ContextBanner(
              key: const ValueKey('ai-context-banner'),
              source: source,
              resident: resident,
            ),
            const SizedBox(height: 24),
          ],
          if (healthDraft != null) ...[
            _HealthDraftBanner(draft: healthDraft),
            const SizedBox(height: 24),
          ],
          const SectionHeader(
            title: '建议卡片',
            subtitle: '围绕班次摘要、报警响应和交接班草稿输出同一对象的建议。',
          ),
          const SizedBox(height: 14),
          if (controller.insights.isEmpty)
            const _AiEmptyState()
          else
            ...controller.insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AiInsightCard(
                  key: ValueKey('ai-insight-${insight.title}'),
                  insight: insight,
                ),
              ),
            ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '建议触发器',
            subtitle: '从任务、报警和交接班入口带入上下文，但不自动执行业务动作。',
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              StatusChip(key: ValueKey('ai-trigger-shift-summary'), label: '班次摘要', color: AppPalette.info),
              StatusChip(key: ValueKey('ai-trigger-alerts'), label: '报警动作提示', color: AppPalette.warning),
              StatusChip(key: ValueKey('ai-trigger-handover'), label: '交接班草稿', color: AppPalette.moss),
            ],
          ),
          const SizedBox(height: 24),
          const SectionHeader(
            title: '人工确认边界',
            subtitle: '高风险建议必须可解释、可回退、可追踪。',
          ),
          const SizedBox(height: 14),
          SurfaceCard(
            key: const ValueKey('ai-boundary-card'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.rule_rounded, color: AppPalette.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(controller.boundary, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthDraftBanner extends StatelessWidget {
  const _HealthDraftBanner({required this.draft});

  final HealthEntryFollowupDraft draft;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('ai-health-context-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: AppPalette.danger),
              const SizedBox(width: 10),
              Expanded(
                child: Text('已带入健康录入高风险上下文', style: Theme.of(context).textTheme.titleMedium),
              ),
              const StatusChip(label: '需解释', color: AppPalette.danger),
            ],
          ),
          const SizedBox(height: 10),
          Text(draft.recognitionSummary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: draft.metricHighlights
                .map((item) => StatusChip(label: item, color: AppPalette.info))
                .toList(),
          ),
          const SizedBox(height: 10),
          Text(draft.riskSignals.join('、'), style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _AiEmptyState extends StatelessWidget {
  const _AiEmptyState();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      key: const ValueKey('ai-empty-state'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_alt_rounded, color: AppPalette.textSecondary),
          const SizedBox(height: 12),
          Text('当前没有可展示的 AI 建议', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('可以从任务、报警或交接班入口再次带入上下文，重新生成建议卡片。', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ContextBanner extends StatelessWidget {
  const _ContextBanner({this.source, this.resident, super.key});

  final String? source;
  final String? resident;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link_rounded, color: AppPalette.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '当前从 ${source ?? '首页'} 进入${resident == null ? '' : '，焦点对象为 $resident'}。AI 建议会围绕相同上下文生成。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({required this.insight, super.key});

  final AiInsight insight;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(insight.summary, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 12),
          _InsightMeta(label: '原因', value: insight.reason),
          const SizedBox(height: 8),
          _InsightMeta(label: '建议动作', value: insight.action),
        ],
      ),
    );
  }
}

class _InsightMeta extends StatelessWidget {
  const _InsightMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge)),
      ],
    );
  }
}