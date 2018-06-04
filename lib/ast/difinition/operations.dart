enum PriorityType {
  Prefix, Postfix, InfixL, InfixR
}

class Priority {
  final PriorityType type;
  final Map<String, String> ops;
  const Priority(this.type, this.ops);
}

final operations = [
  // http://mathworld.wolfram.com/Precedence.html
  new Priority(PriorityType.Postfix, {
    "!": "_factorial",
  }),
  new Priority(PriorityType.InfixR, {
    "^": "_power",
  }),
  new Priority(PriorityType.InfixL, {
    "*": "_multiplication",
    "/": "_division",
    "%": "_remainder",
  }),
  new Priority(PriorityType.Prefix, {
    "~": "_negative", // Transformed
  }),
  new Priority(PriorityType.InfixL, {
    "+": "_addition",
    "-": "_substruction",
  }),
];
