import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for setting device orientation

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Lock to portrait mode
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const BarbellCalculatorApp());
  });
}

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
          thumbColor: WidgetStateProperty.all(Colors.blue), // Switch thumb color
          trackColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.5)), // Switch track color
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

class _BarbellCalculatorHomeState extends State<BarbellCalculatorHome> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  double weight = 45;
  double barWeight = 45;
  final TextEditingController _controller = TextEditingController(text: '45');
  bool isDarkMode = true; // Dark mode enabled by default
  bool isWeightToPlates = true; // Default mode is Weight to Plates

  Map<double, int> plateInventory = {
    45: 4,
    35: 2,
    25: 2,
    10: 4,
    5: 4,
    2.5: 2,
  };

  bool _isWeightAchievable = true; // Flag to track if the target weight is achievable
  String _errorMessage = ''; // Error message to display when weight is not achievable

  late AnimationController _numberAnimationController;
  late Animation<double> _numberAnimation;

  @override
  void initState() {
    super.initState();
    _numberAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _numberAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _numberAnimationController,
      curve: Curves.easeInOut,
    ));
    _numberAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _numberAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _numberAnimationController.dispose();
    super.dispose();
  }

  void _applyInventoryChanges(Map<double, int> updatedInventory) {
    setState(() {
      plateInventory = Map.from(updatedInventory);
    });
  }

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

  void _toggleMode() {
    setState(() {
      isWeightToPlates = !isWeightToPlates;
    });
  }

  void _adjustWeight(double amount) {
    setState(() {
      weight = (weight + amount).clamp(barWeight, 405); // Ensure weight does not exceed 405
      _controller.text = weight.toStringAsFixed(0);
    });
  }

  void _resetWeight() {
    setState(() {
      weight = barWeight; // Reset target weight to barbell weight
      _controller.text = barWeight.toStringAsFixed(0);
    });
  }

  void _showErrorMessage(String message) {
    _scaffoldMessengerKey.currentState?.clearSnackBars(); // Clear existing SnackBars
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateAndSetWeight(String value) {
    final newValue = double.tryParse(value);
    if (newValue == null || newValue < barWeight || newValue > 405) {
      _showErrorMessage('Invalid weight. Please enter a number between $barWeight and 405.');
      _controller.text = weight.toStringAsFixed(0);
      return;
    }
    setState(() => weight = newValue);
  }

  void _animateNumberChange() {
    _numberAnimationController.forward();
  }

  List<double> getPlatesNeeded() {
    double remainder = weight - barWeight;
    Map<double, int> tempInventory = Map.from(plateInventory);
    List<double> usedPlates = [];

    for (double plate in tempInventory.keys.toList()..sort((a, b) => b.compareTo(a))) {
      while (remainder >= plate * 2 && tempInventory[plate]! > 0) {
        usedPlates.add(plate);
        remainder -= plate * 2;
        tempInventory[plate] = tempInventory[plate]! - 1;
      }
    }

    if (remainder > 0) {
      setState(() {
        _isWeightAchievable = false;
        _errorMessage = 'Target weight cannot be achieved with available plates.';
      });
      return [];
    }

    setState(() {
      _isWeightAchievable = true;
      _errorMessage = '';
    });

    return usedPlates;
  }

  double calculateWeightFromPlates(List<double> selectedPlates) {
    double totalWeight = barWeight;
    for (double plate in selectedPlates) {
      totalWeight += plate * 2; // Each plate is added to both sides of the barbell
    }
    return totalWeight;
  }

  Widget buildPlatesSelection() {
    Map<double, int> tempInventory = Map.from(plateInventory);
    List<double> selectedPlates = [];

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _numberAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _numberAnimation.value,
                  child: Text(
                    calculateWeightFromPlates(selectedPlates).toInt().toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...selectedPlates.reversed.map((w) => AnimatedPlate(weight: w)), // Left side plates with animation
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 20, // Smaller width for the bar
                          height: 20, // Smaller square shape for the bar
                          color: Colors.grey, // Barbell shaft
                        ),
                        Text(
                          barWeight.toStringAsFixed(0), // Display the bar's weight
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), // Larger font size
                        ),
                      ],
                    ),
                    ...selectedPlates.map((w) => AnimatedPlate(weight: w)), // Right side plates with animation
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedPlates.clear(); // Clear all selected plates
                  _animateNumberChange();
                });
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 4, // Display 4 buttons per row
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true, // Ensure the grid only takes up necessary space
              physics: const NeverScrollableScrollPhysics(), // Disable scrolling for the grid
              children: tempInventory.entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (tempInventory[entry.key]! > 0) {
                        selectedPlates.add(entry.key);
                        selectedPlates.sort((a, b) => b.compareTo(a)); // Sort plates by size
                        _animateNumberChange();
                      }
                    });
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key} lb',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget buildSmallPlate(double weight) {
    String display = weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1); // Ensure "2.5" is displayed clearly
    double plateHeight = 35 + (weight / 45) * 70; // Smaller height for plates
    double plateWidth = 15 + weight / 4; // Smaller width for plates
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      width: plateWidth,
      height: plateHeight,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: Text(
        display,
        style: TextStyle(
          color: Colors.white,
          fontSize: weight == 2.5 ? 14 : 12, // Larger font size for "2.5"
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildBarbellDiagram() {
    List<double> plates = getPlatesNeeded();

    return AnimatedBuilder(
      animation: _numberAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _numberAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40, // Moderately increased width for the bar
                    height: 40, // Moderately larger square shape for the bar
                    color: Colors.grey, // Barbell shaft
                  ),
                  Text(
                    barWeight.toStringAsFixed(0), // Display the bar's weight
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black), // Slightly larger font size
                  ),
                ],
              ),
              ...plates.map((w) => buildPlate(w)), // Show right side weights
              Container(
                width: 15, // Slightly longer bar sticking out beyond the weights
                height: 40,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPlate(double weight) {
    String display = weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
    double plateHeight = 80 + (weight / 45) * 160; // Moderately larger height for plates
    double plateWidth = 30 + weight / 2.5; // Moderately larger width for plates
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: plateWidth,
      height: plateHeight,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        display,
        style: TextStyle(
          color: Colors.white,
          fontSize: weight == 2.5 ? 10 : 20, // Smaller text for 2.5lb plates
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton({required String label, required VoidCallback onPressed, double fontSize = 16, double minWidth = 60, double minHeight = 40}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth, minHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey, // Attach the key to the Scaffold
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.settings, size: 30), // Increased icon size
          tooltip: 'Open Settings',
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
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added padding
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
          iconSize: 40, // Increased button size
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center, size: 30), // Icon for barbell weight
            tooltip: 'Set Barbell Weight',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController barWeightController = TextEditingController(text: barWeight.toInt().toString());
                  return AlertDialog(
                    title: const Text('Set Barbell Weight'),
                    content: TextField(
                      controller: barWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Barbell Weight',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final newBarWeight = int.tryParse(barWeightController.text);
                          if (newBarWeight != null && newBarWeight > 0) {
                            setState(() {
                              barWeight = newBarWeight.toDouble();
                              weight = barWeight; // Reset target weight to new bar weight
                              _controller.text = barWeight.toStringAsFixed(0);
                            });
                            Navigator.of(context).pop();
                          } else {
                            _showErrorMessage('Invalid weight. Please enter a positive integer.');
                          }
                        },
                        child: const Text(
                          'Set',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            iconSize: 40, // Increased button size
          ),
          IconButton(
            icon: const Icon(Icons.backpack, size: 30), // Increased icon size
            tooltip: 'Manage Plate Inventory',
            onPressed: () {
              Map<double, int> tempInventory = Map.from(plateInventory); // Temporary inventory for dialog
              final Map<double, int> defaultInventory = {
                45: 4,
                35: 2,
                25: 2,
                10: 4,
                5: 4,
                2.5: 2,
              }; // Default inventory

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
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...tempInventory.entries.where((entry) => entry.value > 0).map((entry) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key % 1 == 0 ? entry.key.toInt().toString() : entry.key.toStringAsFixed(1), // Display as integer if whole number
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  if (tempInventory[entry.key]! > 0) {
                                                    tempInventory[entry.key] = tempInventory[entry.key]! - 1;
                                                    if (tempInventory[entry.key] == 0) {
                                                      tempInventory.remove(entry.key); // Remove plate when count reaches 0
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                            Text(
                                              '${tempInventory[entry.key]}',
                                              style: const TextStyle(fontSize: 18),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  tempInventory[entry.key] = tempInventory[entry.key]! + 1;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
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
                                      tempInventory[customWeight] = (tempInventory[customWeight] ?? 0) + 1;
                                    });
                                    customWeightController.clear();
                                  } else {
                                    _showErrorMessage('Invalid weight. Please enter a positive number.');
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
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              tempInventory = Map.from(defaultInventory); // Reset to default inventory
                                            });
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          child: const Text(
                                            'Confirm',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Clear All'),
                                      content: const Text('Are you sure you want to remove all plates from the inventory?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(), // Close dialog
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              tempInventory.clear(); // Remove all plates
                                            });
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          child: const Text(
                                            'Confirm',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(120, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Clear All',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            _applyInventoryChanges(tempInventory); // Apply changes to the main inventory
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Added padding
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // White text
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
            iconSize: 40, // Increased button size
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleMode,
                    icon: const Icon(Icons.swap_horiz, size: 30), // Icon for mode toggle
                    label: Text(
                      isWeightToPlates ? 'Weight → Plates' : 'Plates → Weight', // Dynamic title
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // More rounded edges
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isWeightToPlates) ...[
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
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _isWeightAchievable ? Colors.white : Colors.red, // Red text if weight is not achievable
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter Weight',
                    labelStyle: const TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: _validateAndSetWeight,
                ),
                if (!_isWeightAchievable) // Show error message if weight is not achievable
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ] else ...[
                Expanded(
                  child: buildPlatesSelection(),
                ),
              ],
              const SizedBox(height: 20),
              if (isWeightToPlates)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildElevatedButton(label: '-90', onPressed: () => _adjustWeight(-90)),
                    buildElevatedButton(label: '-5', onPressed: () => _adjustWeight(-5)),
                    buildElevatedButton(label: 'Reset', onPressed: _resetWeight, minWidth: 70),
                    buildElevatedButton(label: '+5', onPressed: () => _adjustWeight(5)),
                    buildElevatedButton(label: '+90', onPressed: () => _adjustWeight(90)),
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

class AnimatedPlate extends StatelessWidget {
  final double weight;

  const AnimatedPlate({super.key, required this.weight});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      width: 15 + weight / 4, // Smaller width for plates
      height: 35 + (weight / 45) * 70, // Smaller height for plates
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.center,
      child: Text(
        weight % 1 == 0 ? weight.toInt().toString() : weight.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontSize: weight == 2.5 ? 14 : 12, // Larger font size for "2.5"
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
