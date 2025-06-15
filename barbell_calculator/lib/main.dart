import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for setting device orientation
import 'package:shared_preferences/shared_preferences.dart'; // Import for saving purchase state
import 'dart:convert'; // Import for JSON encoding and decoding
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'dart:async'; // Import for StreamSubscription
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
// Conditional import for BannerAdWidget
import 'ads_stub.dart'
  if (dart.library.html) 'ads_web.dart'
  if (dart.library.io) 'ads_mobile.dart';

final bool isMobile = !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
     defaultTargetPlatform == TargetPlatform.iOS);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isMobile) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(BarbellCalculatorApp());
}

class BarbellCalculatorApp extends StatelessWidget {
  BarbellCalculatorApp({super.key});

  final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF212121),
      secondary: Colors.blue,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF212121),
      foregroundColor: Colors.blue,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF212121),
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: Colors.blue),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.blue),
      trackColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.5)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      home: BarbellCalculatorHome(),
    );
  }
}

class BarbellCalculatorHome extends StatefulWidget {
  const BarbellCalculatorHome({super.key});

  @override
  State<BarbellCalculatorHome> createState() => _BarbellCalculatorHomeState();
}

class _BarbellCalculatorHomeState extends State<BarbellCalculatorHome>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  double weight = 45;
  double barWeight = 45;
  final TextEditingController _controller = TextEditingController(text: '45');
  Map<double, int> plateInventory = {45: 4, 35: 2, 25: 2, 10: 4, 5: 4, 2.5: 2};

  bool _isWeightAchievable =
      true; // Flag to track if the target weight is achievable
  String _errorMessage = ''; // Error message to display when weight is not achievable

  late AnimationController _numberAnimationController;
  late Animation<double> _numberAnimation;

  bool _adsRemoved = false; // Track if ads are removed

  bool isWeightToPlates = true; // Default mode is Weight to Plates

  // --- FIX: Move selectedPlates to state ---
  List<double> selectedPlates = [];

  late final StreamSubscription<dynamic> _purchaseSubscription = const Stream.empty().listen((_) {});

  // Track if the user has dismissed the large window warning in this session
  bool _largeWindowWarningDismissed = false;

  @override
  void initState() {
    super.initState();
    _initializePurchaseState();
    _loadPlateInventory(); // Load plate inventory on app start
    _loadBarWeight(); // Load bar weight on app start
    _numberAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _numberAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _numberAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _numberAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _numberAnimationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _numberAnimationController.dispose();
    _purchaseSubscription.cancel();
    super.dispose();
  }

  Future<void> _saveBarWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('barWeight', barWeight);
  }

  Future<void> _loadBarWeight() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      barWeight =
          prefs.getDouble('barWeight') ?? 45.0; // Default to 45.0 if not set
    });
  }

  Future<void> _initializePurchaseState() async {
    final prefs = await SharedPreferences.getInstance();
    _adsRemoved = prefs.getBool('adsRemoved') ?? false;
  }

  Future<void> _removeAds() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('adsRemoved', true);
    setState(() {
      _adsRemoved = true;
    });
  }

  Future<void> _restorePurchases() async {
    // Stub for non-mobile platforms
  }

  void _listenToPurchaseUpdated(List<dynamic> purchases) async {
    // Stub for non-mobile platforms
  }

  void _buyRemoveAds() async {
    // Stub for non-mobile platforms
  }

  Future<void> _savePlateInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final inventoryMap = plateInventory.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    await prefs.setString('plateInventory', jsonEncode(inventoryMap));
  }

  Future<void> _loadPlateInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final inventoryString = prefs.getString('plateInventory');
    if (inventoryString != null) {
      final Map<String, dynamic> inventoryMap = jsonDecode(inventoryString);
      setState(() {
        plateInventory = inventoryMap.map(
          (key, value) => MapEntry(double.parse(key), value as int),
        );
      });
    }
  }

  void _applyInventoryChanges(Map<double, int> updatedInventory) {
    setState(() {
      plateInventory = Map.from(updatedInventory);
      _savePlateInventory(); // Save the updated inventory
    });
  }

  void _toggleMode() {
    if (!kIsWeb) HapticFeedback.lightImpact(); // Only on mobile
    setState(() {
      isWeightToPlates = !isWeightToPlates;
    });
  }

  void _adjustWeight(double amount) {
    if (!kIsWeb) HapticFeedback.mediumImpact(); // Only on mobile
    setState(() {
      weight = (weight + amount).clamp(
        barWeight,
        405,
      ); // Ensure weight does not exceed 405
      _controller.text = weight.toStringAsFixed(0);
    });
  }

  void _resetWeight() {
    if (!kIsWeb) HapticFeedback.lightImpact(); // Only on mobile
    setState(() {
      weight = barWeight; // Reset target weight to barbell weight
      _controller.text = barWeight.toStringAsFixed(0);
    });
  }

  void _showErrorMessage(String message) {
    _scaffoldMessengerKey.currentState
        ?.clearSnackBars(); // Clear existing SnackBars
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validateAndSetWeight(String value) {
    final newValue = double.tryParse(value);
    if (newValue == null || newValue < barWeight || newValue > 405) {
      _showErrorMessage(
        'Invalid weight. Please enter a number between $barWeight and 405.',
      );
      _controller.text = weight.toStringAsFixed(0);
      return;
    }
    setState(() => weight = newValue);
  }

  void _animateNumberChange() {
    _numberAnimationController.forward();
  }

  void _updateBarWeight(double newBarWeight) {
    setState(() {
      barWeight = newBarWeight;
      weight = barWeight; // Reset target weight to new bar weight
      _controller.text = barWeight.toStringAsFixed(0);
      _saveBarWeight(); // Save the updated bar weight
    });
  }

  List<double> getPlatesNeeded() {
    double remainder = weight - barWeight;
    Map<double, int> tempInventory = Map.from(plateInventory);
    List<double> usedPlates = [];

    for (double plate
        in tempInventory.keys.toList()..sort((a, b) => b.compareTo(a))) {
      while (remainder >= plate * 2 && tempInventory[plate]! > 0) {
        usedPlates.add(plate);
        remainder -= plate * 2;
        tempInventory[plate] = tempInventory[plate]! - 1;
      }
    }

    if (remainder > 0) {
      setState(() {
        _isWeightAchievable = false;
        _errorMessage =
            'Target weight cannot be achieved with available plates.';
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
      totalWeight +=
          plate * 2; // Each plate is added to both sides of the barbell
    }
    return totalWeight;
  }

  Widget buildPlatesSelection({int? maxPlates}) {
    Map<double, int> tempInventory = Map.from(plateInventory);
    // Use the stateful selectedPlates

    // Calculate available plates for selection (subtract already selected)
    Map<double, int> availableInventory = Map.from(tempInventory);
    for (var plate in selectedPlates) {
      if (availableInventory.containsKey(plate) &&
          availableInventory[plate]! > 0) {
        availableInventory[plate] = availableInventory[plate]! - 1;
      }
    }

    // Determine the effective maxPlates (default to unlimited if not provided)
    int effectiveMaxPlates = maxPlates ?? 1000;

    return Column(
      children: [
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _numberAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _numberAnimation.value,
              child: Text(
                calculateWeightFromPlates(selectedPlates).toStringAsFixed(0),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final int leftCount = selectedPlates.length;
              // Calculate left/right padding to center the bar
              final double plateWidth = 15 + 45 / 4; // Max width for a plate
              final double barWidth = 20;
              final double sidePadding =
                  ((availableWidth - barWidth) / 2) - (leftCount * plateWidth);
              return Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding > 0 ? sidePadding : 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...selectedPlates.reversed.map(
                          (w) => AnimatedPlate(weight: w),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey,
                            ),
                            Text(
                              barWeight.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        ...selectedPlates.map((w) => AnimatedPlate(weight: w)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (!kIsWeb) HapticFeedback.mediumImpact(); // Only on mobile
            setState(() {
              selectedPlates.clear();
              _animateNumberChange();
            });
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(120, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Reset', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 4, // Display 4 buttons per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true, // Ensure the grid only takes up necessary space
          physics:
              const NeverScrollableScrollPhysics(), // Disable scrolling for the grid
          children:
              availableInventory.entries.map((entry) {
                // Gray out if this plate is unavailable OR if the bar is already max loaded
                final bool isBarMaxLoaded =
                    selectedPlates.length >= effectiveMaxPlates;
                final bool isSelected = selectedPlates.contains(entry.key);
                final bool isAvailable =
                    entry.value > 0 && (!isBarMaxLoaded || isSelected);
                return GestureDetector(
                  onTap:
                      isAvailable && !isBarMaxLoaded
                          ? () {
                            setState(() {
                              selectedPlates.add(entry.key);
                              selectedPlates.sort(
                                (a, b) => b.compareTo(a),
                              ); // Sort plates by size
                              HapticFeedback.lightImpact(); // Add haptic feedback when plate is added
                              _animateNumberChange();
                            });
                          }
                          : null,
                  onLongPress:
                      isSelected
                          ? () {
                            setState(() {
                              // Remove the last occurrence of this plate if present
                              int idx = selectedPlates.lastIndexOf(entry.key);
                              if (idx != -1) {
                                selectedPlates.removeAt(idx);
                                _animateNumberChange();
                              }
                            });
                          }
                          : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.blue : Colors.grey[700],
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (isAvailable)
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius:
                                isSelected ? 5 : 0, // Highlight selected plates
                          ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key % 1 == 0 ? entry.key.toInt() : entry.key} lb',
                      style: TextStyle(
                        color: isAvailable ? Colors.white : Colors.white54,
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
  }

  Widget buildSmallPlate(double weight) {
    String display =
        weight % 1 == 0
            ? weight.toInt().toString()
            : weight.toStringAsFixed(1); // Ensure "2.5" is displayed clearly
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
          fontSize: 12,
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
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ), // Slightly larger font size
                  ),
                ],
              ),
              ...plates.map((w) => buildPlate(w)), // Show right side weights
              Container(
                width:
                    15, // Slightly longer bar sticking out beyond the weights
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
    String display =
        weight % 1 == 0 ? weight.toInt().toString() : weight.toString();
    double plateHeight =
        80 + (weight / 45) * 160; // Moderately larger height for plates
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
          fontSize: weight == 2.5 ? 15 : 20, // Smaller text for 2.5lb plates
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ElevatedButton buildElevatedButton({
    required String label,
    required VoidCallback onPressed,
    double fontSize = 16,
    double minWidth = 60,
    double minHeight = 40,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth, minHeight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: TextStyle(fontSize: fontSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // Show the warning if the window is large and not dismissed
    bool showLargeWindowWarning = width > 600 && !_largeWindowWarningDismissed;
    // If the window becomes small, reset the dismissed state so the warning can reappear
    if (width <= 600 && _largeWindowWarningDismissed) {
      // Use WidgetsBinding to schedule setState after build to avoid build cycle errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _largeWindowWarningDismissed = false;
          });
        }
      });
    }
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        centerTitle: false, // Remove centerTitle
        title: const SizedBox.shrink(), // Remove the default title
        flexibleSpace: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: constraints.maxHeight - 45, // Lift logo up by 5 pixels
                  child: Image.asset('assets/logo.png', height: 40),
                ),
              ],
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, size: 30),
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
                          if (!kIsWeb) ...[
                            ElevatedButton(
                              onPressed: _adsRemoved ? null : () { _buyRemoveAds(); },
                              child: _adsRemoved
                                  ? const Text('Ads Removed')
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.block_flipped, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Remove Ads (\$1.99)'),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _restorePurchases,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.cloud_download, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Restore Purchases'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          ElevatedButton(
                            onPressed: () async {
                              const url =
                                  'https://occipital-hub-fe2.notion.site/Privacy-Policy-for-Barbell-Calculator-1f881eaa537580b997e3f04b4e8795dd?pvs=4';
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(
                                  Uri.parse(url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                _showErrorMessage(
                                  'Could not open privacy policy.',
                                );
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.policy, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Privacy Policy'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Close',
                            style: TextStyle(fontSize: 18, color: Colors.white),
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
            icon: const Icon(
              Icons.fitness_center,
              size: 30,
            ), // Icon for barbell weight
            tooltip: 'Set Barbell Weight',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final TextEditingController barWeightController =
                      TextEditingController(text: barWeight.toInt().toString());
                  return AlertDialog(
                    title: const Text('Set Barbell Weight'),
                    content: TextField(
                      controller: barWeightController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*\.?[0-9]*'),
                        ),
                      ],
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          final newBarWeight = int.tryParse(
                            barWeightController.text,
                          );
                          if (newBarWeight != null && newBarWeight > 0) {
                            _updateBarWeight(newBarWeight.toDouble());
                            Navigator.of(context).pop();
                          } else {
                            _showErrorMessage(
                              'Invalid weight. Please enter a positive integer.',
                            );
                          }
                        },
                        child: const Text(
                          'Set',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
              Map<double, int> tempInventory = Map.from(
                plateInventory,
              ); // Temporary inventory for dialog
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
                builder:
                    (context) => StatefulBuilder(
                      builder: (context, setState) {
                        final TextEditingController customWeightController =
                            TextEditingController();
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
                                              entry.key % 1 == 0
                                                  ? entry.key.toInt().toString()
                                                  : entry.key.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      if (tempInventory[entry
                                                              .key]! >
                                                          0) {
                                                        tempInventory[entry
                                                                .key] =
                                                            tempInventory[entry
                                                                .key]! -
                                                            1;
                                                        if (tempInventory[entry
                                                                .key] ==
                                                            0) {
                                                          tempInventory.remove(
                                                            entry.key,
                                                          ); // Remove plate when count reaches 0
                                                        }
                                                      }
                                                    });
                                                  },
                                                ),
                                                Text(
                                                  '${tempInventory[entry.key]}',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () {
                                                    setState(() {
                                                      tempInventory[entry.key] =
                                                          tempInventory[entry
                                                              .key]! +
                                                          1;
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
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^[0-9]*\.?[0-9]*'),
                                        ),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Add another',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      final customWeight = double.tryParse(
                                        customWeightController.text,
                                      );
                                      if (customWeight != null &&
                                          customWeight > 0) {
                                        setState(() {
                                          tempInventory[customWeight] =
                                              (tempInventory[customWeight] ??
                                                  0) +
                                              1;
                                        });
                                        customWeightController.clear();
                                      } else {
                                        _showErrorMessage(
                                          'Invalid weight. Please enter a positive number.',
                                        );
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(
                                        50,
                                        50,
                                      ), // Ideal size for mobile
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ), // Rounded corners
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Confirm Reset',
                                              ),
                                              content: const Text(
                                                'Are you sure you want to reset the inventory to its default state?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(), // Close dialog
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      tempInventory = Map.from(
                                                        defaultInventory,
                                                      ); // Reset to default inventory
                                                    });
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Close dialog
                                                  },
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
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
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Confirm Clear All',
                                              ),
                                              content: const Text(
                                                'Are you sure you want to remove all plates from the inventory?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(), // Close dialog
                                                  child: const Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      tempInventory
                                                          .clear(); // Remove all plates
                                                    });
                                                    Navigator.of(
                                                      context,
                                                    ).pop(); // Close dialog
                                                  },
                                                  child: const Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
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
                                _applyInventoryChanges(
                                  tempInventory,
                                ); // Apply changes to the main inventory
                                Navigator.of(context).pop();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ), // Added padding
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ), // White text
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
        child: Column(
          children: [
            if (showLargeWindowWarning)
              Container(
                width: double.infinity,
                color: Colors.amber[800],
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10), // Thinner vertical padding
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.black, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Use a mobile device for the best experience.',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black, size: 18),
                        tooltip: 'Dismiss',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _largeWindowWarningDismissed = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
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
                          icon: const Icon(Icons.swap_horiz, size: 30),
                          label: isWeightToPlates
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Weight', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward, size: 24, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('Plates', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Plates', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_forward, size: 24, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('Weight', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ],
                                ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isWeightToPlates) ...[
                      Expanded(child: Center(child: buildBarbellDiagram())),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[0-9]*\.?[0-9]*'),
                          ),
                        ],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color:
                              _isWeightAchievable ? Colors.white : Colors.red,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Enter Weight',
                          labelStyle: const TextStyle(color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  !_isWeightAchievable
                                      ? Colors.red
                                      : Colors.blue,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  !_isWeightAchievable
                                      ? Colors.red
                                      : Colors.blue,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  !_isWeightAchievable
                                      ? Colors.red
                                      : Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: _validateAndSetWeight,
                      ),
                      if (!_isWeightAchievable)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ] else ...[
                      Expanded(child: buildPlatesSelection(maxPlates: 12)),
                    ],
                    const SizedBox(height: 20),
                    if (isWeightToPlates)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildElevatedButton(
                            label: '-90',
                            onPressed: () => _adjustWeight(-90),
                          ),
                          buildElevatedButton(
                            label: '-5',
                            onPressed: () => _adjustWeight(-5),
                          ),
                          buildElevatedButton(
                            label: 'Reset',
                            onPressed: _resetWeight,
                            minWidth: 70,
                          ),
                          buildElevatedButton(
                            label: '+5',
                            onPressed: () => _adjustWeight(5),
                          ),
                          buildElevatedButton(
                            label: '+90',
                            onPressed: () => _adjustWeight(90),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (!_adsRemoved) BannerAdWidget(),
          ],
        ),
      ),
      backgroundColor: Colors.grey[900], // Always use dark mode background
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
          fontSize: weight == 2.5 ? 8 : 12, // Larger font size for "2.5"
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
