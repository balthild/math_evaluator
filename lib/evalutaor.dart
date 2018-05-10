import 'package:math_evaluator/ast/element.dart';
import 'package:math_evaluator/ast/group.dart';
import 'package:math_evaluator/ast/token/token.dart';
import 'package:math_evaluator/ast/token/operator.dart';
import 'package:math_evaluator/ast/token/number.dart';
import 'package:math_evaluator/ast/token/identifier.dart';

Element evaluate(String input) {
  if (input.isEmpty)
    return new Number(0);

  return new Group(lex(input)).evaluate();
}

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

List<int> a = [1];

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

    if (isIdentifierStart(char)) {
      String idn = char;
      while (isIdentifier(advance()))
        idn += char;

      tokens.add(new Identifier(idn));
      continue;
    }

    if (isSpecialIdentifier(char)) {
      tokens.add(new Identifier(char));
      advance();
      continue;
    }

    throw "Unrecognized token.";
  }

  return tokens;
}
