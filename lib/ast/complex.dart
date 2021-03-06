import 'dart:math' as math;
import 'package:math_evaluator/util.dart';
import 'contract/calculable.dart';
import 'number.dart';
import 'degree.dart';

class Complex implements Calculable {
  final num re, im, r, arg;
  const Complex._(this.re, this.im, this.r, this.arg);

  factory Complex(num re, num im) {
    final norm = math.sqrt(math.pow(re, 2) + math.pow(im, 2));
    return new Complex._(
      re,
      im,
      norm,
      re == 0 && im == 0 ? null : (im >= 0 ? 1 : -1) * math.acos(re / norm),
    );
  }

  factory Complex.tr(num a, num theta) => new Complex._(
    a * math.cos(theta),
    a * math.sin(theta),
    a,
    theta,
  );

  String toString() {
    final imStr = numToString(im);
    if (imStr == "0")
      return numToString(re);

    final reStr = numToString(re);
    if (reStr == "0") {
      if (imStr == "1")
        return "i";
      else if (imStr == "-1")
        return "-i";
      else
        return "$imStr i";
    }

    if (imStr == "1")
      return "$reStr + i";
    else if (imStr == "-1")
      return "$reStr - i";
    else if (imStr.startsWith("-"))
      return "$reStr - ${imStr.substring(1)} i";
    else
      return "$reStr + $imStr i";
  }

  // iz = -y + ix
  Complex iz() => new Complex(-im, re);

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
    if (a == 0)
      return new Complex(0, 0);

    final ax = math.pow(a, z.re);
    return new Complex.tr(ax, z.im * math.log(a));
  }

  static Complex complexPowerComplex(Complex w, Complex z) {
    if (w.im == 0) {
      return realPowerComplex(w.re, z);
    }

    // Denote w as a*e^(iθ)
    final az = realPowerComplex(w.r, z);
    return az * (new Complex(0, w.arg) * z).exp();
  }

  static Complex complexPowerReal(Complex w, num x) {
    if (w.im == 0) {
      return new Complex(math.pow(w.re, x), 0);
    }

    final ax = math.pow(w.r, x);
    return new Complex.tr(ax, w.arg * x);
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
      // (a+bi) / (c-di) = (ac+bd) / (c^2+d^2) + (bc-ad)i / (c^2+d^2)
      return new Complex(
        (re * x.re + im * x.im) / x.r,
        (im * x.re - re * x.im) / x.r
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
  Calculable ln() => new Complex(math.log(r), arg);
  Calculable log2() => new Complex(math.log(r) / math.ln2, arg / math.ln2);
  Calculable log10() => new Complex(math.log(r) / math.ln10, arg / math.ln10);

  Calculable norm() => new Number(r);
  Calculable Re() => new Number(re);
  Calculable Im() => new Number(im);
}
