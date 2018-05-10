abstract class Calculable {
  Calculable operator -();
  Calculable operator +(Calculable x);
  Calculable operator -(Calculable x);
  Calculable operator *(Calculable x);
  Calculable operator /(Calculable x);
  Calculable operator %(Calculable x);

  Calculable power(Calculable x);

  Calculable factorial();
  Calculable sqrt();
  Calculable sin();
  Calculable cos();
  Calculable tan();
  Calculable exp();
  Calculable ln();
  Calculable log2();
  Calculable log10();
}
