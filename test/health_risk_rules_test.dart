import 'package:flutter_test/flutter_test.dart';
import 'package:nursing_nani_app/app/data/config/health_risk_rules.dart';

void main() {
  test('does not flag values below configured thresholds', () {
    final assessment = evaluateHealthRisk({
      '血压': '149/94',
      '心率': '109',
      '血氧': '94',
      '体温': '37.7',
    });

    expect(assessment.hasRisk, isFalse);
    expect(assessment.priority, 'P2');
  });

  test('flags configured elevated values as high risk', () {
    final assessment = evaluateHealthRisk({
      '血压': '150/95',
    });

    expect(assessment.hasRisk, isTrue);
    expect(assessment.riskSignals, contains('血压偏高需复测确认'));
    expect(assessment.priority, 'P2');
  });

  test('escalates to P1 for multi-signal high risk', () {
    final assessment = evaluateHealthRisk({
      '血压': '156/98',
      '血氧': '92',
    });

    expect(assessment.hasRisk, isTrue);
    expect(assessment.priority, 'P1');
    expect(assessment.metricHighlights, contains('血压 156/98'));
    expect(assessment.metricHighlights, contains('血氧 92%'));
  });
}