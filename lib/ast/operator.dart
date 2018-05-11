import 'contract/token.dart';

class Operator implements Token {
  final String op;
  Operator(this.op);

  @override
  String toString() => op;
}
