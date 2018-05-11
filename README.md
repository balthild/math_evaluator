# math_evaluator

An interpreter for math expressions. Supports real and complex numbers.

**Note**: This library is still in an early state, the test coverage is not perfect, the performance is not optimized and some features are still unimplemented.

## Usage

```dart
var result = evaluate("1+sin(π/2)");
print(result); // prints "2"
```

## TODO

- [x] Supporting complex numbers.
- [ ] Increase test coverage and stability.
