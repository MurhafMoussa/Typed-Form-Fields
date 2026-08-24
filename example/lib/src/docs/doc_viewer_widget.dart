import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

import '../shell/app_routes.dart';
import 'doc_sidebar.dart';
import 'embedded_live_demo.dart';
import 'table_of_contents_widget.dart';

/// Represents a segment of a parsed documentation guide.
abstract class DocGuideSegment {
  const DocGuideSegment();
}

/// A plain markdown text segment.
class MarkdownTextSegment extends DocGuideSegment {
  final String content;
  const MarkdownTextSegment(this.content);
}

/// An embedded live interactive demo segment.
class LiveDemoSegment extends DocGuideSegment {
  final String demoId;
  const LiveDemoSegment(this.demoId);
}

/// Helper parser to split raw markdown content on `<live-demo id="..." />` tags.
class DocGuideParser {
  static final RegExp _demoTagRegex = RegExp(
    r'<live-demo\s+id=["'
    "'"
    r']([^"'
    "'"
    r']+)["'
    "'"
    r']\s*/?>',
    caseSensitive: false,
  );

  static List<DocGuideSegment> parse(String rawMarkdown) {
    final List<DocGuideSegment> segments = [];
    final matches = _demoTagRegex.allMatches(rawMarkdown);

    int currentOffset = 0;
    for (final match in matches) {
      if (match.start > currentOffset) {
        final textBefore = rawMarkdown.substring(currentOffset, match.start);
        if (textBefore.trim().isNotEmpty) {
          segments.add(MarkdownTextSegment(textBefore));
        }
      }

      final demoId = match.group(1);
      if (demoId != null && demoId.isNotEmpty) {
        segments.add(LiveDemoSegment(demoId));
      }

      currentOffset = match.end;
    }

    if (currentOffset < rawMarkdown.length) {
      final remainingText = rawMarkdown.substring(currentOffset);
      if (remainingText.trim().isNotEmpty) {
        segments.add(MarkdownTextSegment(remainingText));
      }
    }

    return segments;
  }
}

/// Custom Markdown element builder for code blocks with language banner & Copy button.
class ShadcnCodeBlockBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  ShadcnCodeBlockBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Only handle multi-line code blocks or formatted code elements
    final code = element.textContent;
    if (!code.contains('\n') && code.length < 40) {
      // Inline code fallback handled by MarkdownStyleSheet
      return null;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Code Block Top Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.code, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                const Text(
                  'CODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                InkWell(
                  key: const Key('copy_code_button'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.copy_rounded,
                          size: 12,
                          color: Color(0xDDFFFFFF),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xDDFFFFFF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Code Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.4,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive Embedded Documentation Hub viewer component.
class DocViewerWidget extends StatefulWidget {
  final String docRoute;
  final Locale locale;
  final ValueChanged<String> onNavigate;

  const DocViewerWidget({
    super.key,
    required this.docRoute,
    required this.locale,
    required this.onNavigate,
  });

  @override
  State<DocViewerWidget> createState() => _DocViewerWidgetState();
}

class _DocViewerWidgetState extends State<DocViewerWidget> {
  final ScrollController _scrollController = ScrollController();
  String? _rawMarkdown;
  bool _isLoading = true;
  String? _errorMessage;
  List<TocItem> _tocItems = [];
  String? _activeAnchorId;

  static const double desktopBreakpoint = 1000.0;

  @override
  void initState() {
    super.initState();
    _loadDocumentContent();
  }

  @override
  void didUpdateWidget(DocViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.docRoute != widget.docRoute ||
        oldWidget.locale != widget.locale) {
      _loadDocumentContent();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getTopicFileName(String route) {
    switch (route) {
      case AppRoutes.docsGettingStarted:
        return 'getting_started.md';
      case AppRoutes.docsCoreConcepts:
        return 'core_concepts.md';
      case AppRoutes.docsValidationStrategies:
        return 'validation_strategies.md';
      case AppRoutes.docsAsyncValidation:
        return 'async_validation.md';
      case AppRoutes.docsFieldGrouping:
        return 'field_grouping.md';
      case AppRoutes.docsDynamicFormManagement:
        return 'dynamic_form_management.md';
      default:
        return 'getting_started.md';
    }
  }

  Future<void> _loadDocumentContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fileName = _getTopicFileName(widget.docRoute);
    final langCode = widget.locale.languageCode;
    final primaryAssetPath = 'assets/docs/$langCode/$fileName';
    final fallbackAssetPath = 'assets/docs/en/$fileName';

    String? content;

    try {
      content = await rootBundle.loadString(primaryAssetPath);
    } catch (_) {
      try {
        content = await rootBundle.loadString(fallbackAssetPath);
      } catch (e) {
        _errorMessage = 'Failed to load document: $fileName ($e)';
      }
    }

    if (mounted) {
      setState(() {
        _rawMarkdown = content;
        _tocItems = content != null ? TocItem.extractFromMarkdown(content) : [];
        _activeAnchorId = _tocItems.isNotEmpty
            ? _tocItems.first.anchorId
            : null;
        _isLoading = false;
      });
    }
  }

  void _scrollToAnchor(TocItem item) {
    setState(() {
      _activeAnchorId = item.anchorId;
    });
    // Scroll smoothly when TOC item is tapped
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= desktopBreakpoint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Sticky Sidebar (Desktop Viewports)
        if (isDesktop)
          DocSidebar(
            currentRoute: widget.docRoute,
            onSelectRoute: widget.onNavigate,
          ),

        // Main Document Content Body
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : _buildMarkdownContent(context),
        ),

        // Right Table of Contents (Desktop Viewports)
        if (isDesktop && _tocItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableOfContentsWidget(
              items: _tocItems,
              activeAnchorId: _activeAnchorId,
              onItemTap: _scrollToAnchor,
            ),
          ),
      ],
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    final theme = Theme.of(context);
    final segments = DocGuideParser.parse(_rawMarkdown ?? '');

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mobile Guide Selector Header (When not desktop)
              if (MediaQuery.of(context).size.width < desktopBreakpoint)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: widget.docRoute,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      items: docGuideSections.map((sec) {
                        return DropdownMenuItem<String>(
                          value: sec.route,
                          child: Text(
                            sec.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        );
                      }).toList(),
                      onChanged: (route) {
                        if (route != null) {
                          widget.onNavigate(route);
                        }
                      },
                    ),
                  ),
                ),

              // Render Document Segments
              ...segments.map((segment) {
                if (segment is LiveDemoSegment) {
                  return EmbeddedLiveDemo(demoId: segment.demoId);
                } else if (segment is MarkdownTextSegment) {
                  return MarkdownBody(
                    data: segment.content,
                    selectable: true,
                    builders: {'code': ShadcnCodeBlockBuilder(context)},
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.onSurface,
                      ),
                      h1: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                      h2: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                      h3: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      code: TextStyle(
                        backgroundColor: theme.colorScheme.secondary,
                        color: theme.colorScheme.primary,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
