import 'package:flutter/material.dart';

void main() {
  runApp(WeightCalcApp());
}

class WeightCalcApp extends StatelessWidget {
  const WeightCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbell Calculator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: WeightCalcHome(),
    );
  }
}

class WeightCalcHome extends StatefulWidget {
  const WeightCalcHome({super.key});

  @override
  _WeightCalcHomeState createState() => _WeightCalcHomeState();
}

class _WeightCalcHomeState extends State<WeightCalcHome> {
  final List<Map<String, dynamic>> availablePlates = [
    {'weight': 45, 'count': 4},
    {'weight': 35, 'count': 2},
    {'weight': 25, 'count': 2},
    {'weight': 10, 'count': 4},
    {'weight': 5, 'count': 4},
    {'weight': 2.5, 'count': 2},
  ];

  double targetWeight = 45;
  double barbellWeight = 45;
  bool isDarkMode = false;

  void calculatePlates() {
    // Logic to calculate plates based on targetWeight and barbellWeight
    // ...existing code...
  }

  void adjustWeight(double amount) {
    setState(() {
      targetWeight = (targetWeight + amount).clamp(0, double.infinity);
      calculatePlates();
    });
  }

  void resetToBarWeight() {
    setState(() {
      targetWeight = barbellWeight;
      calculatePlates();
    });
  }

  void toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barbell Calculator'),
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: toggleDarkMode,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<double>(
              value: barbellWeight,
              items: [
                DropdownMenuItem(value: 45, child: Text('Standard Bar (45 lbs)')),
                DropdownMenuItem(value: 35, child: Text('Women\'s Bar (35 lbs)')),
                DropdownMenuItem(value: 15, child: Text('Training Bar (15 lbs)')),
              ],
              onChanged: (value) {
                setState(() {
                  barbellWeight = value!;
                  calculatePlates();
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Weight (lbs)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  targetWeight = double.tryParse(value) ?? 0;
                  calculatePlates();
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () => adjustWeight(-90), child: Text('-90')),
                ElevatedButton(onPressed: () => adjustWeight(-5), child: Text('-5')),
                ElevatedButton(onPressed: resetToBarWeight, child: Text('Reset')),
                ElevatedButton(onPressed: () => adjustWeight(5), child: Text('+5')),
                ElevatedButton(onPressed: () => adjustWeight(90), child: Text('+90')),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  'Results will be displayed here',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}