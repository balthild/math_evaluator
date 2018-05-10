import 'package:math_evaluator/ast/token/token.dart';

class Operator extends Token {
  final String op;
  Operator(this.op);

  @override
  String toString() => op;
}
