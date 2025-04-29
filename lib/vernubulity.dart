// lib/vulnerability.dart
class Vulnerability {
  final String id;
  final String type;
  final String url;
  final String severity;
  final String description;
  final String category;
  final String remediation;
  final String? evidence;
  final String? cweId;
  final String? owaspCategory;

  Vulnerability({
    String? id,
    required this.type,
    required this.url,
    required this.severity,
    required this.description,
    required this.category,
    required this.remediation,
    this.evidence,
    this.cweId,
    this.owaspCategory,
  }) : id = id ?? 'VULN-${DateTime.now().millisecondsSinceEpoch}';
}
