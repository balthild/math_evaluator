import 'dart:math' as math;
import 'ast/contract/calculable.dart';
import 'ast/number.dart';
import 'ast/complex.dart';

final Map<String, Calculable> constants = {
  "e": new Number(math.e),
  "π": new Number(math.pi),
  "i": new Complex(0, 1),
};
