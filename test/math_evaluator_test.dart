import 'package:test/test.dart';
import 'package:math_evaluator/evalutaor.dart';

void main() {
  test('calculate', () {
    expect(evaluate("").toString(), "0");
    expect(evaluate("6 * (3 + 4)").toString(), "42");
    expect(evaluate("6 * 3 + 4").toString(), "22");
    expect(evaluate("6 * sin(3+4)").toString(), "3.941919592313");
    expect(evaluate("e^2").toString(), "7.389056098931");
    expect(evaluate("π").toString(), "3.14159265359");
    expect(evaluate("10!").toString(), "3628800");
    expect(evaluate("sin(e+π)^2 + cos(e+π)^2").toString(), "1");
    expect(evaluate("2° 3′5″").toString(), "2°3′5″");
    expect(evaluate("2° 3′5″ * 2° 3′5″").toString(), "0.001281889921");
    expect(evaluate("2+3i").toString(), "2 + 3 i");
    expect(evaluate("e^i").toString(), "0.540302305868 + 0.841470984808 i");
    expect(evaluate("e^(iπ)").toString(), "-1");
  });
}
