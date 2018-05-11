import 'dart:math' as math;
import 'package:math_evaluator/util.dart';
import 'contract/calculable.dart';
import 'contract/token.dart';
import 'number.dart';

class Degree implements Calculable, Token {
  final int degree, minute;
  final num second;
  Degree._(int this.degree, int this.minute, num this.second);

  factory Degree(num degree, num minute, num second) {
    if (degree is double) {
      var floor = degree.floor();
      var rest = degree - floor;
      degree = floor;
      minute += 60 * rest;
    }
    if (minute is double) {
      var floor = minute.floor();
      var rest = minute - floor;
      minute = floor;
      second += 60 * rest;
    }

    while (second >= 60) {
      second -= 60;
      ++minute;
    }
    while (second < 0) {
      second += 60;
      --minute;
    }

    while (minute >= 60) {
      minute -= 60;
      ++degree;
    }
    while (minute < 0) {
      minute += 60;
      --degree;
    }

    return new Degree._(degree, minute, second);
  }

  String toString() {
    return "$degree°$minute′${numToString(second)}″";
  }

  num toRadius() => (degree + minute / 60 + second / 3600) * math.pi / 180;

  Number toNumber() => new Number(toRadius());

  Calculable operator -() {
    return new Degree(-degree, -minute, -second);
  }

  Calculable operator +(Calculable x) {
    if (x is Degree)
      return new Degree(
        degree + x.degree,
        minute + x.minute,
        second + x.second
      );
    else if (x is Number)
      return new Number(toRadius() + x.value);

    throw "Unknown error";
  }

  Calculable operator -(Calculable x) => this + (-x);

  Calculable operator *(Calculable x) {
    if (x is Number)
      return new Degree(
        degree * x.value,
        minute * x.value,
        second * x.value
      );
    else if (x is Degree)
      return new Number(toRadius() * x.toRadius());

    throw "Unknown error";
  }

  Calculable operator /(Calculable x) {
    if (x is Number)
      return new Degree(
        degree / x.value,
        minute / x.value,
        second / x.value
      );
    else if (x is Degree)
      return new Number(toRadius() / x.toRadius());

    throw "Unknown error";
  }

  Calculable operator %(Calculable x) => toNumber() % x;

  Calculable power(Calculable x) => toNumber().power(x);

  Calculable factorial() => toNumber().factorial();

  Calculable sqrt() => toNumber().sqrt();
  Calculable sin() => toNumber().sin();
  Calculable cos() => toNumber().cos();
  Calculable tan() => toNumber().tan();
  Calculable exp() => toNumber().exp();
  Calculable ln() => toNumber().ln();
  Calculable log2() => toNumber().log2();
  Calculable log10() => toNumber().log10();
}
