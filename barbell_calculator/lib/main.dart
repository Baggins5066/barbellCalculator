import 'package:flutter/material.dart';

void main() => runApp(const BarbellCalculatorApp());

class BarbellCalculatorApp extends StatelessWidget {
  const BarbellCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, // Dark theme
        primaryColor: Colors.grey[900], // Dark grey as main color
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF212121), // Dark grey
          secondary: Colors.blue, // Accent color
        ),
        scaffoldBackgroundColor: Colors.grey[900], // Dark grey background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF212121), // Dark grey AppBar background
          foregroundColor: Colors.blue, // AppBar text/icon color
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Button background
            foregroundColor: Colors.white, // Button text color
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Default text color
          bodyMedium: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF212121), // Dark grey fill color
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.blue), // Label color
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.blue), // Switch thumb color
          trackColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.5)), // Switch track color
        ),
      ),
      home: const BarbellCalculatorHome(),
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
  bool isDarkMode = true; // Dark mode enabled by default

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
      if (isDarkMode) {
        // Apply dark mode colors
        Theme.of(context).copyWith(
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF212121),
            foregroundColor: Colors.blue,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Color(0xFF212121),
          ),
        );
      } else {
        // Apply light mode colors
        Theme.of(context).copyWith(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Colors.white,
          ),
        );
      }
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 30, // Fixed width for the bar
              height: 30, // Square shape for the bar
              color: Colors.grey, // Barbell shaft
            ),
            Text(
              '${barWeight.toStringAsFixed(0)}', // Display the bar's weight
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
        ...plates.map((w) => buildPlate(w)), // Show right side weights
        Container(
          width: 10, // Short bar sticking out beyond the weights
          height: 30,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget buildPlate(double weight) {
    String display = weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
    double plateHeight = 70 + (weight / 45) * 140; // Larger height for plates
    double plateWidth = 30 + weight / 2; // Larger width for plates
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: plateWidth,
      height: plateHeight,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        display,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Path to your logo image
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(width: 10),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
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
                                onChanged: (value) {
                                  setState(() => isDarkMode = value);
                                  _toggleDarkMode(value);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Close',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added padding
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.backpack),
            onPressed: () {
              Map<int, int> plateInventory = {
                45: 4,
                35: 2,
                25: 2,
                10: 4,
                5: 4,
                2: 2, // Representing 2.5 lb plates as 2 for integer storage
              };

              final Map<int, int> defaultInventory = Map.from(plateInventory); // Save default state

              showDialog(
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) {
                    final TextEditingController customWeightController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Plate Inventory'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ...plateInventory.entries.where((entry) => entry.value > 0).map((entry) {
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
                                            if (plateInventory[entry.key] == 0) {
                                              plateInventory.remove(entry.key); // Remove plate when count reaches 0
                                            }
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
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: customWeightController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Add another',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  final customWeight = double.tryParse(customWeightController.text);
                                  if (customWeight != null && customWeight > 0) {
                                    setState(() {
                                      plateInventory[customWeight.toInt()] = (plateInventory[customWeight.toInt()] ?? 0) + 1;
                                    });
                                    customWeightController.clear();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invalid weight. Please enter a positive number.')),
                                    );
                                  }
                                },
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(50, 50), // Ideal size for mobile
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Rounded corners
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Reset'),
                                      content: const Text('Are you sure you want to reset the inventory to its default state?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(), // Close dialog
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added padding
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              plateInventory = Map.from(defaultInventory); // Reset to default state
                                            });
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          child: const Text(
                                            'Confirm',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added padding
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(fontSize: 20, color: Colors.white), // White text
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(90, 50), // Slightly larger for emphasis
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Rounded corners
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    plateInventory.updateAll((key, value) => 0); // Clear all plates
                                  });
                                },
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(fontSize: 20, color: Colors.white), // White text
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(90, 50), // Ideal size for mobile
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Rounded corners
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Close',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added padding
                          ),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Barbell Setup',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: buildBarbellDiagram(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter Weight',
                  labelStyle: const TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _validateAndSetWeight,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _adjustWeight(-90),
                    child: const Text(
                      '-90',
                      style: TextStyle(fontSize: 20), // Larger font size for better readability
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50), // Ideal size for mobile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _adjustWeight(-5),
                    child: const Text(
                      '-5',
                      style: TextStyle(fontSize: 20), // Larger font size for better readability
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50), // Ideal size for mobile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _resetWeight,
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 20), // Larger font size for better readability
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(90, 50), // Slightly larger for emphasis
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _adjustWeight(5),
                    child: const Text(
                      '+5',
                      style: TextStyle(fontSize: 20), // Larger font size for better readability
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50), // Ideal size for mobile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _adjustWeight(90),
                    child: const Text(
                      '+90',
                      style: TextStyle(fontSize: 20), // Larger font size for better readability
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50), // Ideal size for mobile
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white, // Toggle background color
    );
  }
}
