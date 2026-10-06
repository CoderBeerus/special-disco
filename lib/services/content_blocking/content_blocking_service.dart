import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

enum BlockingMode { strict, standard, disabled }

class ContentBlockingService {
  ContentBlockingService();

  final Set<String> _blockedDomains = {};
  final Set<String> _allowlist = {};

  Future<void> initialize() async {
    if (_blockedDomains.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/blocklists/easylist_sample.txt');
    final lines = const LineSplitter().convert(raw);
    for (final line in lines) {
      if (line.startsWith('||') && line.endsWith('^')) {
        _blockedDomains.add(line.substring(2, line.length - 1));
      }
    }
  }

  void setAllowlist(Iterable<String> domains) {
    _allowlist
      ..clear()
      ..addAll(domains.map((e) => e.toLowerCase()));
  }

  bool isBlocked(Uri? uri, BlockingMode mode) {
    if (mode == BlockingMode.disabled || uri == null) return false;
    final host = uri.host.toLowerCase();
    if (_allowlist.contains(host)) return false;
    if (_blockedDomains.contains(host)) return true;
    if (mode == BlockingMode.strict) {
      return _blockedDomains.any((domain) => host.endsWith('.$domain'));
    }
    return false;
  }

  Future<NavigationActionPolicy> shouldAllowRequest(
    NavigationAction action,
    BlockingMode mode,
  ) async {
    final uri = action.request.url;
    return isBlocked(uri, mode)
        ? NavigationActionPolicy.CANCEL
        : NavigationActionPolicy.ALLOW;
  }
}
