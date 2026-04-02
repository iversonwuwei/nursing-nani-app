class HealthRiskThresholds {
  const HealthRiskThresholds({
    required this.highSystolic,
    required this.highDiastolic,
    required this.tachycardia,
    required this.bradycardia,
    required this.lowOxygen,
    required this.fever,
    required this.criticalSystolic,
    required this.criticalDiastolic,
    required this.criticalTachycardia,
    required this.criticalBradycardia,
    required this.criticalOxygen,
    required this.criticalFever,
  });

  final int highSystolic;
  final int highDiastolic;
  final int tachycardia;
  final int bradycardia;
  final int lowOxygen;
  final double fever;
  final int criticalSystolic;
  final int criticalDiastolic;
  final int criticalTachycardia;
  final int criticalBradycardia;
  final int criticalOxygen;
  final double criticalFever;
}

const defaultHealthRiskThresholds = HealthRiskThresholds(
  highSystolic: 150,
  highDiastolic: 95,
  tachycardia: 110,
  bradycardia: 50,
  lowOxygen: 93,
  fever: 37.8,
  criticalSystolic: 160,
  criticalDiastolic: 100,
  criticalTachycardia: 120,
  criticalBradycardia: 45,
  criticalOxygen: 90,
  criticalFever: 38.5,
);

class HealthRiskAssessment {
  const HealthRiskAssessment({
    required this.metricHighlights,
    required this.riskSignals,
    required this.priority,
  });

  final List<String> metricHighlights;
  final List<String> riskSignals;
  final String priority;

  bool get hasRisk => riskSignals.isNotEmpty;
}

HealthRiskAssessment evaluateHealthRisk(
  Map<String, String> currentValues, {
  HealthRiskThresholds thresholds = defaultHealthRiskThresholds,
}) {
  final riskSignals = <String>[];
  final metricHighlights = <String>[];
  var isCritical = false;

  final bloodPressure = currentValues['血压']?.trim() ?? '';
  final heartRate = currentValues['心率']?.trim() ?? '';
  final oxygen = currentValues['血氧']?.trim() ?? '';
  final temperature = currentValues['体温']?.trim() ?? '';

  final bpParts = bloodPressure.split('/');
  if (bpParts.length == 2) {
    final systolic = int.tryParse(bpParts[0]);
    final diastolic = int.tryParse(bpParts[1]);
    if ((systolic ?? 0) >= thresholds.highSystolic || (diastolic ?? 0) >= thresholds.highDiastolic) {
      riskSignals.add('血压偏高需复测确认');
      metricHighlights.add('血压 $bloodPressure');
    }
    if ((systolic ?? 0) >= thresholds.criticalSystolic || (diastolic ?? 0) >= thresholds.criticalDiastolic) {
      isCritical = true;
    }
  }

  final heartRateValue = int.tryParse(heartRate);
  if ((heartRateValue ?? 0) >= thresholds.tachycardia ||
      (heartRateValue != null && heartRateValue <= thresholds.bradycardia)) {
    riskSignals.add('心率异常需人工复核');
    metricHighlights.add('心率 $heartRate');
  }
  if ((heartRateValue ?? 0) >= thresholds.criticalTachycardia ||
      (heartRateValue != null && heartRateValue <= thresholds.criticalBradycardia)) {
    isCritical = true;
  }

  final oxygenValue = int.tryParse(oxygen);
  if (oxygenValue != null && oxygenValue <= thresholds.lowOxygen) {
    riskSignals.add('血氧偏低需评估是否升级');
    metricHighlights.add('血氧 $oxygen%');
  }
  if (oxygenValue != null && oxygenValue <= thresholds.criticalOxygen) {
    isCritical = true;
  }

  final temperatureValue = double.tryParse(temperature);
  if (temperatureValue != null && temperatureValue >= thresholds.fever) {
    riskSignals.add('体温升高需结合症状解释');
    metricHighlights.add('体温 $temperature℃');
  }
  if (temperatureValue != null && temperatureValue >= thresholds.criticalFever) {
    isCritical = true;
  }

  final priority = isCritical || riskSignals.length >= 2 ? 'P1' : 'P2';

  return HealthRiskAssessment(
    metricHighlights: metricHighlights,
    riskSignals: riskSignals,
    priority: priority,
  );
}