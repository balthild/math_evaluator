String numToString(num n) {
  if (n is int)
    return n.toString();

  var str = num.parse(n.toStringAsFixed(12)).toString();

  if (str.endsWith(".0"))
    str = str.substring(0, str.length - 2);

  if (str == "-0")
    str = "0";

  return str;
}

int fact(int n) => n == 0 ? 1 : n * fact(n - 1);
