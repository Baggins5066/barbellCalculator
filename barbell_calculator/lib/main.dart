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
  bool isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

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

  void _validateAndSetWeight(String value) {
    final newValue = double.tryParse(value);
    if (newValue != null && newValue >= barWeight) {
      setState(() => weight = newValue);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid weight. Please enter a valid number greater than or equal to the bar weight.')),
      );
      _controller.text = weight.toStringAsFixed(0);
    }
  }

  List<double> getPlatesNeeded() {
    double remainder = weight - barWeight;
    Map<double, int> plateInventory = {
      45: 4,
      35: 2,
      25: 2,
      10: 4,
      5: 4,
      2.5: 2,
    };
    List<double> usedPlates = [];
    for (double plate in plateInventory.keys) {
      while (remainder >= plate * 2 && plateInventory[plate]! > 0) {
        usedPlates.add(plate);
        remainder -= plate * 2;
        plateInventory[plate] = plateInventory[plate]! - 1;
      }
    }
    if (remainder > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target weight cannot be achieved with available plates.')),
      );
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
          child: Container(height: 15, color: Colors.grey), // Reduced height from 30 to 15
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
      appBar: AppBar(
        title: null, // Removed the "Barbell Calculator" text
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Dark Mode'),
                          Switch(
                            value: isDarkMode,
                            onChanged: _toggleDarkMode,
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backpack),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    final Map<int, int> plateInventory = {
                      45: 4,
                      35: 2,
                      25: 2,
                      10: 4,
                      5: 4,
                      2: 2, // Representing 2.5 lb plates as 2 for integer storage
                    };

                    return AlertDialog(
                      title: const Text('Plate Inventory'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: plateInventory.entries.map((entry) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${entry.key == 2 ? 2.5 : entry.key} lb plates:', // Convert 2 back to 2.5 for display
                                style: const TextStyle(fontSize: 18),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (plateInventory[entry.key]! > 0) {
                                          plateInventory[entry.key] = plateInventory[entry.key]! - 1;
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '${plateInventory[entry.key]}',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        plateInventory[entry.key] = plateInventory[entry.key]! + 1;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
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
                onChanged: _validateAndSetWeight,
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
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }
}
