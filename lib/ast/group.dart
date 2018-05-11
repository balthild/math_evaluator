import 'dart:math' as math;
import 'contract/element.dart';
import 'contract/evaluable.dart';
import 'contract/calculable.dart';
import 'contract/token.dart';
import 'number.dart';
import 'complex.dart';
import 'degree.dart';
import 'operator.dart';
import 'identifier.dart';
import 'func.dart';

class Group implements Evaluable {
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

  Calculable evaluate() {
    List<Element> elements;
    elements = parseGroups(tokens);
    elements = parseIdentifiers(elements);
    elements = parseOperators(elements);

    assert(elements.length == 1, "Unknown error");

    final root = elements[0];
    if (root is Number || root is Degree)
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
      if (name == "i") {
        parsed.add(new Complex(0, 1));
        continue;
      }

      if (origin.isEmpty)
        throw "Expected parentheses after function $name";

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
      final degEl = elements[i];
      if (degEl is! Operator)
        continue;

      final degOp = (degEl as Operator).op;
      if (degOp != "°")
        continue;

      if (i == 0)
        throw "Unexpected token °";

      final degLeft = elements[i - 1];
      if (degLeft is! Number)
        throw "Unexpected token °";

      final degValue = (degLeft as Number).value;
      elements.removeRange(i - 1, i + 1);
      elements.insert(i - 1, new Degree(degValue, 0, 0));
      --i;

      final j = i + 2;
      if (j > elements.length - 1)
        continue;

      final minEl = elements[j];
      if (minEl is! Operator)
        continue;

      final minOp = (minEl as Operator).op;
      if (minOp == "°")
        throw "Unexpected token °";
      if (minOp != "′")
        continue;

      final minLeft = elements[j - 1];
      if (minLeft is! Number)
        throw "Unexpected token ′";

      final minValue = (minLeft as Number).value;
      elements.removeRange(j - 1, j + 1);
      elements[i] = new Degree(degValue, minValue, 0);

      final k = j; // Left two elements have been removed
      if (k > elements.length - 1)
        continue;

      final secEl = elements[k];
      if (secEl is! Operator)
        continue;

      final secOp = (secEl as Operator).op;
      if (secOp == "°")
        throw "Unexpected token °";
      if (secOp != "″")
        continue;

      final secLeft = elements[k - 1];
      if (secLeft is! Number)
        throw "Unexpected token ″";

      final secValue = (secLeft as Number).value;
      elements.removeRange(k - 1, k + 1);
      elements[i] = new Degree(degValue, minValue, secValue);
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
      if (left is! Calculable && left is! Evaluable)
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
      if (left is! Calculable && left is! Evaluable)
        throw "Unexpected token ^";
      if (right is! Calculable && right is! Evaluable)
        throw "Expected number after ^";

      elements.removeRange(i - 1, i + 2);
      elements.insert(i - 1, new Func("_power", [left, right]));
      --i;
    }

    // Insert multiplication sign between two elements
    for (var i = 0; i < elements.length; ++i) {
      final el = elements[i];
      if (el is! Calculable && el is! Evaluable)
        continue;

      if (i + 1 == elements.length)
        break;

      final right = elements[i + 1];
      if (right is! Calculable && right is! Evaluable)
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
      if (left is! Calculable && left is! Evaluable)
        throw "Unexpected token $op";
      if (right is! Calculable && right is! Evaluable)
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
      if (right is! Calculable && right is! Evaluable)
        throw "Unexpected token after $op";

      var left = null;
      if (i != 0)
        left = elements[i - 1];

      if (i != 0 && (left is Calculable || left is Group))
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
      if (left is! Calculable && left is! Evaluable)
        throw "Unexpected token $op";
      if (right is! Calculable && right is! Evaluable)
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
