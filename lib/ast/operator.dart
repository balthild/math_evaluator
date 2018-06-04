import 'contract/token.dart';

class Operator implements Token {
  final String name;
  Operator(this.name);

  @override
  String toString() => name;
}
