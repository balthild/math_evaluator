import 'dart:math' as math;
import 'func.dart';
import 'package:math_evaluator/ast/element.dart';
import 'package:math_evaluator/ast/token/token.dart';
import 'package:math_evaluator/ast/token/number.dart';
import 'package:math_evaluator/ast/token/operator.dart';
import 'package:math_evaluator/ast/token/identifier.dart';

class Group extends Element {
  final List<Token> tokens;
  Group(this.tokens) {
    // Trim "(" and ")" pair
    while (tokens.length > 0) {
      var start = tokens[0], end = tokens.last;
      if (start is Operator && start.op == "(" && end is Operator && end.op == ")") {
        tokens.removeAt(0);
        tokens.removeLast();
      } else break;
    }
  }

  Element evaluate() {
    List<Element> elements;
    elements = parseGroups(tokens);
    elements = parseIdentifiers(elements);
    elements = parseOperators(elements);

    assert(elements.length == 1, "Unknown error");

    final root = elements[0];
    if (root is Number)
      return root;
    else if (root is Func)
      return root.evaluate();

    throw "Unknown error";
  }

  List<Element> parseGroups(List<Element> origin) {
    List<Element> parsed = [];

    int depth = 0;
    Group subGroup = new Group([]);

    for (var token in origin) {
      if (token is Operator && token.op == "(") {
        ++depth;
        if (depth == 1)
          continue;
      }

      if (token is Operator && token.op == ")") {
        --depth;

        if (depth == 0) {
          parsed.add(subGroup);
          subGroup = new Group([]);
          continue;
        } else if (depth < 0) {
          throw "Unexpected token )";
        }
      }

      if (depth > 0)
        subGroup.tokens.add(token);
      else
        parsed.add(token);
    }

    return parsed;
  }

  List<Element> parseIdentifiers(List<Element> origin) {
    List<Element> parsed = [];

    while (origin.length > 0) {
      final el = origin.removeAt(0);
      if (el is! Identifier) {
        parsed.add(el);
        continue;
      }

      var name = (el as Identifier).name;
      if (name == "π") {
        parsed.add(new Number(math.pi));
        continue;
      }
      if (name == "e") {
        parsed.add(new Number(math.e));
        continue;
      }

      var right = origin[0];
      if (right is Group) {
        parsed.add(new Func(name, right.toFuncParameters()));
        origin.removeAt(0);
        continue;
      }

      throw "Expected parentheses after function $name";
    }

    return parsed;
  }

  List<Element> parseOperators(List<Element> elements) {
    for (var el in elements) {
      if (el is Operator && el.op == ",")
        throw "Unexpected token ,";
    }

    // Angle by degrees
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Operator)
        continue;

      final op = (el as Operator).op;
      if (op != "°")
        continue;

      if (i == 0)
        throw "Unexpected token °";

      var left = elements[i - 1];
      if (left is! Number && left is! Group && left is! Func)
        throw "Unexpected token °";

      elements.removeRange(i - 1, i + 1);
      elements.insert(i - 1, new Func("_factorial", [left]));
      --i;
    }

    // Factorial
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Operator)
        continue;

      final op = (el as Operator).op;
      if (op != "!")
        continue;

      if (i == 0)
        throw "Unexpected token !";

      var left = elements[i - 1];
      if (left is! Number && left is! Group && left is! Func)
        throw "Unexpected token !";

      elements.removeRange(i - 1, i + 1);
      elements.insert(i - 1, new Func("_factorial", [left]));
      --i;
    }

    // Power
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Operator)
        continue;

      final op = (el as Operator).op;
      if (op != "^")
        continue;

      if (i + 1 == elements.length)
        throw "Unexpected EOF";
      if (i == 0)
        throw "Unexpected token $op";

      var left = elements[i - 1], right = elements[i + 1];
      if (left is! Number && left is! Group && left is! Func)
        throw "Unexpected token ^";
      if (right is! Number && right is! Group && right is! Func)
        throw "Expected number after ^";

      elements.removeRange(i - 1, i + 2);
      elements.insert(i - 1, new Func("_power", [left, right]));
      --i;
    }

    // Insert multiplication sign between two elements
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Number && el is! Group && el is! Func)
        continue;

      if (i + 1 == elements.length)
        break;

      final right = elements[i + 1];
      if (right is! Number && right is! Group && right is! Func)
        continue;

      elements.insert(++i, new Operator("*"));
    }

    // Multiplication, division and remainder
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Operator)
        continue;

      final op = (el as Operator).op;
      if (op != "*" && op != "/" && op != "%")
        continue;

      if (i + 1 == elements.length)
        throw "Unexpected EOF";
      if (i == 0)
        throw "Unexpected token $op";

      final left = elements[i - 1], right = elements[i + 1];
      if (left is! Number && left is! Group && left is! Func)
        throw "Unexpected token $op";
      if (right is! Number && right is! Group && right is! Func)
        throw "Unexpected token after $op";

      var name = "";
      switch (op) {
        case "*": name = "_multiplication"; break;
        case "/": name = "_division"; break;
        case "%": name = "_remainder"; break;
      }

      elements.removeRange(i - 1, i + 2);
      elements.insert(i - 1, new Func(name, [left, right]));
      --i;
    }

    // Negative
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Operator)
        continue;

      final op = (el as Operator).op;
      if (op != "-")
        continue;

      if (i + 1 == elements.length)
        throw "Unexpected EOF";

      final right = elements[i + 1];
      if (right is! Number && right is! Group && right is! Func)
        throw "Unexpected token after $op";

      var left = null;
      if (i != 0)
        left = elements[i - 1];

      if (i != 0 && (left is Number || left is Group || left is Func))
        continue;

      elements.removeRange(i, i + 2);
      elements.insert(i, new Func("_negative", [right]));
    }

    // Addition and substruction
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Operator)
        continue;

      if (i + 1 == elements.length)
        throw "Unexpected EOF";

      final op = (el as Operator).op;
      if (op != "+" && op != "-" && op != "%")
        continue;

      if (i == 0)
        throw "Unexpected token $op";

      final left = elements[i - 1], right = elements[i + 1];
      if (left is! Number && left is! Group && left is! Func)
        throw "Unexpected token $op";
      if (right is! Number && right is! Group && right is! Func)
        throw "Unexpected token after $op";

      var name = "";
      switch (op) {
        case "+": name = "_addition"; break;
        case "-": name = "_substruction"; break;
      }

      elements.removeRange(i - 1, i + 2);
      elements.insert(i - 1, new Func(name, [left, right]));
      --i;
    }

    return elements;
  }

  List<Group> toFuncParameters() {
    List<Element> parameters = [];

    var item = new Group([]);
    for (var token in tokens) {
      if (token is Operator && token.op == ",") {
        if (item.tokens.length == 0)
          throw "Unexpected token ,";
        else if (item.tokens.length == 1)
          parameters.add(item.tokens[0]);
        else
          parameters.add(item);

        item = new Group([]);
      } else {
        item.tokens.add(token);
      }
    }

    if (item.tokens.length == 0)
      throw "Unexpected token ) after ,";

    parameters.add(item);
    return parameters;
  }

  @override
  String toString() {
    return "Group: " + tokens.toString();
  }
}
