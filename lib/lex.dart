import 'ast/contract/token.dart';
import 'ast/operator.dart';
import 'ast/number.dart';
import 'ast/identifier.dart';
import 'package:math_evaluator/ast/difinition/functions.dart';
import 'package:math_evaluator/ast/difinition/constants.dart';

final operators = [
  "(", ")", ",",
  "°", "′", "″", "!",
  "^",
  "*", "/", "%",
  "+", "-"
];
final digitTest = new RegExp(r"[0-9]");
final whitespaceTest = new RegExp(r"\s");
final identifierStartTest = new RegExp(r"[A-Za-z]");
final identifierTest = new RegExp(r"[A-Za-z0-9]");
final specialIdentifiers = ["π"];

bool isOperator(String c) => operators.contains(c);
bool isDigit(String c) => digitTest.hasMatch(c);
bool isWhiteSpace(String c) => whitespaceTest.hasMatch(c);
bool isIdentifierStart(c) => identifierStartTest.hasMatch(c);
bool isIdentifier(c) => identifierTest.hasMatch(c);
bool isSpecialIdentifier(c) => specialIdentifiers.contains(c);

List<Token> lex(String expr) {
  List<Token> tokens = [];
  int i = 0;
  String char;

  String advance() {
    if (++i < expr.length)
      return char = expr[i];
    else
      return "";
  }

  while (i < expr.length) {
    char = expr[i];

    if (isWhiteSpace(char)) {
      advance();
      continue;
    }

    if (isOperator(char)) {
      tokens.add(new Operator(char));
      advance();
      continue;
    }

    if (isDigit(char)) {
      String str = char;
      while (isDigit(advance()))
        str += char;

      // Is floating-point number
      if (char == ".")
        do str += char; while (isDigit(advance()));

      var n = num.parse(str);
      assert(n is num, throw "Number is too large or too small for 64-bit.");

      tokens.add(new Number(n));
      continue;
    }

    if (isSpecialIdentifier(char)) {
      if (!functions.containsKey(char) && !constants.containsKey(char))
        throw "Unknown identifier $char";

      tokens.add(new Identifier(char));
      advance();
      continue;
    }

    if (isIdentifierStart(char)) {
      String idn = char;
      while (isIdentifier(advance()))
        idn += char;

      if (!functions.containsKey(idn) && !constants.containsKey(idn))
        throw "Unknown identifier $idn";

      tokens.add(new Identifier(idn));
      continue;
    }

    throw "Unrecognized token.";
  }

  return tokens;
}
