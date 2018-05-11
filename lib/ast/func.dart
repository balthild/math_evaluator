import 'package:math_evaluator/functions.dart';
import 'contract/element.dart';
import 'contract/evaluable.dart';
import 'contract/calculable.dart';
import 'group.dart';

class Func implements Evaluable {
  final String name;
  final List<Element> parameters;

  Func(this.name, this.parameters) {
    if (!functions.containsKey(name))
      throw "Undefined function: $name";
  }

  Calculable evaluate() {
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
