import 'package:math_evaluator/parse.dart';
import 'contract/element.dart';
import 'contract/evaluable.dart';
import 'contract/calculable.dart';
import 'contract/token.dart';
import 'operator.dart';

class Group implements Evaluable {
  final List<Token> tokens;
  Group(this.tokens) {
    // Trim "(" and ")" pair
    while (tokens.length > 0) {
      var start = tokens[0], end = tokens.last;
      if (start is Operator && start.name == "(" && end is Operator && end.name == ")") {
        tokens.removeAt(0);
        tokens.removeLast();
      } else break;
    }
  }

  Calculable evaluate() {
    if (tokens.length == 1) {
      final inner = tokens[0];
      if (inner is Calculable)
        return inner as Calculable;
      else if (inner is Evaluable)
        return (inner as Evaluable).evaluate();
    }

    final root = parse(tokens);

    if (root is Calculable)
      return root;
    else if (root is Evaluable)
      return root.evaluate();

    throw "Unknown error";
  }

  List<Element> toFuncParameters() {
    List<Element> parameters = [];

    List<Token> children = [];
    for (var token in tokens) {
      if (token is Operator && token.name == ",") {
        assert(tokens.isNotEmpty, "Unexpected token , after (");

        if (children.length == 1)
          parameters.add(children[0]);
        else
          parameters.add(new Group(children));

        children = [];
      } else {
        children.add(token);
      }
    }

    if (children.isEmpty)
      throw "Unexpected token ) after ,";

    if (children.length == 1)
      parameters.add(children[0]);
    else
      parameters.add(new Group(children));

    return parameters;
  }

  @override
  String toString() {
    return "Group: " + tokens.toString();
  }
}
