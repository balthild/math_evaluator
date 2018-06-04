import 'package:math_evaluator/util.dart';
import 'package:math_evaluator/ast/contract/calculable.dart';
import 'package:math_evaluator/ast/number.dart';

bool isInt(Calculable x) => x is Number && x.value is int;

final Map<String, Function> functions = {
  // Infix operators
  "_addition": (List<Calculable> p) => p[0] + p[1],
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
  "tan": (List<Calculable> p) => p[0].tan(),
  "exp": (List<Calculable> p) => p[0].exp(),
  "ln": (List<Calculable> p) => p[0].ln(),
  "log2": (List<Calculable> p) => p[0].log2(),
  "log10": (List<Calculable> p) => p[0].log10(),
  "log": (List<Calculable> p) => p[1].ln() / p[0].ln(),
  "abs": (List<Calculable> p) => p[0].norm(),
  "norm": (List<Calculable> p) => p[0].norm(),
  "Re": (List<Calculable> p) => p[0].Re(),
  "Im": (List<Calculable> p) => p[0].Im(),

  "P": (List<Calculable> p) {
    final n = p[0], k = p[1];
    assert(isInt(n) && isInt(k), "Parameters for P(n, k) must be integers");
    return new Number(perm((n as Number).value, (k as Number).value));
  },
  "C": (List<Calculable> p) {
    final n = p[0], k = p[1];
    assert(isInt(n) && isInt(k), "Parameters for C(n, k) must be integers");
    return new Number(comb((n as Number).value, (k as Number).value));
  },
};
