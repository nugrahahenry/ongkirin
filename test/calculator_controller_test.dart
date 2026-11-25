import 'package:flutter_test/flutter_test.dart';

import 'package:ongkirin/features/calculator/calculator_controller.dart';

void main() {
  test('weight additions keep displayed value and grams in sync', () {
    final controller = CalculatorController();

    controller.addWeight(250);
    expect(controller.weightText, '250');
    expect(controller.weightUnit, 'gram');
    expect(controller.weightInGrams, 250);

    controller.addWeight(250);
    expect(controller.weightText, '500');
    expect(controller.weightUnit, 'gram');
    expect(controller.weightInGrams, 500);

    controller.addWeight(1000);
    expect(controller.weightText, '1.5');
    expect(controller.weightUnit, 'kg');
    expect(controller.weightInGrams, 1500);

    controller.dispose();
  });
}
