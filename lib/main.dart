import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _backgroundColor = Color(0xFF171717);
const Color _numberButtonColor = Color(0xFF3B3B3B);
const Color _secondaryButtonColor = Color(0xFF323232);
const Color _zeroButtonColor = Color(0xFF2D2D2D);
const Color _equalsButtonColor = Color(0xFF76C7FF);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Máy tính cơ bản',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: _backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _equalsButtonColor,
          brightness: Brightness.dark,
        ).copyWith(surface: _backgroundColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  static const _studentLabel = '2224801030048-Huỳnh Xuân Nhã';
  static const _operators = {'+', '-', '×', '÷'};

  String _display = '0';
  bool _isEquationFinished = false;

  void _onPressed(String text) {
    if (text == '=') {
      _calculate();
      return;
    }

    setState(() {
      if (_display == 'Lỗi') {
        _display = '0';
        _isEquationFinished = false;
      }

      if (text == 'C') {
        _display = '0';
        _isEquationFinished = false;
        return;
      }

      if (text == '⌫') {
        _deleteLastCharacter();
        return;
      }

      if (_isEquationFinished) {
        if (_operators.contains(text)) {
          _isEquationFinished = false;
        } else {
          _display = text == ',' ? '0,' : text;
          _isEquationFinished = false;
          return;
        }
      }

      if (text == ',') {
        _addDecimalSeparator();
        return;
      }

      if (_operators.contains(text)) {
        _addOperator(text);
        return;
      }

      if (text == '0' && _display == '0') {
        return;
      }

      if (_display == '0') {
        _display = text;
      } else {
        _display += text;
      }
    });
  }

  void _deleteLastCharacter() {
    if (_display.length <= 1) {
      _display = '0';
      return;
    }

    _display = _display.substring(0, _display.length - 1);
    if (_display.isEmpty || _operators.contains(_display)) {
      _display = '0';
    }
  }

  void _addDecimalSeparator() {
    final currentNumber = _display.split(RegExp(r'[+\-×÷]')).last;
    if (currentNumber.contains(',')) {
      return;
    }

    if (_display.isEmpty || _operators.contains(_display)) {
      _display += '0,';
    } else if (_operators.contains(_display.substring(_display.length - 1))) {
      _display += '0,';
    } else {
      _display += ',';
    }
  }

  void _addOperator(String operator) {
    if (_display.isEmpty) {
      _display = '0$operator';
      return;
    }

    final lastCharacter = _display.substring(_display.length - 1);
    if (_operators.contains(lastCharacter)) {
      _display = '${_display.substring(0, _display.length - 1)}$operator';
    } else if (lastCharacter != ',') {
      _display += operator;
    }
  }

  void _calculate() {
    setState(() {
      try {
        final result = _evaluate(_display);
        _display = _formatResult(result);
        _isEquationFinished = true;
      } on FormatException {
        _display = 'Lỗi';
        _isEquationFinished = true;
      }
    });
  }

  double _evaluate(String expression) {
    final normalized = expression
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');
    final numbers = <double>[];
    final operators = <String>[];
    var index = 0;

    while (index < normalized.length) {
      final numberStart = index;
      while (index < normalized.length &&
          _isNumberCharacter(normalized.codeUnitAt(index))) {
        index++;
      }

      if (numberStart == index) {
        throw const FormatException('Biểu thức không hợp lệ');
      }

      numbers.add(double.parse(normalized.substring(numberStart, index)));

      if (index == normalized.length) {
        break;
      }

      final operator = normalized[index];
      if (!_isMathOperator(operator)) {
        throw const FormatException('Biểu thức không hợp lệ');
      }

      while (operators.isNotEmpty &&
          _precedence(operators.last) >= _precedence(operator)) {
        _reduce(numbers, operators);
      }
      operators.add(operator);
      index++;
    }

    while (operators.isNotEmpty) {
      _reduce(numbers, operators);
    }

    if (numbers.length != 1 || !numbers.single.isFinite) {
      throw const FormatException('Không thể tính kết quả');
    }
    return numbers.single;
  }

  void _reduce(List<double> numbers, List<String> operators) {
    if (numbers.length < 2 || operators.isEmpty) {
      throw const FormatException('Biểu thức không hợp lệ');
    }

    final right = numbers.removeLast();
    final left = numbers.removeLast();
    final operator = operators.removeLast();

    switch (operator) {
      case '+':
        numbers.add(left + right);
      case '-':
        numbers.add(left - right);
      case '*':
        numbers.add(left * right);
      case '/':
        if (right == 0) {
          throw const FormatException('Không thể chia cho 0');
        }
        numbers.add(left / right);
      default:
        throw const FormatException('Toán tử không hợp lệ');
    }
  }

  String _formatResult(double result) {
    if (result == 0) {
      return '0';
    }

    final formatted = result
        .toStringAsFixed(10)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return formatted.replaceAll('.', ',');
  }

  bool _isNumberCharacter(int codeUnit) {
    return (codeUnit >= 48 && codeUnit <= 57) || codeUnit == 46;
  }

  bool _isMathOperator(String value) {
    return value == '+' || value == '-' || value == '*' || value == '/';
  }

  int _precedence(String operator) {
    return operator == '*' || operator == '/' ? 2 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _backgroundColor,
        systemNavigationBarColor: _backgroundColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _studentLabel,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final buttonHeight = ((constraints.maxHeight - 16) / 5).clamp(
                64.0,
                80.0,
              );

              return Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                        child: Semantics(
                          liveRegion: true,
                          label: 'Kết quả $_display',
                          value: _display,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              _display,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Color(0xFFF2EEF5),
                                fontSize: 72,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildMinimalKeyboard(buttonHeight),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalKeyboard(double buttonHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          _buildRow(['0', 'C', ',', '⌫'], buttonHeight),
          _buildRow(['7', '8', '9', '÷'], buttonHeight),
          _buildRow(['4', '5', '6', '×'], buttonHeight),
          _buildRow(['1', '2', '3', '-'], buttonHeight),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildButton('=', buttonHeight, isSpecial: true),
              ),
              Expanded(child: _buildButton('+', buttonHeight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> texts, double buttonHeight) {
    return Row(
      children: texts
          .map((text) => Expanded(child: _buildButton(text, buttonHeight)))
          .toList(),
    );
  }

  Widget _buildButton(
    String text,
    double buttonHeight, {
    bool isSpecial = false,
  }) {
    final backgroundColor = switch (text) {
      '=' => _equalsButtonColor,
      '0' || ',' => _zeroButtonColor,
      '÷' || '×' || '-' || '+' || 'C' || '⌫' => _secondaryButtonColor,
      _ => _numberButtonColor,
    };
    final textColor = text == '=' ? Colors.black : Colors.white;

    return Semantics(
      button: true,
      label: text == '⌫'
          ? 'Xóa ký tự'
          : text == 'C'
          ? 'Xóa tất cả'
          : text == '='
          ? 'Tính kết quả'
          : null,
      child: SizedBox(
        height: buttonHeight,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ElevatedButton(
            onPressed: () => _onPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              overlayColor: textColor == Colors.black
                  ? Colors.black.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.12),
            ),
            child: text == '⌫'
                ? const ExcludeSemantics(
                    child: Icon(Icons.backspace_outlined, size: 24),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: isSpecial ? 28 : 22,
                      fontWeight: isSpecial
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
