class ShiftOverview {
  const ShiftOverview({
    required this.caregiverName,
    required this.station,
    required this.shiftLabel,
    required this.checkInTime,
    required this.focusSummary,
    required this.completionRate,
    required this.urgentAlerts,
  });

  final String caregiverName;
  final String station;
  final String shiftLabel;
  final String checkInTime;
  final String focusSummary;
  final int completionRate;
  final int urgentAlerts;
}

class NaniUser {
  const NaniUser({
    required this.id,
    required this.name,
    required this.role,
    required this.station,
  });

  final String id;
  final String name;
  final String role;
  final String station;
}

class ShiftKpi {
  const ShiftKpi({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;
}

class CareEvidenceRequirement {
  const CareEvidenceRequirement({
    required this.id,
    required this.title,
    required this.instruction,
    required this.isRequired,
  });

  final String id;
  final String title;
  final String instruction;
  final bool isRequired;
}

class CareExecutionFollowupDraft {
  const CareExecutionFollowupDraft({
    required this.taskId,
    required this.taskTitle,
    required this.residentName,
    required this.evidenceSummary,
    required this.note,
    required this.priority,
    this.clockInSummary,
    this.exceptionNote,
  });

  final String taskId;
  final String taskTitle;
  final String residentName;
  final String evidenceSummary;
  final String note;
  final String priority;
  final String? clockInSummary;
  final String? exceptionNote;

  String get handoverTopic => '$taskTitle 执行结果待下一班确认';

  String get handoverDetail {
    final segments = <String>[];
    if (clockInSummary?.trim().isNotEmpty == true) {
      segments.add('打卡摘要：${clockInSummary!.trim()}');
    }
    segments.add(evidenceSummary);
    segments.add('执行备注：$note');
    return segments.join('；');
  }

  String get alertDetail => exceptionNote?.trim().isNotEmpty == true
      ? exceptionNote!.trim()
      : '$taskTitle 已完成，但需要继续人工确认异常或风险变化。';
}

class CareClockInDraft {
  const CareClockInDraft({
    required this.taskId,
    required this.taskTitle,
    required this.residentName,
    required this.room,
    required this.method,
    required this.locationLabel,
    required this.checkedInAtLabel,
    required this.arrivalConfirmed,
    this.exceptionNote,
  });

  final String taskId;
  final String taskTitle;
  final String residentName;
  final String room;
  final String method;
  final String locationLabel;
  final String checkedInAtLabel;
  final bool arrivalConfirmed;
  final String? exceptionNote;

  String get summaryLabel {
    final segments = <String>[
      '$checkedInAtLabel 以$method完成打卡',
      '位置 $locationLabel',
    ];

    if (exceptionNote?.trim().isNotEmpty == true) {
      segments.add('异常说明：${exceptionNote!.trim()}');
    }

    return segments.join('；');
  }
}

class CareTask {
  const CareTask({
    required this.id,
    required this.title,
    required this.residentName,
    required this.room,
    required this.dueTime,
    required this.status,
    required this.priority,
    required this.tags,
    required this.nextAction,
    this.evidenceRequirements = const [],
    this.evidenceFallbackHint = '现场不适合拍照时，请补充异常说明。',
    this.suggestedNotes = const [],
  });

  final String id;
  final String title;
  final String residentName;
  final String room;
  final String dueTime;
  final String status;
  final String priority;
  final List<String> tags;
  final String nextAction;
  final List<CareEvidenceRequirement> evidenceRequirements;
  final String evidenceFallbackHint;
  final List<String> suggestedNotes;
}

class ResidentSnapshot {
  const ResidentSnapshot({
    required this.id,
    required this.name,
    required this.room,
    required this.careLevel,
    required this.riskNote,
    required this.lastVitals,
    required this.focusTask,
  });

  final String id;
  final String name;
  final String room;
  final String careLevel;
  final String riskNote;
  final String lastVitals;
  final String focusTask;
}

class ResidentDetail {
  const ResidentDetail({
    required this.snapshot,
    required this.age,
    required this.mobility,
    required this.cognition,
    required this.dietNote,
    required this.familyPreference,
    required this.watchItems,
    required this.careNotes,
    required this.linkedTaskId,
  });

  final ResidentSnapshot snapshot;
  final String age;
  final String mobility;
  final String cognition;
  final String dietNote;
  final String familyPreference;
  final List<String> watchItems;
  final List<String> careNotes;
  final String linkedTaskId;
}

class HealthMetricTrend {
  const HealthMetricTrend({
    required this.label,
    required this.currentValue,
    required this.previousValue,
    required this.deltaLabel,
    required this.status,
    required this.interpretation,
  });

  final String label;
  final String currentValue;
  final String previousValue;
  final String deltaLabel;
  final String status;
  final String interpretation;
}

class ResidentHealthView {
  const ResidentHealthView({
    required this.residentId,
    required this.summary,
    required this.riskLevel,
    required this.nextReview,
    required this.metrics,
    required this.watchNotes,
  });

  final String residentId;
  final String summary;
  final String riskLevel;
  final String nextReview;
  final List<HealthMetricTrend> metrics;
  final List<String> watchNotes;
}

class AlertCase {
  const AlertCase({
    required this.id,
    required this.title,
    required this.residentName,
    required this.level,
    required this.time,
    required this.status,
    required this.description,
    required this.recommendedAction,
    required this.owner,
  });

  final String id;
  final String title;
  final String residentName;
  final String level;
  final String time;
  final String status;
  final String description;
  final String recommendedAction;
  final String owner;
}

class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    required this.isRead,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final String category;
  final bool isRead;
}

class AlertTimelineEntry {
  const AlertTimelineEntry({
    required this.time,
    required this.title,
    required this.detail,
    required this.actor,
  });

  final String time;
  final String title;
  final String detail;
  final String actor;
}

class HandoverItem {
  const HandoverItem({
    required this.id,
    required this.relatedResidentId,
    required this.residentName,
    required this.topic,
    required this.detail,
    required this.priority,
  });

  final String id;
  final String relatedResidentId;
  final String residentName;
  final String topic;
  final String detail;
  final String priority;
}

class HandoffDetail {
  const HandoffDetail({
    required this.item,
    required this.owner,
    required this.dueBy,
    required this.lastUpdated,
    required this.confirmationSteps,
    required this.escalationNote,
  });

  final HandoverItem item;
  final String owner;
  final String dueBy;
  final String lastUpdated;
  final List<String> confirmationSteps;
  final String escalationNote;
}

class ScheduleItem {
  const ScheduleItem({
    required this.date,
    required this.shift,
    required this.area,
    required this.note,
  });

  final String date;
  final String shift;
  final String area;
  final String note;
}

class VitalDraft {
  const VitalDraft({
    required this.label,
    required this.unit,
    required this.placeholder,
    required this.lastValue,
  });

  final String label;
  final String unit;
  final String placeholder;
  final String lastValue;
}

class HealthScanSlot {
  const HealthScanSlot({
    required this.id,
    required this.title,
    required this.instruction,
    required this.isRequired,
  });

  final String id;
  final String title;
  final String instruction;
  final bool isRequired;
}

class HealthImageDraft {
  const HealthImageDraft({
    required this.slotId,
    required this.sourceLabel,
    required this.capturedAtLabel,
  });

  final String slotId;
  final String sourceLabel;
  final String capturedAtLabel;
}

class HealthRecognitionSuggestion {
  const HealthRecognitionSuggestion({
    required this.label,
    required this.value,
    required this.confidence,
    required this.source,
  });

  final String label;
  final String value;
  final int confidence;
  final String source;
}

class HealthRecognitionResult {
  const HealthRecognitionResult({
    required this.summary,
    required this.confidence,
    required this.suggestions,
    required this.sourceLabels,
    required this.missingLabels,
  });

  final String summary;
  final int confidence;
  final List<HealthRecognitionSuggestion> suggestions;
  final List<String> sourceLabels;
  final List<String> missingLabels;
}

class HealthEntryFollowupDraft {
  const HealthEntryFollowupDraft({
    required this.residentId,
    required this.residentName,
    required this.recognitionSummary,
    required this.priority,
    required this.metricHighlights,
    required this.riskSignals,
  });

  final String residentId;
  final String residentName;
  final String recognitionSummary;
  final String priority;
  final List<String> metricHighlights;
  final List<String> riskSignals;

  String get aiSummary => '$recognitionSummary；重点关注：${riskSignals.join('、')}';

  String get alertDetail => '识别或回填后出现高风险体征：${metricHighlights.join('；')}。';
}

class AlertEscalationDraft {
  const AlertEscalationDraft({
    required this.source,
    required this.residentName,
    required this.title,
    required this.priority,
    required this.summary,
    required this.traceLabel,
    required this.recommendedOwner,
    required this.recommendedArrivalBy,
  });

  final String source;
  final String residentName;
  final String title;
  final String priority;
  final String summary;
  final String traceLabel;
  final String recommendedOwner;
  final String recommendedArrivalBy;

  String get sourceLabel => source == 'health-entry' ? '健康录入' : '护理执行';
}

class AiInsight {
  const AiInsight({
    required this.title,
    required this.summary,
    required this.reason,
    required this.action,
  });

  final String title;
  final String summary;
  final String reason;
  final String action;
}