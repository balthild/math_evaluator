import 'element.dart';
import 'calculable.dart';

abstract class Evaluable extends Element {
  Calculable evaluate();
}
