import 'package:flutter_test/flutter_test.dart';

import 'package:ongkirin/features/calculator/calculator_controller.dart';

void main() {
  test('weight presets keep displayed value and grams in sync', () {
    final controller = CalculatorController();

    controller.setWeightPreset(250);
    expect(controller.weightText, '250');
    expect(controller.weightUnit, 'gram');
    expect(controller.weightInGrams, 250);

    controller.setWeightPreset(2000);
    expect(controller.weightText, '2');
    expect(controller.weightUnit, 'kg');
    expect(controller.weightInGrams, 2000);

    controller.dispose();
  });
}
