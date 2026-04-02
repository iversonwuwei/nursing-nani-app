import 'package:nursing_nani_app/app/data/models/nani_models.dart';

const List<HealthScanSlot> defaultHealthScanSlots = [
  HealthScanSlot(
    id: 'monitor-photo',
    title: '监护仪读数照',
    instruction: '拍摄监护仪或测量设备上的读数区域，避免遮挡关键数值。',
    isRequired: true,
  ),
  HealthScanSlot(
    id: 'record-sheet',
    title: '记录单补充照',
    instruction: '如有纸质记录单或腕带标签，可补一张帮助交叉核对对象与时间。',
    isRequired: false,
  ),
];

const Map<String, Map<String, String>> _residentRecognitionBaseline = {
  '王秀兰': {
    '血压': '142/88',
    '心率': '80',
    '血氧': '96',
    '体温': '36.5',
  },
  '陈国富': {
    '血压': '128/82',
    '心率': '78',
    '血氧': '97',
    '体温': '36.6',
  },
  '周美珍': {
    '血压': '126/79',
    '心率': '84',
    '血氧': '98',
    '体温': '36.4',
  },
};

String _matchFirst(String text, RegExp pattern) {
  final match = pattern.firstMatch(text);
  return match?.group(1)?.trim() ?? '';
}

HealthRecognitionResult simulateHealthImageRecognition({
  required String residentName,
  required List<VitalDraft> drafts,
  required List<HealthImageDraft> imageDrafts,
  required String rawOcrText,
}) {
  final combinedText = [
    rawOcrText,
    ...imageDrafts.map((item) => '${item.sourceLabel} ${item.slotId}'),
  ].where((item) => item.trim().isNotEmpty).join('\n');
  final baseline = _residentRecognitionBaseline[residentName] ?? const {};

  final recognized = <String, String>{
    '血压': _matchFirst(combinedText, RegExp(r'(?:血压|BP)[:：]?\s*(\d{2,3}/\d{2,3})', caseSensitive: false)),
    '心率': _matchFirst(combinedText, RegExp(r'(?:心率|HR)[:：]?\s*(\d{2,3})', caseSensitive: false)),
    '血氧': _matchFirst(combinedText, RegExp(r'(?:血氧|SpO2)[:：]?\s*(\d{2,3})%?', caseSensitive: false)),
    '体温': _matchFirst(combinedText, RegExp(r'(?:体温|TEMP)[:：]?\s*(\d{2}(?:\.\d)?)', caseSensitive: false)),
  };

  final suggestions = <HealthRecognitionSuggestion>[];
  final missingLabels = <String>[];

  for (final draft in drafts) {
    final extracted = recognized[draft.label];
    final value = extracted?.isNotEmpty == true ? extracted! : (baseline[draft.label] ?? '');
    if (value.isEmpty) {
      missingLabels.add(draft.label);
      continue;
    }

    final fromOcr = extracted?.isNotEmpty == true;
    suggestions.add(
      HealthRecognitionSuggestion(
        label: draft.label,
        value: value,
        confidence: fromOcr ? 92 : 74,
        source: fromOcr ? 'OCR 识别' : '图片模板推断',
      ),
    );
  }

  final confidence = suggestions.isEmpty
      ? 0
      : ((suggestions.fold<int>(0, (sum, item) => sum + item.confidence) / suggestions.length)).round();

  return HealthRecognitionResult(
    summary: suggestions.isEmpty
        ? '当前未能从图片或 OCR 摘要中识别到有效体征，请人工录入。'
        : '已从图片和 OCR 摘要中识别 ${suggestions.length} 项体征，回填前请人工复核。',
    confidence: confidence,
    suggestions: suggestions,
    sourceLabels: imageDrafts.map((item) => item.sourceLabel).toList(),
    missingLabels: missingLabels,
  );
}