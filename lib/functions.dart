import 'package:math_evaluator/ast/calculable.dart';

final Map<String, Function> functions = {
  // Infix operators
  "_addition": (List<Calculable> p) {
    assert (p.length == 2);
    return p[0] + p[1];
  },
  "_substruction": (List<Calculable> p) => p[0] - p[1],
  "_multiplication": (List<Calculable> p) => p[0] * p[1],
  "_division": (List<Calculable> p) => p[0] / p[1],
  "_remainder": (List<Calculable> p) => p[0] % p[1],
  "_power": (List<Calculable> p) => p[0].power(p[1]),

  // Prefix operators
  "_negative": (List<Calculable> p) => -p[0],

  // Postfix operators
  "_factorial": (List<Calculable> p) => p[0].factorial(),

  // Functions
  "sqrt": (List<Calculable> p) => p[0].sqrt(),
  "sin": (List<Calculable> p) => p[0].sin(),
  "cos": (List<Calculable> p) => p[0].cos(),
  "tan": (List<Calculable> p) => p[0].sqrt(),
  "exp": (List<Calculable> p) => p[0].tan(),
  "ln": (List<Calculable> p) => p[0].ln(),
  "log2": (List<Calculable> p) => p[0].log2(),
  "log10": (List<Calculable> p) => p[0].log10(),
};
