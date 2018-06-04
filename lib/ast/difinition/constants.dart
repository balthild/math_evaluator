import 'dart:math' as math;
import 'package:math_evaluator/ast/contract/calculable.dart';
import 'package:math_evaluator/ast/number.dart';
import 'package:math_evaluator/ast/complex.dart';

final Map<String, Calculable> constants = {
  "e": new Number(math.e),
  "π": new Number(math.pi),
  "i": new Complex(0, 1),
};
