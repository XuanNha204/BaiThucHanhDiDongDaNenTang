import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color _backgroundColor = Color(0xFF171717);
const Color _numberButtonColor = Color(0xFF3B3B3B);
const Color _secondaryButtonColor = Color(0xFF323232);
const Color _equalsButtonColor = Color(0xFF76C7FF);

void main() {
  runApp(const MyApp());
}

class HistoryItem {
  final String expression;
  final String result;
  final DateTime timestamp;

  HistoryItem({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Máy tính nâng cao',
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
  String _secondaryDisplay = '';
  bool _isEquationFinished = false;
  double? _memory;
  final List<HistoryItem> _history = [];

  void _onPressed(String text) {
    if (text == '=') {
      _calculate();
      return;
    }
    if (text == 'x²') {
      _calculateSquare();
      return;
    }
    if (text == '√x') {
      _calculateSquareRoot();
      return;
    }
    if (text == '¹/x') {
      _calculateReciprocal();
      return;
    }
    if (text == '%') {
      _calculatePercentage();
      return;
    }
    if (text == '+/-') {
      _toggleSign();
      return;
    }
    if (text == 'CE') {
      _clearEntry();
      return;
    }

    setState(() {
      if (_display == 'Lỗi') {
        _display = '0';
        _secondaryDisplay = '';
        _isEquationFinished = false;
      }

      if (text == 'C') {
        _display = '0';
        _secondaryDisplay = '';
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
          _secondaryDisplay = '';
        } else {
          _display = text == ',' ? '0,' : text;
          _secondaryDisplay = '';
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
    if (_isEquationFinished || _display == 'Lỗi') {
      _display = '0';
      _isEquationFinished = false;
      return;
    }
    if (_display.length <= 1) {
      _display = '0';
      return;
    }

    _display = _display.substring(0, _display.length - 1);
    if (_display.isEmpty || _display == '-') {
      _display = '0';
    }
  }

  void _addDecimalSeparator() {
    if (_isEquationFinished || _display == 'Lỗi') {
      _display = '0,';
      _isEquationFinished = false;
      return;
    }

    final parts = _display.split(RegExp(r'[+\-×÷]'));
    final currentNumber = parts.isNotEmpty ? parts.last : '';
    if (currentNumber.contains(',')) {
      return;
    }

    if (_display.isEmpty || _operators.contains(_display.substring(_display.length - 1))) {
      _display += '0,';
    } else {
      _display += ',';
    }
  }

  void _addOperator(String operator) {
    if (_display == 'Lỗi') {
      _display = '0$operator';
      _isEquationFinished = false;
      return;
    }

    if (_isEquationFinished) {
      _isEquationFinished = false;
      _secondaryDisplay = '';
    }

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
      if (_display == 'Lỗi') return;

      try {
        var expr = _display;
        while (expr.isNotEmpty && _operators.contains(expr[expr.length - 1])) {
          expr = expr.substring(0, expr.length - 1);
        }
        if (expr.isEmpty) {
          _display = '0';
          return;
        }

        final result = _evaluate(expr);
        final formatted = _formatResult(result);
        _history.insert(
          0,
          HistoryItem(
            expression: _display,
            result: formatted,
            timestamp: DateTime.now(),
          ),
        );
        _secondaryDisplay = '$_display =';
        _display = formatted;
        _isEquationFinished = true;
      } on Exception {
        _display = 'Lỗi';
        _isEquationFinished = true;
      }
    });
  }

  void _calculateSquare() {
    setState(() {
      if (_display == 'Lỗi') {
        _display = '0';
        return;
      }

      final currentVal = _getCurrentNumber();
      final result = currentVal * currentVal;
      final formatted = _formatResult(result);

      if (_isEquationFinished || !_hasOperator(_display)) {
        final original = _display;
        _display = formatted;
        _secondaryDisplay = 'sqr($original)';
        _isEquationFinished = true;
        _history.insert(
          0,
          HistoryItem(
            expression: 'sqr($original)',
            result: formatted,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _replaceLastNumber(formatted);
      }
    });
  }

  void _calculateSquareRoot() {
    setState(() {
      if (_display == 'Lỗi') {
        _display = '0';
        return;
      }

      final currentVal = _getCurrentNumber();
      if (currentVal < 0) {
        _display = 'Lỗi';
        _isEquationFinished = true;
        return;
      }

      final result = math.sqrt(currentVal);
      final formatted = _formatResult(result);

      if (_isEquationFinished || !_hasOperator(_display)) {
        final original = _display;
        _display = formatted;
        _secondaryDisplay = '√($original)';
        _isEquationFinished = true;
        _history.insert(
          0,
          HistoryItem(
            expression: '√($original)',
            result: formatted,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _replaceLastNumber(formatted);
      }
    });
  }

  void _calculateReciprocal() {
    setState(() {
      if (_display == 'Lỗi') {
        _display = '0';
        return;
      }

      final currentVal = _getCurrentNumber();
      if (currentVal == 0) {
        _display = 'Lỗi';
        _isEquationFinished = true;
        return;
      }

      final result = 1 / currentVal;
      final formatted = _formatResult(result);

      if (_isEquationFinished || !_hasOperator(_display)) {
        final original = _display;
        _display = formatted;
        _secondaryDisplay = '1/($original)';
        _isEquationFinished = true;
        _history.insert(
          0,
          HistoryItem(
            expression: '1/($original)',
            result: formatted,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _replaceLastNumber(formatted);
      }
    });
  }

  void _calculatePercentage() {
    setState(() {
      if (_display == 'Lỗi') {
        _display = '0';
        return;
      }

      final currentVal = _getCurrentNumber();
      final result = currentVal / 100;
      final formatted = _formatResult(result);

      if (_isEquationFinished || !_hasOperator(_display)) {
        final original = _display;
        _display = formatted;
        _secondaryDisplay = '$original%';
        _isEquationFinished = true;
        _history.insert(
          0,
          HistoryItem(
            expression: '$original%',
            result: formatted,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        _replaceLastNumber(formatted);
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0' || _display == 'Lỗi') return;

      if (_isEquationFinished || !_hasOperator(_display)) {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
        return;
      }

      final lastNumMatch = RegExp(r'(-?\d+(?:,\d+)?)$').firstMatch(_display);
      if (lastNumMatch != null) {
        final lastNum = lastNumMatch.group(1)!;
        final start = lastNumMatch.start;
        final toggled = lastNum.startsWith('-') ? lastNum.substring(1) : '-$lastNum';
        _display = _display.substring(0, start) + toggled;
      }
    });
  }

  void _clearEntry() {
    setState(() {
      if (_isEquationFinished || _display == 'Lỗi') {
        _display = '0';
        _secondaryDisplay = '';
        _isEquationFinished = false;
        return;
      }

      final lastNumMatch = RegExp(r'(-?\d+(?:,\d+)?)$').firstMatch(_display);
      if (lastNumMatch != null) {
        final start = lastNumMatch.start;
        if (start == 0) {
          _display = '0';
        } else {
          _display = '${_display.substring(0, start)}0';
        }
      } else {
        _display = '0';
      }
    });
  }

  double _getCurrentNumber() {
    if (_display == 'Lỗi') return 0.0;
    final match = RegExp(r'(-?\d+(?:,\d+)?)$').firstMatch(_display);
    if (match != null) {
      final str = match.group(1)!.replaceAll(',', '.');
      return double.tryParse(str) ?? 0.0;
    }
    return double.tryParse(_display.replaceAll(',', '.')) ?? 0.0;
  }

  void _replaceLastNumber(String replacement) {
    final lastNumMatch = RegExp(r'(-?\d+(?:,\d+)?)$').firstMatch(_display);
    if (lastNumMatch != null) {
      _display = _display.substring(0, lastNumMatch.start) + replacement;
    } else {
      _display = replacement;
    }
  }

  bool _hasOperator(String str) {
    for (final op in _operators) {
      if (str.contains(op)) return true;
    }
    return false;
  }

  void _onMemoryPressed(String label) {
    final currentVal = _getCurrentNumber();
    setState(() {
      switch (label) {
        case 'MS':
          _memory = currentVal;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã lưu vào bộ nhớ: ${_formatResult(_memory!)}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        case 'M+':
          _memory = (_memory ?? 0) + currentVal;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bộ nhớ (M+): ${_formatResult(_memory!)}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        case 'M-':
          _memory = (_memory ?? 0) - currentVal;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bộ nhớ (M-): ${_formatResult(_memory!)}'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Lịch sử tính toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_history.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _history.clear();
                              });
                              setModalState(() {});
                            },
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            label: const Text(
                              'Xóa lịch sử',
                              style: TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    if (_history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: Text(
                            'Chưa có lịch sử tính toán',
                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _history.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              title: Text(
                                '${item.expression} =',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                                textAlign: TextAlign.right,
                              ),
                              subtitle: Text(
                                item.result,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              onTap: () {
                                setState(() {
                                  _display = item.result;
                                  _secondaryDisplay = '${item.expression} =';
                                  _isEquationFinished = true;
                                });
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _evaluate(String expression) {
    final normalized = expression
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .replaceAll('×', '*')
        .replaceAll('÷', '/');
    final numbers = <double>[];
    final operators = <String>[];
    var index = 0;

    while (index < normalized.length) {
      final char = normalized[index];
      final isUnaryMinus = (char == '-') &&
          (index == 0 || _isOperatorChar(normalized[index - 1]));

      if (_isDigitOrDot(char) || isUnaryMinus) {
        final start = index;
        index++;
        while (index < normalized.length && _isDigitOrDot(normalized[index])) {
          index++;
        }
        final numStr = normalized.substring(start, index);
        final val = double.tryParse(numStr);
        if (val == null) {
          throw const FormatException('Biểu thức không hợp lệ');
        }
        numbers.add(val);
      } else if (_isOperatorChar(char)) {
        final op = char;
        while (operators.isNotEmpty &&
            _precedence(operators.last) >= _precedence(op)) {
          _reduce(numbers, operators);
        }
        operators.add(op);
        index++;
      } else {
        throw const FormatException('Biểu thức không hợp lệ');
      }
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

    if (result == result.roundToDouble() && !result.isInfinite && result.abs() < 1e12) {
      return result.toInt().toString();
    }

    final formatted = result
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return formatted.replaceAll('.', ',');
  }

  bool _isDigitOrDot(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 48 && code <= 57) || code == 46;
  }

  bool _isOperatorChar(String char) {
    return char == '+' || char == '-' || char == '*' || char == '/';
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
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.grey),
              tooltip: 'Lịch sử tính toán',
              onPressed: _showHistorySheet,
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableForButtons = constraints.maxHeight * 0.65;
              final buttonHeight = ((availableForButtons - 36) / 6).clamp(
                46.0,
                64.0,
              );

              return Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_secondaryDisplay.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  _secondaryDisplay,
                                  key: const Key('secondary_display'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            Semantics(
                              liveRegion: true,
                              label: 'Kết quả $_display',
                              value: _display,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _display,
                                  key: const Key('display_text'),
                                  maxLines: 1,
                                  style: const TextStyle(
                                    color: Color(0xFFF2EEF5),
                                    fontSize: 68,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildMemoryRow(),
                  const SizedBox(height: 6),
                  _buildKeyboard(buttonHeight),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMemoryButton('M+'),
          _buildMemoryButton('M-'),
          _buildMemoryButton('MS'),
        ],
      ),
    );
  }

  Widget _buildMemoryButton(String label) {
    return TextButton(
      onPressed: () => _onMemoryPressed(label),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildKeyboard(double buttonHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildRow(['%', 'CE', 'C', '⌫'], buttonHeight),
          _buildRow(['¹/x', 'x²', '√x', '÷'], buttonHeight),
          _buildRow(['7', '8', '9', '×'], buttonHeight),
          _buildRow(['4', '5', '6', '-'], buttonHeight),
          _buildRow(['1', '2', '3', '+'], buttonHeight),
          _buildRow(['+/-', '0', ',', '='], buttonHeight),
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

  Widget _buildButton(String text, double buttonHeight) {
    final isEquals = text == '=';
    final isDigit = RegExp(r'^[0-9]$').hasMatch(text);
    final backgroundColor = isEquals
        ? _equalsButtonColor
        : isDigit
            ? _numberButtonColor
            : _secondaryButtonColor;
    final textColor = isEquals ? Colors.black : Colors.white;

    return Semantics(
      button: true,
      label: text == '⌫'
          ? 'Xóa ký tự'
          : text == 'C'
              ? 'Xóa tất cả'
              : text == 'CE'
                  ? 'Xóa giá trị hiện tại'
                  : text == '='
                      ? 'Tính kết quả'
                      : text,
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
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              shadowColor: Colors.transparent,
              overlayColor: isEquals
                  ? Colors.black.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.12),
            ),
            child: text == '⌫'
                ? const ExcludeSemantics(
                    child: Icon(Icons.backspace_outlined, size: 22),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: isEquals ? 26 : 20,
                      fontWeight: isEquals
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
