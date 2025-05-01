import 'package:flutter/material.dart';

void main() => runApp(BarbellCalculatorApp());

class BarbellCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbell Calculator',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: BarbellHomePage(),
    );
  }
}

class BarbellHomePage extends StatefulWidget {
  @override
  _BarbellHomePageState createState() => _BarbellHomePageState();
}

class _BarbellHomePageState extends State<BarbellHomePage> {
  double targetWeight = 45;
  double barWeight = 45;
  bool darkMode = true;
  final TextEditingController newPlateController = TextEditingController();
  List<Map<String, dynamic>> plates = [
    {'weight': 45.0, 'count': 4},
    {'weight': 35.0, 'count': 2},
    {'weight': 25.0, 'count': 2},
    {'weight': 10.0, 'count': 4},
    {'weight': 5.0, 'count': 4},
    {'weight': 2.5, 'count': 2},
  ];

  void adjustWeight(double delta) {
    setState(() => targetWeight = (targetWeight + delta).clamp(0, 1000));
  }

  void resetToBarWeight() {
    setState(() => targetWeight = barWeight);
  }

  void addPlate(double weight) {
    final existing = plates.firstWhere(
      (p) => p['weight'] == weight,
      orElse: () => {},
    );
    setState(() {
      if (existing.isNotEmpty) {
        existing['count']++;
      } else {
        plates.add({'weight': weight, 'count': 1});
      }
    });
  }

  void increasePlate(int index) {
    setState(() => plates[index]['count']++);
  }

  void decreasePlate(int index) {
    setState(() {
      if (plates[index]['count'] > 1) {
        plates[index]['count']--;
      } else {
        plates.removeAt(index);
      }
    });
  }

  void clearInventory() {
    setState(() => plates.clear());
  }

  List<double> calculatePlateConfiguration() {
    double remaining = targetWeight - barWeight;
    if (remaining < 0) return [];
    List<double> visualPlates = [];
    final sorted = [...plates]..sort((a, b) => b['weight'].compareTo(a['weight']));
    for (final plate in sorted) {
      int maxPairs = plate['count'] ~/ 2;
      int neededPairs = (remaining / (plate['weight'] * 2)).floor();
      int usePairs = neededPairs.clamp(0, maxPairs);
      for (int i = 0; i < usePairs; i++) {
        visualPlates.add(plate['weight']);
      }
      remaining -= usePairs * plate['weight'] * 2;
    }
    return visualPlates;
  }

  @override
  Widget build(BuildContext context) {
    final plateVisuals = calculatePlateConfiguration();
    return Scaffold(
      appBar: AppBar(
        title: Text('Barbell Calculator'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => buildSettingsSheet(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.inventory),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => buildInventorySheet(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildTargetWeightInput(),
            buildBarbellVisual(plateVisuals),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text('Made by Jasper Pell')),
      ),
    );
  }

  Widget buildTargetWeightInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Target Weight', style: Theme.of(context).textTheme.titleLarge),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter weight (lbs)'),
              onChanged: (val) => setState(() => targetWeight = double.tryParse(val) ?? 0),
              controller: TextEditingController(text: targetWeight.toString()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final val in [-90, -5, 0, 5, 90])
                  ElevatedButton(
                    onPressed: () =>
                        val == 0 ? resetToBarWeight() : adjustWeight(val.toDouble()),
                    child: Text(val == 0 ? 'Reset' : (val > 0 ? '+$val' : '$val')),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildBarbellVisual(List<double> plates) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Results', style: Theme.of(context).textTheme.titleLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...plates.reversed.map(buildPlate),
                Container(width: 100, height: 10, color: Colors.grey),
                ...plates.map(buildPlate),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildPlate(double weight) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      width: 20 + weight / 2,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        weight.toString(),
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildSettingsSheet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<double>(
            value: barWeight,
            onChanged: (val) => setState(() => barWeight = val ?? 45),
            items: [45.0, 35.0, 15.0].map((e) => DropdownMenuItem(value: e, child: Text('$e lbs'))).toList(),
          ),
          SwitchListTile(
            title: Text('Dark Mode'),
            value: darkMode,
            onChanged: (val) => setState(() => darkMode = val),
          )
        ],
      ),
    );
  }

  Widget buildInventorySheet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...plates.asMap().entries.map((entry) {
            final i = entry.key;
            final plate = entry.value;
            return ListTile(
              title: Text('${plate['weight']} lbs (x${plate['count']})'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => decreasePlate(i), icon: Icon(Icons.remove, color: Colors.red)),
                  IconButton(onPressed: () => increasePlate(i), icon: Icon(Icons.add, color: Colors.green)),
                ],
              ),
            );
          }),
          TextField(
            controller: newPlateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Add plate (lbs)'),
            onSubmitted: (val) => addPlate(double.tryParse(val) ?? 0),
          ),
          ElevatedButton(
            onPressed: clearInventory,
            child: Text('Clear Inventory'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          )
        ],
      ),
    );
  }
}
