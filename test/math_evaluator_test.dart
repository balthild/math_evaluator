import 'package:test/test.dart';
import 'package:math_evaluator/evalutaor.dart';

void main() {
  test('parsing', () {
    expect(evaluate("").toString(), "0");
    expect(evaluate("6 * (3 + 4)").toString(), "42");
    expect(evaluate("6 * 3 + 4").toString(), "22");
    expect(evaluate("6 * sin(3+4)").toString(), "3.941919592313");
    expect(evaluate("10!").toString(), "3628800");
    expect(evaluate("2° 3′5″").toString(), "2°3′5″");
    expect(evaluate("2+3i").toString(), "2 + 3 i");
  });

  test('constants', () {
    expect(evaluate("e").toString(), "2.718281828459");
    expect(evaluate("π").toString(), "3.14159265359");
    expect(evaluate("i").toString(), "i");
  });

  test('calculations', () {
    expect(evaluate("2° 3′5″ * 2° 3′5″").toString(), "0.001281889921");
    expect(evaluate("e^2").toString(), "7.389056098931");
    expect(evaluate("e^i").toString(), "0.540302305868 + 0.841470984808 i");
    expect(evaluate("e^(iπ)").toString(), "-1");
    expect(evaluate("i^3").toString(), "-i");
    expect(evaluate("2^3^2").toString(), "512"); // 2^3^2 == 2^(3^2) != (2^3)^2
  });

  test('functions', () {
    expect(evaluate("tan(π/4)").toString(), "1");
    expect(evaluate("sin(π/6)").toString(), "0.5");
    expect(evaluate("cos(π/3)").toString(), "0.5");
    expect(evaluate("sin(e+π)^2 + cos(e+π)^2").toString(), "1");
    expect(evaluate("exp(ln(100))").toString(), "100");
    expect(evaluate("log2(1024)").toString(), "10");
    expect(evaluate("log10(1000)").toString(), "3");
    expect(evaluate("log(3, 81)").toString(), "4");
    expect(evaluate("Re(2+3i)").toString(), "2");
    expect(evaluate("Im(2+3i)").toString(), "3");
    expect(evaluate("abs(-5)").toString(), "5");
    expect(evaluate("norm(3+4i)").toString(), "5");
    expect(evaluate("P(5, 2)").toString(), "20");
    expect(evaluate("C(5, 2)").toString(), "10");
  });
}
