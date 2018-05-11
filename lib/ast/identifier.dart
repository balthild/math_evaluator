import 'contract/token.dart';

class Identifier implements Token {
  final String name;
  Identifier(this.name);

  @override
  String toString() => name;
}
