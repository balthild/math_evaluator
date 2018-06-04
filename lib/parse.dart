import 'ast/contract/element.dart';
import 'ast/contract/token.dart';
import 'ast/contract/calculable.dart';
import 'ast/contract/evaluable.dart';
import 'ast/difinition/operations.dart';
import 'ast/difinition/constants.dart';
import 'ast/group.dart';
import 'ast/func.dart';
import 'ast/operator.dart';
import 'ast/number.dart';
import 'ast/degree.dart';
import 'ast/identifier.dart';

Element parse(final List<Token> tokens) {
  var elements = tokens;

  elements = trimParentheses(tokens);
  elements = parseGroups(tokens);
  elements = parseIdentifiers(elements);

  // Commas are only allowed between function parameters
  for (var el in elements) {
    if (el is Operator && el.name == ",")
      throw "Unexpected token ,";
  }

  elements = parseDegrees(elements);
  elements = addMultiplicationSigns(elements);
  elements = transformNegativeSign(elements);
  elements = parseOperations(elements);

  assert(elements.length == 1, "Unknown error");

  return elements[0];
}

List<Element> trimParentheses(List<Token> tokens) {
  while (tokens.length > 0) {
    var start = tokens[0], end = tokens.last;
    if (start is Operator && start.name == "(" && end is Operator && end.name == ")") {
      tokens.removeAt(0);
      tokens.removeLast();
    } else break;
  }
  return tokens;
}

List<Element> parseGroups(List<Token> tokens) {
  List<Element> parsed = [];

  int depth = 0;
  List<Element> children = [];

  for (var token in tokens) {
    if (token is Operator && token.name == "(") {
      ++depth;
      if (depth == 1)
        continue;
    }

    if (token is Operator && token.name == ")") {
      --depth;

      if (depth == 0) {
        parsed.add(new Group(children));
        children = [];
        continue;
      } else if (depth < 0) {
        throw "Unexpected token )";
      }
    }

    if (depth > 0)
      children.add(token);
    else
      parsed.add(token);
  }

  return parsed;
}

List<Element> parseIdentifiers(List<Element> elements) {
  List<Element> parsed = [];

  while (elements.length > 0) {
    final el = elements.removeAt(0);
    if (el is! Identifier) {
      parsed.add(el);
      continue;
    }

    var name = (el as Identifier).name;
    if (constants.containsKey(name)) {
      parsed.add(constants[name]);
      continue;
    }

    if (elements.isEmpty)
      throw "Expected parentheses after function $name";

    var right = elements[0];
    if (right is Group) {
      parsed.add(new Func(name, right.toFuncParameters()));
      elements.removeAt(0);
      continue;
    }

    throw "Expected parentheses after function $name";
  }

  return parsed;
}

List<Element> parseDegrees(List<Element> elements) {
  // Angle by degrees
  for (var i = 0; i < elements.length; ++i) {
    final degEl = elements[i];
    if (degEl is! Operator)
      continue;

    final degOp = (degEl as Operator).name;
    if (degOp != "°")
      continue;

    if (i == 0)
      throw "Unexpected token °";

    if (i > 1) {
      final last = elements[i - 2];
      if (last is Degree)
        throw "Unexpected token °";
    }

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

    final minOp = (minEl as Operator).name;
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

    final secOp = (secEl as Operator).name;
    if (secOp != "″")
      continue;

    final secLeft = elements[k - 1];
    if (secLeft is! Number)
      throw "Unexpected token ″";

    final secValue = (secLeft as Number).value;
    elements.removeRange(k - 1, k + 1);
    elements[i] = new Degree(degValue, minValue, secValue);
  }

  return elements;
}

List<Element> addMultiplicationSigns(List<Element> elements) {
  List<Element> parsed = [];

  // Insert multiplication sign between two elements
  while (elements.length > 1) {
    final el = elements.removeAt(0);
    parsed.add(el);

    if (el is! Calculable && el is! Evaluable)
      continue;

    final right = elements[0];
    if (right is Calculable || right is Evaluable)
      parsed.add(new Operator("*"));
  }

  parsed.add(elements[0]);

  return parsed;
}

List<Element> transformNegativeSign(List<Element> elements) {
  final el = elements[0];
  if (el is Operator && el.name == '-')
    elements[0] = new Operator('~');

  return elements;
}

List<Element> parseOperations(List<Element> elements) {
  for (final priority in operations) {
    final ops = priority.ops;
    switch (priority.type) {
      case PriorityType.Prefix:
        for (var i = 0; i < elements.length; ++i) {
          final el = elements[i];
          if (el is! Operator)
            continue;

          final name = (el as Operator).name;
          if (!ops.containsKey(name))
            continue;

          if (i + 1 == elements.length)
            throw "Uxpected EOF";

          final right = elements[i + 1];
          if (right is! Calculable && right is! Evaluable)
            throw "Unexpected token after $name";

          elements.removeRange(i, i + 2);
          elements.insert(i, new Func(ops[name], [right]));
        }
        break;

      case PriorityType.Postfix:
        for (var i = 0; i < elements.length; ++i) {
          final el = elements[i];
          if (el is! Operator)
            continue;

          final name = (el as Operator).name;
          if (!ops.containsKey(name))
            continue;

          if (i == 0)
            throw "Unexpected token $name";

          final left = elements[i - 1];
          if (left is! Calculable && left is! Evaluable)
            throw "Unexpected token $name";

          elements.removeRange(i - 1, i + 1);
          elements.insert(i - 1, new Func(ops[name], [left]));
          --i;
        }
        break;

      case PriorityType.InfixL:
        for (var i = 0; i < elements.length; ++i) {
          final el = elements[i];
          if (el is! Operator)
            continue;

          final name = (el as Operator).name;
          if (!ops.containsKey(name))
            continue;

          if (i + 1 == elements.length) {
            print(elements);
            print(i);
            throw "Unexpected EOF";
          }

          if (i == 0)
            throw "Unexpected token $name";

          final left = elements[i - 1], right = elements[i + 1];
          if (left is! Calculable && left is! Evaluable)
            throw "Unexpected token $name";
          if (right is! Calculable && right is! Evaluable)
            throw "Unexpected token after $name";

          elements.removeRange(i - 1, i + 2);
          elements.insert(i - 1, new Func(ops[name], [left, right]));
          --i;
        }
        break;

      case PriorityType.InfixR:
        for (var i = elements.length - 1; i >= 0; --i) {
          final el = elements[i];
          if (el is! Operator)
            continue;

          final name = (el as Operator).name;
          if (!ops.containsKey(name))
            continue;

          if (i + 1 == elements.length)
            throw "Unexpected EOF";

          if (i == 0)
            throw "Unexpected token $name";

          final left = elements[i - 1], right = elements[i + 1];
          if (left is! Calculable && left is! Evaluable)
            throw "Unexpected token $name";
          if (right is! Calculable && right is! Evaluable)
            throw "Unexpected token after $name";

          elements.removeRange(i - 1, i + 2);
          elements.insert(i - 1, new Func(ops[name], [left, right]));
          --i;
        }
    }
  }

  return elements;
  print(elements);throw "1";
}
