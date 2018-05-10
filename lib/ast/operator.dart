import 'token.dart';

class Operator extends Token {
  final String op;
  Operator(this.op);

  @override
  String toString() => op;
}
