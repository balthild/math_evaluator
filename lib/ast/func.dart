import 'package:math_evaluator/functions.dart';
import 'package:math_evaluator/ast/element.dart';
import 'package:math_evaluator/ast/group.dart';

class Func extends Element {
  final String name;
  final List<Element> parameters;

  Func(this.name, this.parameters) {
    if (!functions.containsKey(name))
      throw "Undefined function: $name";
  }

  Element evaluate() {
    for (int i = 0; i < parameters.length; ++i) {
      var item = parameters[i];
      if (item is Func)
        parameters[i] = item.evaluate();
      else if (item is Group)
        parameters[i] = item.evaluate();
    }

    return functions[name](parameters);
  }

  @override
  String toString() => "$name(${parameters.toString()})";
}
