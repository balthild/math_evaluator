import 'dart:math' as math;
import 'package:math_evaluator/util.dart';
import 'contract/calculable.dart';
import 'number.dart';
import 'degree.dart';

class Complex implements Calculable {
  final num re, im;
  Complex(this.re, this.im);

  factory Complex.tr(num a, num theta) => new Complex(
    a * math.cos(theta),
    a * math.sin(theta)
  );

  String toString() {
    var imStr = numToString(im);
    if (imStr == "0")
      return numToString(re);

    return "${numToString(re)} + $imStr i";
  }

  // iz = -y + ix
  Complex iz() => new Complex(-im, re);

  double norm() => math.sqrt(math.pow(re, 2) + math.pow(im, 2));

  double arg() {
    assert(re != 0 && im != 0);

    final r = norm();
    return (im >= 0 ? 1 : -1) * math.acos(re / r);
  }

  // http://mathforum.org/library/drmath/view/52251.html
  // Any real number a can be written as e^ln(a); so
  //     a^(ix) = (e^ln(a))^(ix)
  //            = e^(ix*ln(a))
  //            = cos(x*ln(a)) + i*sin(x*ln(a))
  // We can extend this to complex exponents this way:
  //     a^(x+iy) = a^x * a^(iy)
  // To allow for complex bases, write the base in the form a*e^(ib), and
  // you find
  //     [a*e^(ib)]^z = a^z * e^(ib*z)
  // These ideas will allow you to raise any real or complex base to any
  // real or complex exponent.
  static Complex realPowerComplex(num a, Complex z) {
    final ax = math.pow(a, z.re);
    return new Complex.tr(ax, z.im * math.log(a));
  }

  static Complex complexPowerComplex(Complex w, Complex z) {
    // Denote w as a*e^(iθ)
    final a = w.norm(), theta = w.arg();
    final az = realPowerComplex(a, z);
    return az * (new Complex(0, theta) * z).exp();
  }

  static Complex complexPowerReal(Complex w, num x) {
    // Denote w as a*e^(iθ)
    final a = w.norm(), theta = w.arg();
    final ax = math.pow(a, x);
    return new Complex.tr(ax, theta * x);
  }

  Calculable operator -() => new Complex(-re, -im);

  Calculable operator +(Calculable x) {
    if (x is Degree)
      return new Complex(re + x.toRadius(), im);
    else if (x is Number)
      return new Complex(re + x.value, im);
    else if (x is Complex)
      return new Complex(re + x.re, im + x.im);

    throw "Unknown error";
  }

  Calculable operator -(Calculable x) => this + (-x);

  Calculable operator *(Calculable x) {
    if (x is Degree)
      return new Complex(re * x.toRadius(), im * x.toRadius());
    else if (x is Number)
      return new Complex(re * x.value, im * x.value);
    else if (x is Complex)
      // (a+bi) * (c-di) = (ac-bd) + (ad+bc)i
      return new Complex(re * x.re - im * x.im, re * x.im + im * x.re);

    throw "Unknown error";
  }

  Calculable operator /(Calculable x) {
    if (x is Degree)
      return new Complex(re / x.toRadius(), im / x.toRadius());
    else if (x is Number)
      return new Complex(re / x.value, im / x.value);
    else if (x is Complex) {
      // (a+bi) / (c-di) = (ac+bd) / (c^2+d^2) + (bc-ad) / (c^2+d^2)i
      var r = (math.pow(x.re, 2) + math.pow(x.im, 2));
      return new Complex(
        (re * x.re + im * x.im) / r,
        (im * x.re - re * x.im) / r
      );
    }

    throw "Unknown error";
  }

  Calculable operator %(Calculable x) {
    throw "Complex numbers do not support modulo operation.";
  }

  Calculable power(Calculable x) {
    if (x is Degree)
      return complexPowerReal(this, x.toRadius());
    else if (x is Number)
      return complexPowerReal(this, x.value);
    else if (x is Complex)
      return complexPowerComplex(this, x);

    throw "Unknown error";
  }

  Calculable factorial() {
    throw "Complex numbers do not have factorial.";
  }

  Calculable sqrt() => complexPowerReal(this, 0.5);

  //   exp(iz) = cos(z) + i sin(z)
  //  exp(-iz) = cos(z) - i sin(z)
  //  2 cos(z) = exp(iz) + exp(-iz)
  // 2i sin(z) = exp(iz) - exp(-iz)
  Calculable sin() => (iz().exp() - (-iz()).exp()) / new Complex(0, 2);
  Calculable cos() => (iz().exp() + (-iz()).exp()) / new Number(2);
  Calculable tan() => sin() / cos();
  Calculable exp() => new Complex.tr(math.exp(re), im);

  // ln(z) = ln(r) + iθ
  Calculable ln() => new Complex(math.log(norm()), arg());
  Calculable log2() => new Complex(math.log(norm()) / math.ln2, arg() / math.ln2);
  Calculable log10() => new Complex(math.log(norm()) / math.ln10, arg() / math.ln10);
}
