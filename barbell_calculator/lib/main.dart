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
  final double barWeight = 45;
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

  List<double> getPlatesNeeded() {
    double remainder = weight - barWeight;
    List<double> availablePlates = [45, 35, 25, 10, 5, 2.5];
    List<double> usedPlates = [];
    for (double plate in availablePlates) {
      while (remainder >= plate * 2) {
        usedPlates.add(plate);
        remainder -= plate * 2;
      }
    }
    return usedPlates;
  }

  Widget buildBarbellDiagram() {
    List<double> plates = getPlatesNeeded();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ...plates.reversed.map((w) => buildPlate(w)),
        Expanded(
          child: Container(height: 30, color: Colors.grey),
        ),
        ...plates.map((w) => buildPlate(w)),
      ],
    );
  }

  Widget buildPlate(double weight) {
    String display = weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
    double plateHeight = 50 + (weight / 45) * 100; // Base height of 50, scales with weight
    double plateWidth = 20 + weight / 2; // Scales width with weight
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: plateWidth,
      height: plateHeight,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(display,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Barbell Setup', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: buildBarbellDiagram(),
                ),
              ),
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
