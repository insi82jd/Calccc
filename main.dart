import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
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
  String _expression = '';
  String _result = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _calculateResult();
      } else if (value == '±') {
        if (_expression.isNotEmpty) {
          if (_expression.startsWith('-')) {
            _expression = _expression.substring(1);
          } else {
            _expression = '-$_expression';
          }
        }
      } else {
        if (_isOperator(value) && _expression.isNotEmpty) {
          String lastChar = _expression[_expression.length - 1];
          if (_isOperator(lastChar)) {
            _expression =
                _expression.substring(0, _expression.length - 1) + value;
            return;
          }
        }
        _expression += value;
      }
    });
  }

  bool _isOperator(String char) {
    return char == '+' || char == '-' || char == '×' || char == '÷' || char == '%';
  }

  void _calculateResult() {
    if (_expression.isEmpty) return;
    try {
      String finalExp = _expression;
      if (_isOperator(finalExp[finalExp.length - 1])) {
        finalExp = finalExp.substring(0, finalExp.length - 1);
      }

      double eval = _evaluateExpression(finalExp);
      if (eval.isInfinite || eval.isNaN) {
        _result = 'خطأ';
      } else {
        _result = eval.toStringAsFixed(6);
        _result = _result.replaceAll(RegExp(r'0*$'), '');
        _result = _result.replaceAll(RegExp(r'\.$'), '');
      }
    } catch (e) {
      _result = 'خطأ';
    }
  }

  double _evaluateExpression(String exp) {
    exp = exp.replaceAll('%', '÷100');

    List<String> tokens = [];
    String currentNumber = '';

    for (int i = 0; i < exp.length; i++) {
      String char = exp[i];
      if ((char == '-' && (i == 0 || _isOperator(exp[i - 1]))) ||
          RegExp(r'[0-9.]').hasMatch(char)) {
        currentNumber += char;
      } else if (_isOperator(char)) {
        if (currentNumber.isNotEmpty) {
          tokens.add(currentNumber);
          currentNumber = '';
        }
        tokens.add(char);
      }
    }
    if (currentNumber.isNotEmpty) {
      tokens.add(currentNumber);
    }

    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '×' || tokens[i] == '÷') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double res = tokens[i] == '×' ? left * right : left / right;
        tokens[i - 1] = res.toString();
        tokens.removeAt(i);
        tokens.removeAt(i);
        i--;
      }
    }

    double total = tokens.isNotEmpty ? double.parse(tokens[0]) : 0.0;
    for (int i = 1; i < tokens.length; i += 2) {
      String op = tokens[i];
      double nextVal = double.parse(tokens[i + 1]);
      if (op == '+') total += nextVal;
      if (op == '-') total -= nextVal;
    }

    return total;
  }

  Widget _buildButton(String text, {Color? bgColor, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor ?? const Color(0xFF1E1E1E),
            foregroundColor: textColor ?? Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color operatorColor = Color(0xFF2B2B2B);
    const Color accentColor = Color(0xFFFF9800);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildButton('C', bgColor: const Color(0xFF3A1D1D), textColor: Colors.redAccent),
                      _buildButton('⌫', bgColor: operatorColor, textColor: accentColor),
                      _buildButton('%', bgColor: operatorColor, textColor: accentColor),
                      _buildButton('÷', bgColor: operatorColor, textColor: accentColor),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('7'),
                      _buildButton('8'),
                      _buildButton('9'),
                      _buildButton('×', bgColor: operatorColor, textColor: accentColor),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('4'),
                      _buildButton('5'),
                      _buildButton('6'),
                      _buildButton('-', bgColor: operatorColor, textColor: accentColor),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('1'),
                      _buildButton('2'),
                      _buildButton('3'),
                      _buildButton('+', bgColor: operatorColor, textColor: accentColor),
                    ],
                  ),
                  Row(
                    children: [
                      _buildButton('±'),
                      _buildButton('0'),
                      _buildButton('.'),
                      _buildButton('=', bgColor: accentColor, textColor: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
