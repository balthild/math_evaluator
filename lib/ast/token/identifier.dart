import 'package:math_evaluator/ast/token/token.dart';

class Identifier extends Token {
  final String name;
  Identifier(this.name);

  @override
  String toString() => name;
}
