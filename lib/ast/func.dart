import 'package:math_evaluator/functions.dart';
import 'element.dart';
import 'group.dart';
import 'literal.dart';

class Func extends Element implements Literal {
  final String name;
  final List<Element> parameters;

  Func(this.name, this.parameters) {
    if (!functions.containsKey(name))
      throw "Undefined function: $name";
  }

  Literal evaluate() {
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
