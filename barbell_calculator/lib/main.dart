import 'package:flutter/material.dart';

void main() => runApp(const BarbellCalculatorApp());

class BarbellCalculatorApp extends StatelessWidget {
  const BarbellCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BarbellCalculatorHome(),
    );
  }
}

class BarbellCalculatorHome extends StatefulWidget {
  const BarbellCalculatorHome({super.key});

  @override
  State<BarbellCalculatorHome> createState() => _BarbellCalculatorHomeState();
}

class _BarbellCalculatorHomeState extends State<BarbellCalculatorHome> {
  double weight = 45;
  final TextEditingController _controller = TextEditingController(text: '45');

  void _adjustWeight(double amount) {
    setState(() {
      weight = (weight + amount).clamp(0, 1000);
      _controller.text = weight.toStringAsFixed(0);
    });
  }

  void _resetWeight() {
    setState(() {
      weight = 45;
      _controller.text = '45';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                onChanged: (value) {
                  final newValue = double.tryParse(value);
                  if (newValue != null) {
                    setState(() => weight = newValue);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: () => _adjustWeight(-90), child: const Text('-90')),
                  ElevatedButton(onPressed: () => _adjustWeight(-5), child: const Text('-5')),
                  ElevatedButton(onPressed: _resetWeight, child: const Text('Reset')),
                  ElevatedButton(onPressed: () => _adjustWeight(5), child: const Text('+5')),
                  ElevatedButton(onPressed: () => _adjustWeight(90), child: const Text('+90')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
