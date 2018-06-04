import 'contract/element.dart';
import 'contract/evaluable.dart';
import 'contract/calculable.dart';
import 'difinition/functions.dart';

class Func implements Evaluable {
  final String name;
  final List<Element> parameters;

  Func(this.name, this.parameters) {
    if (!functions.containsKey(name))
      throw "Undefined function: $name";
  }

  Calculable evaluate() {
    List<Calculable> evaluatedParameters = [];

    for (final p in parameters) {
      if (p is Evaluable)
        evaluatedParameters.add(p.evaluate());
      else
        evaluatedParameters.add(p);
    }

    return functions[name](evaluatedParameters);
  }

  @override
  String toString() => "$name(${parameters.toString()})";
}
