// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shadow_strike/vernubulity.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:path_provider/path_provider.dart';
import 'vernubulites_pro.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';


// Cyberpunk color palette
const Color bgColor = Color(0xFF0A0A0A);
const Color hackerGreen = Color(0xFF00FF41);
const Color cyberBlue = Color(0xFF00F5FF);
const Color matrixRed = Color(0xFFFF0044);
const Color terminalYellow = Color(0xFFFFF700);

// Terminal-style text theme
final _terminalTextTheme = TextTheme(
  displayLarge: const TextStyle(
    fontFamily: 'CourierPrime',
    color: hackerGreen,
    fontSize: 32,
  ),
  displayMedium: const TextStyle(
    fontFamily: 'CourierPrime',
    color: hackerGreen,
    fontSize: 24,
  ),
  bodyLarge: const TextStyle(
    fontFamily: 'CourierPrime',
    color: hackerGreen,
    fontSize: 16,
  ),
  bodyMedium: const TextStyle(
    fontFamily: 'CourierPrime',
    color: cyberBlue,
    fontSize: 14,
  ),
  labelLarge: const TextStyle(
    fontFamily: 'CourierPrime',
    color: terminalYellow,
    fontSize: 14,
  ),
);

// Cyberpunk box decoration
BoxDecoration _cyberBoxDecoration() {
  return BoxDecoration(
    border: Border.all(color: hackerGreen.withOpacity(0.5)),
    borderRadius: BorderRadius.circular(4),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0.3)],
    ),
    boxShadow: [
      BoxShadow(
        color: hackerGreen.withOpacity(0.2),
        spreadRadius: 1,
        blurRadius: 10,
      ),
    ],
  );
}

void main() {
  runApp(const VernubulitesProApp());
}

class VernubulitesProApp extends StatelessWidget {
  const VernubulitesProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHADOWSTRIKE PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // make all scaffolds transparent so the background peek through
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: _terminalTextTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black.withOpacity(0.7),
          centerTitle: true,
          titleTextStyle: _terminalTextTheme.displayMedium?.copyWith(
            shadows: [
              Shadow(color: hackerGreen.withOpacity(0.5), blurRadius: 10),
            ],
          ),
          elevation: 0,
          iconTheme: const IconThemeData(color: hackerGreen),
        ),
        cardTheme: CardTheme(
          color: Colors.black.withOpacity(0.5),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: hackerGreen.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        dividerTheme: DividerThemeData(color: hackerGreen.withOpacity(0.3)),
      ),
      // wrap every screen in a Stack that paints your image behind it
      builder: (context, child) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/cyber.png', fit: BoxFit.cover),
            ),
            if (child != null) child,
          ],
        );
      },
      home: const HomeScreen(),
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
      body: Stack(children: [_buildCyberBackground(), screens[_index]]),
      bottomNavigationBar: _buildCyberNavBar(),
    );
  }

  Widget _buildCyberBackground() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/cyber.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.dstIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCyberNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: hackerGreen.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarButton(
            icon: Icons.search,
            label: 'SCAN',
            isActive: _index == 0,
            onTap: () => setState(() => _index = 0),
          ),
          _NavBarButton(
            icon: Icons.analytics,
            label: 'RESULTS',
            isActive: _index == 1,
            onTap: () => setState(() => _index = 1),
          ),
          _NavBarButton(
            icon: Icons.info,
            label: 'ABOUT',
            isActive: _index == 2,
            onTap: () => setState(() => _index = 2),
          ),
          _NavBarButton(
            icon: Icons.code,
            label: 'DONATE',
            isActive: _index == 3,
            onTap: () => setState(() => _index = 3),
          ),
        ],
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _NavBarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? hackerGreen : Colors.white54, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'CourierPrime',
              fontSize: 10,
              color: isActive ? hackerGreen : Colors.white54,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: hackerGreen,
            ),
        ],
      ),
    );
  }
}

// ScannerScreen unchanged...
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
  final _scrollCtrl = ScrollController();

  Future<void> _startScan() async {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      _addLog('[ERROR] No target URL specified', isError: true);
      return;
    }

    setState(() {
      _scanning = true;
      _logs.clear();
    });
    _addLog('[SYSTEM] Initializing ShadowStrike Pro v1.0');
    _addLog('[SYSTEM] Loading vulnerability database...');
    _addLog('[TARGET] Scanning: $url');
    _addLog('[STATUS] Establishing connection...');

    try {
      final results = await VernubulitesPro.scan(
        url,
        onLog: (msg) => _addLog(msg),
      );

      if (results.isEmpty) {
        _addLog('[RESULT] Target appears secure. No vulnerabilities detected.');
      } else {
        _addLog('[RESULT] ${results.length} vulnerabilities found:');
        for (var v in results) {
          _addLog('[FINDING] ${v.type} (${v.severity}) at ${v.url}');
        }
      }

      widget.onComplete(results);
    } catch (e) {
      _addLog('[ERROR] Scan failed: $e', isError: true);
    } finally {
      setState(() => _scanning = false);
      _addLog('[SYSTEM] Scan terminated');
    }
  }

  void _addLog(String msg, {bool isError = false}) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} $msg');
    });
    // scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveLogs() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/shadowstrike_${DateTime.now().millisecondsSinceEpoch}.log',
      );
      await file.writeAsString(_logs.join('\n'));
      _addLog('[SYSTEM] Logs saved to ${file.path}');
    } catch (e) {
      _addLog('[ERROR] Failed to save logs: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHADOWSTRIKE PRO'),
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLogs,
              tooltip: 'Save logs',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildTargetInput(context),
            const SizedBox(height: 16),
            _buildScanButton(context),
            const SizedBox(height: 16),
            _buildLogDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CYBER VULNERABILITY SCANNER',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: cyberBlue,
            shadows: [
              Shadow(color: cyberBlue.withOpacity(0.5), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Penetration testing toolkit v1.0',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hackerGreen.withOpacity(0),
                hackerGreen,
                hackerGreen.withOpacity(0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTargetInput(BuildContext context) {
    return Container(
      decoration: _cyberBoxDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Text(
            '>',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: matrixRed),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _urlCtrl,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'https://target.com',
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _scanning ? null : _startScan,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: hackerGreen,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: _scanning ? matrixRed : hackerGreen,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_scanning)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: matrixRed,
              ),
            )
          else
            const Icon(Icons.security, size: 20),
          const SizedBox(width: 8),
          Text(
            _scanning ? 'SCAN IN PROGRESS' : 'INITIATE SCAN',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    ).animate().shimmer(duration: 1500.ms).then().shake(hz: 3);
  }

  Widget _buildLogDisplay() {
    return Expanded(
      child: Container(
        decoration: _cyberBoxDecoration(),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            _buildScanLines(),
            ListView.builder(
              controller: _scrollCtrl,
              itemCount: _logs.length,
              itemBuilder: (_, i) {
                final isError = _logs[i].contains('[ERROR]');
                final isWarning = _logs[i].contains('[WARNING]');
                final color =
                    isError
                        ? matrixRed
                        : isWarning
                        ? terminalYellow
                        : _logs[i].contains('[FINDING]')
                        ? hackerGreen
                        : cyberBlue;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _logs[i],
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: color),
                  ).animate().fadeIn(duration: 200.ms),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanLines() {
    return IgnorePointer(
      child: Column(
        children: List.generate(
          30,
          (i) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 1),
              color: Colors.black.withOpacity(i % 2 == 0 ? 0.03 : 0.01),
            ),
          ),
        ),
      ),
    );
  }
}

// ResultsScreen with share logic
class ResultsScreen extends StatelessWidget {
  final List<Vulnerability> results;
  const ResultsScreen({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    final counts = {
      'CRITICAL':
          results.where((v) => v.severity.toLowerCase() == 'critical').length,
      'HIGH': results.where((v) => v.severity.toLowerCase() == 'high').length,
      'MEDIUM':
          results.where((v) => v.severity.toLowerCase() == 'medium').length,
      'LOW': results.where((v) => v.severity.toLowerCase() == 'low').length,
      'INFO': results.where((v) => v.severity.toLowerCase() == 'info').length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCAN RESULTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share results',
            onPressed: () => _shareResults(context, counts),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSummaryCard(context, counts),
              const SizedBox(height: 16),
              _buildSeverityChart(context, counts),
              const SizedBox(height: 16),
              ..._buildFindingsList(context),
            ],
          ),
        ),
      ),
    );
  }

  void _shareResults(BuildContext context, Map<String, int> counts) {
    final buffer = StringBuffer();
    buffer.writeln('SHADOWSTRIKE PRO Scan Results');
    buffer.writeln('============================');
    buffer.writeln('Summary:');
    counts.forEach((key, value) {
      buffer.writeln('  $key: $value');
    });
    buffer.writeln('\nFindings:');
    if (results.isEmpty) {
      buffer.writeln('  No vulnerabilities detected.');
    } else {
      for (var v in results) {
        buffer.writeln('- ${v.type} [${v.severity.toUpperCase()}] at ${v.url}');
      }
    }

    Share.share(buffer.toString(), subject: 'ShadowStrike Pro Scan Results');
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    return Container(
      decoration: _cyberBoxDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCAN SUMMARY',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cyberBlue, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: hackerGreen.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(context, 'TOTAL', total.toString(), hackerGreen),
              _buildStatItem(
                context,
                'CRITICAL',
                counts['CRITICAL'].toString(),
                matrixRed,
              ),
              _buildStatItem(
                context,
                'HIGH',
                counts['HIGH'].toString(),
                terminalYellow,
              ),
              _buildStatItem(
                context,
                'MEDIUM',
                counts['MEDIUM'].toString(),
                cyberBlue,
              ),
              _buildStatItem(
                context,
                'LOW',
                counts['LOW'].toString(),
                hackerGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(color: color, fontSize: 24),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildSeverityChart(BuildContext context, Map<String, int> counts) {
    return Container(
      decoration: _cyberBoxDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'SEVERITY DISTRIBUTION',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cyberBlue, fontSize: 18),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: SfCircularChart(
              palette: [
                matrixRed,
                terminalYellow,
                cyberBlue,
                hackerGreen,
                Colors.white54,
              ],
              series: <PieSeries<MapEntry<String, int>, String>>[
                PieSeries<MapEntry<String, int>, String>(
                  dataSource: counts.entries.toList(),
                  xValueMapper: (e, _) => e.key,
                  yValueMapper: (e, _) => e.value,
                  dataLabelMapper: (e, _) => '${e.key}\n${e.value}',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(
                      fontFamily: 'CourierPrime',
                      fontSize: 12,
                    ),
                  ),
                  explode: true,
                  explodeIndex: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFindingsList(BuildContext context) {
    if (results.isEmpty) {
      return [
        Container(
          decoration: _cyberBoxDecoration(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.verified_user, size: 48, color: hackerGreen),
              const SizedBox(height: 16),
              Text(
                'NO VULNERABILITIES DETECTED',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: hackerGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'Target appears secure.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ];
    }

    return [
      Text(
        'FINDINGS (${results.length})',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: cyberBlue, fontSize: 18),
      ),
      const SizedBox(height: 8),
      ...results.map(
        (v) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: _cyberBoxDecoration(),
          child: ExpansionTile(
            title: Text(
              '${v.type} [${v.severity.toUpperCase()}]',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _getSeverityColor(v.severity),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFindingDetail(context, 'URL', v.url),
                    const SizedBox(height: 8),
                    _buildFindingDetail(context, 'DESCRIPTION', v.description),
                    const SizedBox(height: 8),
                    if (v.remediation.isNotEmpty)
                      _buildFindingDetail(
                        context,
                        'REMEDIATION',
                        v.remediation,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildFindingDetail(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: terminalYellow),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return matrixRed;
      case 'high':
        return terminalYellow;
      case 'medium':
        return cyberBlue;
      case 'low':
        return hackerGreen;
      default:
        return Colors.white;
    }
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('ABOUT SHADOWSTRIKE')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCyberHeader(context),
            const SizedBox(height: 24),
            _buildInfoCard(context),
            const SizedBox(height: 16),
            _buildFeaturesCard(context),
            const SizedBox(height: 16),
            _buildDisclaimerCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHADOWSTRIKE PRO',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            shadows: [
              Shadow(color: hackerGreen.withOpacity(0.5), blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'CYBER SECURITY ASSESSMENT TOOL',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: cyberBlue),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                hackerGreen.withOpacity(0),
                hackerGreen,
                hackerGreen.withOpacity(0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      decoration: _cyberBoxDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM INFO',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cyberBlue),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'VERSION', '1.0.0'),
          _buildInfoRow(context, 'DEVELOPER', 'KALA SECURITY PROGRAM'),
          _buildInfoRow(context, 'LICENSE', 'MIT OPEN SOURCE'),
          _buildInfoRow(context, 'BUILD', '2025.04.30'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: terminalYellow),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(BuildContext context) {
    return Container(
      decoration: _cyberBoxDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CORE FEATURES',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: cyberBlue),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(context, 'OWASP Top 10 coverage'),
          _buildFeatureItem(context, 'Real-time scanning engine'),
          _buildFeatureItem(context, 'Detailed reporting'),
          _buildFeatureItem(context, 'Custom payload support'),
          _buildFeatureItem(context, 'API security testing'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: hackerGreen, size: 16),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    return Container(
      decoration: _cyberBoxDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEGAL DISCLAIMER',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: matrixRed),
          ),
          const SizedBox(height: 8),
          Text(
            'This tool is provided for legal security testing purposes only. Unauthorized scanning without permission is illegal.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}


class DonateScreen extends StatelessWidget {
  const DonateScreen({super.key});

  static const _upiId    = '9392278183@ibl';
  static const _payee    = 'ShadowStrike Pro';
  static const _note     = 'Thank you for supporting ShadowStrike Pro';
  static const _currency = 'INR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('SUPPORT DEVELOPMENT')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, size: 80, color: hackerGreen)
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms)
                  .then()
                  .shake(),
              const SizedBox(height: 24),
              Text(
                'SUPPORT SHADOWSTRIKE PRO',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      shadows: [
                        Shadow(
                            color: hackerGreen.withOpacity(0.5),
                            blurRadius: 10),
                      ],
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Help us maintain and improve this open-source security tool.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              // PhonePe button
              _buildDonationOption(
                context,
                title: 'Pay via PhonePe',
                icon: Icons.phone_android,
                onTap: () => _launchUpiInApp(context, 'com.phonepe.app'),
              ),
              // Google Pay button
              _buildDonationOption(
                context,
                title: 'Pay via Google Pay',
                icon: Icons.payment,
                onTap: () => _launchUpiInApp(context, 'com.google.android.apps.nbu.paisa.user'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonationOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cyberBoxDecoration(),
      child: ListTile(
        leading: Icon(icon, color: hackerGreen),
        title: Text(
          title,
          style:
              Theme.of(context).textTheme.bodyLarge?.copyWith(color: cyberBlue),
        ),
        trailing: Icon(Icons.arrow_forward, color: hackerGreen),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchUpiInApp(BuildContext context, String package) async {
    final upiUri = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': _upiId,
        'pn': _payee,
        'tn': _note,
        'am': '',        // user enters amount
        'cu': _currency,
      },
    ).toString();

    // First try explicit Android intent:
    final intent = AndroidIntent(
      action: 'action_view',
      data: upiUri,
      package: package,
    );
    try {
      await intent.launch();
    } catch (_) {
      // fallback: open chooser for any UPI app
      if (await canLaunchUrl(Uri.parse(upiUri))) {
        await launchUrl(Uri.parse(upiUri));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_appName(package)} not available',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            backgroundColor: matrixRed.withOpacity(0.8),
          ),
        );
      }
    }
  }

  String _appName(String pkg) {
    if (pkg.contains('phonepe')) return 'PhonePe';
    if (pkg.contains('paisa')) return 'Google Pay';
    return 'UPI app';
  }
}
