import 'ast/contract/calculable.dart';
import 'ast/contract/evaluable.dart';
import 'ast/number.dart';
import 'lex.dart';
import 'parse.dart';

Calculable evaluate(String input) {
  input = input.trim();

  if (input.isEmpty)
    return new Number(0);

  final root = parse(lex(input));

  if (root is Calculable)
    return root;
  else if (root is Evaluable)
    return root.evaluate();

  throw "Unknown error";
}
