import 'package:aniweb/core/utils/url_validator.dart';
import 'package:aniweb/services/content_blocking/content_blocking_service.dart';
import 'package:aniweb/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key, this.initialUrl});

  final String? initialUrl;

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  late final TextEditingController _urlController;
  InAppWebViewController? _webViewController;
  late final ContentBlockingService _blockingService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? 'https://www.google.com');
    _blockingService = ContentBlockingService()..initialize();
  }

  @override
  void didUpdateWidget(BrowserScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialUrl != oldWidget.initialUrl && widget.initialUrl != null) {
      _loadUrl(widget.initialUrl!);
      _urlController.text = widget.initialUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final mode = !settings.contentBlockingEnabled
        ? BlockingMode.disabled
        : settings.strictContentBlocking
            ? BlockingMode.strict
            : BlockingMode.standard;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.go,
          onSubmitted: _loadUrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            hintText: 'Search or enter URL',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: () async {
              if (_webViewController == null) return;
              final urlStr = _urlController.text.trim();
              if (urlStr.isEmpty) return;

              final uri = Uri.tryParse(urlStr);
              if (uri == null) return;

              final title = await _webViewController!.getTitle() ?? uri.host;

              try {
                final repo = ref.read(bookmarkRepositoryProvider);
                await repo.addBookmarkWithAutoGroup(
                  title: title,
                  url: urlStr,
                  domain: uri.host,
                );
                // Refresh bookmarks
                ref.read(bookmarkGroupsProvider.notifier).refresh();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookmark added')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add bookmark: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final url = Uri.tryParse(_urlController.text.trim());
              if (url != null) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_urlController.text)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              useShouldOverrideUrlLoading: true,
              useOnDownloadStart: true,
            ),
            onWebViewCreated: (controller) => _webViewController = controller,
            shouldOverrideUrlLoading: (controller, action) =>
                _blockingService.shouldAllowRequest(action, mode),
            onLoadStart: (_, uri) {
              if (uri != null) _urlController.text = uri.toString();
              setState(() => _isLoading = true);
            },
            onLoadStop: (_, __) => setState(() => _isLoading = false),
            onDownloadStartRequest: (_, req) {
              final media = ref.read(mediaDetectionServiceProvider).detect(
                    resourceUrl: req.url.toString(),
                    pageUrl: _urlController.text,
                    title: req.suggestedFilename ?? 'Detected media',
                  );
              if (media != null) {
                final list = [...ref.read(detectedMediaProvider)];
                list.insert(0, media);
                ref.read(detectedMediaProvider.notifier).state = list;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Media detected'),
                      action: SnackBarAction(
                        label: 'Download',
                        onPressed: () => ref
                            .read(downloadsProvider.notifier)
                            .enqueue(media.url, media.title),
                      ),
                    ),
                  );
                }
              }
            },
          ),
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
      bottomNavigationBar: _BottomBar(controller: _webViewController),
    );
  }

  void _loadUrl(String value) {
    var query = value.trim();
    if (!UrlValidator.isAllowedWebUrl(query)) {
      query = 'https://www.google.com/search?q=${Uri.encodeQueryComponent(query)}';
    }
    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(query)));
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.controller});

  final InAppWebViewController? controller;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller?.goBack(),
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () => controller?.goForward(),
            icon: const Icon(Icons.arrow_forward),
          ),
          IconButton(
            onPressed: () => controller?.reload(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => controller?.stopLoading(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
