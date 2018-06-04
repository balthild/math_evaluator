import 'dart:math' as math;
import 'package:math_evaluator/util.dart';
import 'contract/token.dart';
import 'contract/calculable.dart';
import 'degree.dart';
import 'complex.dart';

class Number implements Calculable, Token {
  final num value;
  const Number(this.value);

  String toString() {
    return numToString(value);
  }

  Calculable operator -() => new Number(-value);

  Calculable operator +(Calculable x) {
    if (x is Degree)
      return new Number(value + x.toRadius());
    else if (x is Number)
      return new Number(value + x.value);
    else if (x is Complex)
      return x + this;

    throw "Unknown error";
  }

  Calculable operator -(Calculable x) => this + (-x);

  Calculable operator *(Calculable x) {
    if (x is Degree)
      return x * this;
    else if (x is Number)
      return new Number(value * x.value);
    else if (x is Complex)
      return x * this;

    throw "Unknown error";
  }

  Calculable operator /(Calculable x) {
    if (x is Degree)
      return new Number(value / x.toRadius());
    else if (x is Number)
      return new Number(value / x.value);
    else if (x is Complex)
      return new Complex(value, 0) / x;

    throw "Unknown error";
  }

  Calculable operator %(Calculable x) {
    if (x is Degree)
      return new Number(value % x.toRadius());
    else if (x is Number)
      return new Number(value % x.value);
    else if (x is Complex)
      throw "Complex numbers do not support modulo operation";

    throw "Unknown error";
  }

  Calculable power(Calculable x) {
    if (x is Degree)
      return new Number(math.pow(value, x.toRadius()));
    else if (x is Number)
      return new Number(math.pow(value, x.value));
    else if (x is Complex)
      return Complex.realPowerComplex(value, x);

    throw "Unknown error";
  }

  Calculable factorial() {
    if (value is double || value < 0)
      throw "Only integers that greater than 0 have factorial";

    return new Number(fact(value as int));
  }

  Calculable sqrt() => new Number(math.sqrt(value));
  Calculable sin() => new Number(math.sin(value));
  Calculable cos() => new Number(math.cos(value));
  Calculable tan() => new Number(math.tan(value));
  Calculable exp() => new Number(math.exp(value));
  Calculable ln() => new Number(math.log(value));
  Calculable log2() => new Number(math.log(value) / math.ln2);
  Calculable log10() => new Number(math.log(value) / math.ln10);
  Calculable norm() => new Number(value.abs());
  Calculable Re() => this;
  Calculable Im() => const Number(0);
}
