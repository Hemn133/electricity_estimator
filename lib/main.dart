import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'about_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ElectricityEstimatorApp());
}

class ElectricityEstimatorApp extends StatelessWidget {
  const ElectricityEstimatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoltCalc Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
          secondary: Colors.tealAccent,
          surface: Colors.grey[50]!,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
      ),
      home: const MainNavigationNavigationContainer(),
    );
  }
}

class MainNavigationNavigationContainer extends StatefulWidget {
  const MainNavigationNavigationContainer({super.key});

  @override
  State<MainNavigationNavigationContainer> createState() => _MainNavigationNavigationContainerState();
}

class _MainNavigationNavigationContainerState extends State<MainNavigationNavigationContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CalculatorScreen(),
    const HistoryScreen(),
    const AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}