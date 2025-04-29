// lib/vernubulites_pro.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shadow_strike/vernubulity.dart';

class VernubulitesPro {
  static const Duration _timeout = Duration(seconds: 15);
  static final http.Client _http = http.Client();

  /// Run all checks one by one, logging progress via onLog
  static Future<List<Vulnerability>> scan(
    String baseUrl, {
    required void Function(String msg) onLog,
  }) async {
    if (!baseUrl.startsWith('http')) baseUrl = 'https://$baseUrl';
    baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

    final allVulns = <Vulnerability>[];
    final checks = <String, Future<List<Vulnerability>> Function(String)>{
      'SQL Injection': _checkSqlInjection,
      'Broken Authentication': _checkBrokenAuthentication,
      'Sensitive Data Exposure': _checkSensitiveDataExposure,
      'XXE': _checkXXE,
      'Auth Misconfiguration': _checkAuthMisconfiguration,
      'CSRF': _checkCsrf,
      'Insecure Deserialization': _checkInsecureDeserialization,
      'Components Vulnerabilities': _checkComponentsVulnerabilities,
      'Server Misconfiguration': _checkMisconfiguration,
      'XSS': _checkXss,
      'SSRF': _checkSsrF,
      'Open Redirect': _checkOpenRedirect,
      'IDOR': _checkIdor,
      'SSTI': _checkSsti,
      'Directory Traversal': _checkDirectoryTraversal,
      'Clickjacking': _checkClickjacking,
      'Insecure Cookie Flags': _checkInsecureCookieFlags,
      'Rate Limiting': _checkRateLimiting,
      'Hardcoded Secrets': _checkHardcodedSecrets,
      'CORS Misconfiguration': _checkCorsMisconfiguration,
      'JWT Issues': _checkJwtIssues,
      'GraphQL Issues': _checkGraphQLIssues,
      'API Shadowing': _checkApiShadowing,
      'Cache Poisoning': _checkCachePoisoning,
      'WebSocket CSRF': _checkWebSocketIssues,
      // HTTP smuggling is omitted
    };

    for (final entry in checks.entries) {
      final name = entry.key;
      final fn = entry.value;
      try {
        onLog('🔎 Checking $name...');
        final vulns = await fn(baseUrl).timeout(_timeout);
        onLog('✅ $name: found ${vulns.length}');
        allVulns.addAll(vulns);
      } catch (e) {
        onLog('❌ $name error: $e');
      }
    }

    // sort by severity
    allVulns.sort(
      (a, b) => _severityValue(b.severity) - _severityValue(a.severity),
    );
    return allVulns.toSet().toList();
  }

  // severity ranking
  static int _severityValue(String s) {
    switch (s.toLowerCase()) {
      case 'critical':
        return 5;
      case 'high':
        return 4;
      case 'medium':
        return 3;
      case 'low':
        return 2;
      case 'info':
        return 1;
      default:
        return 0;
    }
  }

  // ─── Checks ───────────────────────────────────────────────────────────────

  static Future<List<Vulnerability>> _checkSqlInjection(String base) async {
    final vulns = <Vulnerability>[];
    final uri = Uri.parse(base).replace(queryParameters: {'q': "' OR 1=1--"});
    final res = await _http.get(uri).timeout(_timeout);
    if (res.body.toLowerCase().contains('sql') || res.statusCode >= 500) {
      vulns.add(
        Vulnerability(
          type: 'SQL Injection',
          url: uri.toString(),
          severity: 'Critical',
          description: 'Error or stack trace indicates SQL injection.',
          category: 'Injection',
          remediation: 'Use parameterized queries or ORM methods.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkBrokenAuthentication(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final uri = Uri.parse('$base/login');
    final res = await _http
        .post(uri, body: {'username': 'admin', 'password': 'admin'})
        .timeout(_timeout);
    if (res.statusCode == 200 && res.body.toLowerCase().contains('dashboard')) {
      vulns.add(
        Vulnerability(
          type: 'Broken Authentication',
          url: uri.toString(),
          severity: 'High',
          description: 'Logged in with default or weak credentials.',
          category: 'Authentication',
          remediation: 'Enforce strong passwords and MFA.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkSensitiveDataExposure(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse(base)).timeout(_timeout);
    final body = res.body.toLowerCase();
    if (body.contains('password') ||
        body.contains('token') ||
        body.contains('apikey')) {
      vulns.add(
        Vulnerability(
          type: 'Sensitive Data Exposure',
          url: base,
          severity: 'High',
          description: 'Potential secrets or PII found in response.',
          category: 'Information Exposure',
          remediation: 'Remove sensitive data from responses.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkXXE(String base) async {
    final vulns = <Vulnerability>[];
    final payload =
        '<?xml version="1.0"?><!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>';
    final res = await _http
        .post(
          Uri.parse(base),
          headers: {'Content-Type': 'application/xml'},
          body: payload,
        )
        .timeout(_timeout);
    if (res.body.contains('root:')) {
      vulns.add(
        Vulnerability(
          type: 'XXE',
          url: base,
          severity: 'High',
          description: 'External entity expansion retrieved local file.',
          category: 'XML External Entities',
          remediation: 'Disable DTDs and external entities in XML parser.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkAuthMisconfiguration(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse('$base/admin')).timeout(_timeout);
    if (res.statusCode == 200 && !res.body.toLowerCase().contains('login')) {
      vulns.add(
        Vulnerability(
          type: 'Auth Misconfiguration',
          url: '$base/admin',
          severity: 'High',
          description: 'Admin page accessible without authentication.',
          category: 'Authentication',
          remediation: 'Restrict admin endpoints behind auth.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkCsrf(String base) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse(base)).timeout(_timeout);
    final html = res.body.toLowerCase();
    if (html.contains('<form') && !html.contains('csrf')) {
      vulns.add(
        Vulnerability(
          type: 'Missing CSRF',
          url: base,
          severity: 'Medium',
          description: 'Form posts without anti-CSRF token.',
          category: 'CSRF',
          remediation: 'Implement synchronizer tokens or same-site cookies.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkInsecureDeserialization(
    String base,
  ) async {
    // Hard to detect generically; stub returns empty
    return [];
  }

  static Future<List<Vulnerability>> _checkComponentsVulnerabilities(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse(base)).timeout(_timeout);
    final server = res.headers['server'] ?? '';
    if (server.contains('Apache/2.4.49') || server.contains('Apache/2.4.50')) {
      vulns.add(
        Vulnerability(
          type: 'Vulnerable Server Version',
          url: base,
          severity: 'Critical',
          description: 'Outdated Apache version with known CVE.',
          category: 'Components',
          remediation: 'Upgrade to a patched server version.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkMisconfiguration(String base) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse('$base/.env')).timeout(_timeout);
    if (res.statusCode == 200 && res.body.contains('DB_PASSWORD')) {
      vulns.add(
        Vulnerability(
          type: 'Env File Exposed',
          url: '$base/.env',
          severity: 'High',
          description: 'Environment file containing secrets exposed.',
          category: 'Misconfiguration',
          remediation: 'Remove or block access to env files.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkXss(String base) async {
    final vulns = <Vulnerability>[];
    final uri = Uri.parse(
      base,
    ).replace(queryParameters: {'q': '<script>alert(1)</script>'});
    final res = await _http.get(uri).timeout(_timeout);
    if (res.body.contains('<script>alert(1)</script>')) {
      vulns.add(
        Vulnerability(
          type: 'Reflected XSS',
          url: uri.toString(),
          severity: 'High',
          description: 'User input reflected without sanitization.',
          category: 'XSS',
          remediation: 'Escape or sanitize user-supplied content.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkSsrF(String base) async {
    final vulns = <Vulnerability>[];
    final uri = Uri.parse(base).replace(
      queryParameters: {'url': 'http://169.254.169.254/latest/meta-data/'},
    );
    final res = await _http.get(uri).timeout(_timeout);
    if (res.body.contains('ami-id')) {
      vulns.add(
        Vulnerability(
          type: 'SSRF',
          url: uri.toString(),
          severity: 'Critical',
          description: 'Internal metadata endpoint accessed via SSRF.',
          category: 'SSRF',
          remediation: 'Validate and block private IPs in URLs.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkOpenRedirect(String base) async {
    final vulns = <Vulnerability>[];
    final evil = 'http://evil.com';
    final uri = Uri.parse(base).replace(queryParameters: {'next': evil});
    final res = await _http.get(uri).timeout(_timeout);
    final loc = res.headers['location'] ?? '';
    if (loc.contains(evil)) {
      vulns.add(
        Vulnerability(
          type: 'Open Redirect',
          url: uri.toString(),
          severity: 'High',
          description: 'Redirect parameter can be abused for phishing.',
          category: 'Redirect',
          remediation: 'Whitelist safe redirect targets.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkIdor(String base) async {
    final vulns = <Vulnerability>[];
    final r1 = await _http.get(Uri.parse('$base/user/1')).timeout(_timeout);
    final r2 = await _http.get(Uri.parse('$base/user/2')).timeout(_timeout);
    if (r1.statusCode == 200 && r2.statusCode == 200 && r1.body != r2.body) {
      vulns.add(
        Vulnerability(
          type: 'IDOR',
          url: '$base/user/2',
          severity: 'High',
          description: 'Accessed another user’s data by changing ID.',
          category: 'Access Control',
          remediation: 'Enforce object-level authorization.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkSsti(String base) async {
    final vulns = <Vulnerability>[];
    final uri = Uri.parse(base).replace(queryParameters: {'q': '{{7*7}}'});
    final res = await _http.get(uri).timeout(_timeout);
    if (res.body.contains('49')) {
      vulns.add(
        Vulnerability(
          type: 'SSTI',
          url: uri.toString(),
          severity: 'High',
          description: 'Template expression evaluated server-side.',
          category: 'Injection',
          remediation: 'Avoid direct template evaluation of user input.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkDirectoryTraversal(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final uri = Uri.parse('$base/../../../../etc/passwd');
    final res = await _http.get(uri).timeout(_timeout);
    if (res.statusCode == 200 && res.body.contains('root:')) {
      vulns.add(
        Vulnerability(
          type: 'Directory Traversal',
          url: uri.toString(),
          severity: 'Critical',
          description: '/etc/passwd exposed via path traversal.',
          category: 'File Access',
          remediation: 'Normalize and validate file paths.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkClickjacking(String base) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse(base)).timeout(_timeout);
    final headers = res.headers;
    if (!headers.containsKey('x-frame-options') &&
        !(headers['content-security-policy']?.contains('frame-ancestors') ??
            false)) {
      vulns.add(
        Vulnerability(
          type: 'Clickjacking',
          url: base,
          severity: 'Medium',
          description: 'Missing X-Frame-Options or CSP frame-ancestors.',
          category: 'UI Security',
          remediation:
              'Add appropriate frame-ancestors or X-Frame-Options headers.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkInsecureCookieFlags(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse(base)).timeout(_timeout);
    final cookie = res.headers['set-cookie']?.toLowerCase() ?? '';
    if (!cookie.contains('httponly') || !cookie.contains('secure')) {
      vulns.add(
        Vulnerability(
          type: 'Insecure Cookie',
          url: base,
          severity: 'Medium',
          description: 'Cookies missing Secure or HttpOnly flags.',
          category: 'Session Management',
          remediation: 'Set Secure and HttpOnly on cookies.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkRateLimiting(String base) async {
    final vulns = <Vulnerability>[];
    for (int i = 0; i < 5; i++) {
      final res = await _http.get(Uri.parse(base)).timeout(_timeout);
      if (res.statusCode == 429) return vulns; // rate limiting in place
    }
    vulns.add(
      Vulnerability(
        type: 'No Rate Limiting',
        url: base,
        severity: 'Low',
        description: 'No HTTP 429 after multiple rapid requests.',
        category: 'Throttling',
        remediation: 'Implement IP/user rate limiting.',
      ),
    );
    return vulns;
  }

  static Future<List<Vulnerability>> _checkHardcodedSecrets(String base) async {
    final vulns = <Vulnerability>[];
    final res = await _http.get(Uri.parse(base)).timeout(_timeout);
    final body = res.body;
    final patterns = {
      'AWS Key': r'AKIA[0-9A-Z]{16}',
      'Private Key': r'-----BEGIN (RSA|EC|DSA) PRIVATE KEY-----',
    };
    for (final entry in patterns.entries) {
      if (RegExp(entry.value).hasMatch(body)) {
        vulns.add(
          Vulnerability(
            type: 'Hardcoded Secret - ${entry.key}',
            url: base,
            severity: 'High',
            description: 'Found ${entry.key} in response body.',
            category: 'Information Exposure',
            remediation: 'Remove secrets from public code.',
          ),
        );
      }
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkCorsMisconfiguration(
    String base,
  ) async {
    final vulns = <Vulnerability>[];
    final req = http.Request('GET', Uri.parse(base));
    req.headers['Origin'] = 'https://evil.com';
    final streamed = await _http.send(req).timeout(_timeout);
    final res = await http.Response.fromStream(streamed);
    final acao = res.headers['access-control-allow-origin'];
    if (acao == '*' || acao == 'https://evil.com') {
      vulns.add(
        Vulnerability(
          type: 'CORS Misconfiguration',
          url: base,
          severity: 'High',
          description: 'Access-Control-Allow-Origin set too permissively.',
          category: 'CORS',
          remediation: 'Restrict CORS to trusted origins.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkJwtIssues(String base) async {
    final vulns = <Vulnerability>[];
    final auth = await _http
        .post(
          Uri.parse('$base/api/auth'),
          body: {'username': 'test', 'password': 'test'},
        )
        .timeout(_timeout);
    if (auth.statusCode == 200) {
      final jsonRes = json.decode(auth.body);
      if (jsonRes is Map && jsonRes.containsKey('token')) {
        final token = jsonRes['token'] as String;
        final parts = token.split('.');
        if (parts.length == 3) {
          final header = json.decode(utf8.decode(base64Url.decode(parts[0])));
          if (header['alg'] == 'none') {
            vulns.add(
              Vulnerability(
                type: 'JWT None Algorithm',
                url: '$base/api/auth',
                severity: 'High',
                description: 'Token signed with none algorithm.',
                category: 'Authentication',
                remediation: 'Disallow none alg and require signature.',
              ),
            );
          }
        }
      }
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkGraphQLIssues(String base) async {
    final vulns = <Vulnerability>[];
    final q = '''
      query IntrospectionQuery { __schema { queryType { name } } }
    ''';
    final res = await _http
        .post(
          Uri.parse('$base/graphql'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'query': q}),
        )
        .timeout(_timeout);
    if (res.statusCode == 200 && res.body.contains('__schema')) {
      vulns.add(
        Vulnerability(
          type: 'GraphQL Introspection',
          url: '$base/graphql',
          severity: 'Medium',
          description: 'Introspection enabled in production.',
          category: 'Information Exposure',
          remediation: 'Disable introspection in prod.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkApiShadowing(String base) async {
    final vulns = <Vulnerability>[];
    final endpoints = ['/api', '/api/v1', '/api/v2'];
    for (final path in endpoints) {
      final res = await _http.get(Uri.parse('$base$path')).timeout(_timeout);
      if (res.statusCode == 200 && res.body.contains('[')) {
        vulns.add(
          Vulnerability(
            type: 'API Shadowing',
            url: '$base$path',
            severity: 'Low',
            description: 'Legacy API endpoint exposed: $path',
            category: 'Information Exposure',
            remediation: 'Deprecate or secure old API routes.',
          ),
        );
      }
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkCachePoisoning(String base) async {
    final vulns = <Vulnerability>[];
    final res = await _http
        .get(Uri.parse(base), headers: {'X-Forwarded-Host': 'evil.com'})
        .timeout(_timeout);
    if ((res.headers['cache-control'] ?? '').contains('public')) {
      vulns.add(
        Vulnerability(
          type: 'Cache Poisoning',
          url: base,
          severity: 'Medium',
          description: 'Untrusted headers used in cache key.',
          category: 'Cache',
          remediation: 'Vary on safe headers only.',
        ),
      );
    }
    return vulns;
  }

  static Future<List<Vulnerability>> _checkWebSocketIssues(String base) async {
    final vulns = <Vulnerability>[];
    try {
      final wsUrl = base.replaceFirst(RegExp(r'^http'), 'ws') + '/ws';
      final ws = await WebSocket.connect(wsUrl).timeout(_timeout);
      ws.add(json.encode({'action': 'ping'}));
      final msg = await ws.first.timeout(Duration(seconds: 3));
      if (msg.toString().contains('pong')) {
        // indicates open WebSocket without auth
        vulns.add(
          Vulnerability(
            type: 'WebSocket Open Endpoint',
            url: wsUrl,
            severity: 'Medium',
            description: 'WebSocket endpoint accessible without auth.',
            category: 'WebSocket',
            remediation: 'Require auth on WebSocket handshake.',
          ),
        );
      }
      await ws.close();
    } catch (_) {}
    return vulns;
  }
}
