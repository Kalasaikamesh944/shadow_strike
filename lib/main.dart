// lib/main.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadow_strike/vernubulity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'vernubulites_pro.dart'; // Your scanner logic

const Color bgColor = Colors.black;
const Color hackerGreen = Colors.greenAccent;

void main() {
  runApp(const VernubulitesProApp());
}

class VernubulitesProApp extends StatelessWidget {
  const VernubulitesProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shadow_strike pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'RobotoMono', color: hackerGreen),
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  List<Vulnerability> _results = [];

  void _onScanComplete(List<Vulnerability> res) {
    setState(() {
      _results = res;
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ScannerScreen(onComplete: _onScanComplete),
      ResultsScreen(results: _results),
      const AboutScreen(),
      const DonateScreen(),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bgColor,
        selectedItemColor: hackerGreen,
        unselectedItemColor: Colors.white54,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Scan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Results',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Donate'),
        ],
      ),
    );
  }
}

class ScannerScreen extends StatefulWidget {
  final void Function(List<Vulnerability>) onComplete;
  const ScannerScreen({super.key, required this.onComplete});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final _urlCtrl = TextEditingController();
  final List<String> _logs = [];
  bool _scanning = false;

  Future<void> _startScan() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a URL')));
      return;
    }

    setState(() {
      _scanning = true;
      _logs.clear();
    });
    _addLog('🌐 Connecting to $url...');

    try {
      // NOTE: removed the onLog parameter here
      final results = await VernubulitesPro.scan(
        url,
        onLog: (msg) {
          _addLog(msg); // this will be called by each check
        },
      );

      if (results.isEmpty) {
        _addLog('✅ No vulnerabilities found.');
      } else {
        _addLog('✅ Scan complete: ${results.length} issues.');
        // Log each finding
        for (var v in results) {
          _addLog('[${v.severity}] ${v.type} at ${v.url}');
        }
      }

      widget.onComplete(results);
    } catch (e) {
      _addLog('❌ Error: $e');
    } finally {
      setState(() => _scanning = false);
    }
  }

  void _addLog(String msg) => setState(() => _logs.add(msg));

  Future<void> _saveLogs() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/vernubulites_logs.json');
    await file.writeAsString(jsonEncode(_logs));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Saved logs to ${file.path}')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vernubulites Scanner'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _urlCtrl,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                color: hackerGreen,
              ),
              decoration: InputDecoration(
                hintText: 'https://example.com',
                hintStyle: TextStyle(color: hackerGreen.withOpacity(0.5)),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _scanning ? null : _startScan,
              style: ElevatedButton.styleFrom(backgroundColor: hackerGreen),
              child: Text(
                _scanning ? 'SCANNING...' : 'START SCAN',
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'RobotoMono',
                ),
              ),
            ).animate().shake(duration: 500.ms, hz: 2),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: hackerGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder:
                      (_, i) => Text(
                        _logs[i],
                        style: const TextStyle(
                          fontFamily: 'RobotoMono',
                          color: hackerGreen,
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (i * 50).ms),
                ),
              ),
            ),
            if (_logs.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _saveLogs,
                icon: const Icon(Icons.save, color: Colors.black),
                label: const Text(
                  'Save Logs',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: hackerGreen),
              ),
          ],
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final List<Vulnerability> results;
  const ResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final counts = {
      'Critical':
          results.where((v) => v.severity.toLowerCase() == 'critical').length,
      'High': results.where((v) => v.severity.toLowerCase() == 'high').length,
      'Medium':
          results.where((v) => v.severity.toLowerCase() == 'medium').length,
      'Low': results.where((v) => v.severity.toLowerCase() == 'low').length,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Results'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SfCircularChart(
              title: ChartTitle(
                text: 'Severity Distribution',
                textStyle: const TextStyle(color: hackerGreen),
              ),
              legend: Legend(
                isVisible: true,
                textStyle: const TextStyle(color: Colors.white),
              ),
              series: <PieSeries<MapEntry<String, int>, String>>[
                PieSeries<MapEntry<String, int>, String>(
                  dataSource: counts.entries.toList(),
                  xValueMapper: (e, _) => e.key,
                  yValueMapper: (e, _) => e.value,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms),
            const SizedBox(height: 12),
            if (results.isEmpty)
              const Text(
                'No vulnerabilities found.',
                style: TextStyle(color: hackerGreen),
              )
            else
              ...results.map(
                (v) => Card(
                  color: bgColor,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: hackerGreen),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(
                      '${v.type} [${v.severity}]',
                      style: TextStyle(color: _sevColor(v.severity)),
                    ),
                    subtitle: Text(
                      v.description,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static Color _sevColor(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return Colors.redAccent;
      case 'high':
        return Colors.orangeAccent;
      case 'medium':
        return Colors.yellowAccent;
      default:
        return hackerGreen;
    }
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
        backgroundColor: bgColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            'ShadowStrike Pro v1.0\n\n'
            'Developed by Kala Security Program\n\n'
            'Kala Security Program is dedicated to empowering ethical hackers and '
            'security researchers with open-source, cutting-edge tools. Our mission '
            'is to make web applications safer by providing robust, neon-themed '
            'vulnerability scanners that are easy to use and deeply configurable.\n\n'
            'Features:\n'
            '• 100+ checks (SQLi, XSS, SSRF, CSRF, CORS, JWT, GraphQL, and more)\n'
            '• Live, animated terminal-style logs\n'
            '• Cyberpunk neon UI with animations\n'
            '• Save logs to JSON for reporting\n\n'
            'Use responsibly on authorized targets only!\n\n'
            'Licensed under the MIT License.',
            style: const TextStyle(
              color: hackerGreen,
              fontFamily: 'RobotoMono',
              fontSize: 16,
              height: 1.5,
              shadows: [Shadow(color: hackerGreen, blurRadius: 20)],
            ),
          ).animate().fadeIn(duration: 800.ms),
        ),
      ),
    );
  }
}

class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate'), centerTitle: true),
      body: Center(
        child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '❤️ Support ShadowStrike Pro!',
                  style: TextStyle(
                    color: hackerGreen,
                    fontSize: 22,
                    shadows: const [Shadow(color: hackerGreen, blurRadius: 15)],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Phonepay: 9392278183@ibl',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            )
            .animate()
            .slideY(begin: 0.5, duration: 500.ms)
            .fadeIn(duration: 500.ms),
      ),
    );
  }
}
