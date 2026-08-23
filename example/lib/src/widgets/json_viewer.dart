import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Syntax-highlighted, formatted JSON tree viewer widget for form state diagnostics.
class JsonViewer extends StatefulWidget {
  final Map<String, dynamic> jsonMap;
  final String? title;

  const JsonViewer({
    super.key,
    required this.jsonMap,
    this.title = 'TypedFormState',
  });

  @override
  State<JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<JsonViewer> {
  bool _copied = false;
  Timer? _copyTimer;

  @override
  void dispose() {
    _copyTimer?.cancel();
    super.dispose();
  }

  String get _formattedJson {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(widget.jsonMap);
    } catch (_) {
      return widget.jsonMap.toString();
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _formattedJson));
    _copyTimer?.cancel();
    setState(() {
      _copied = true;
    });
    _copyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.title != null)
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.code_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.title!,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextButton.icon(
              key: const Key('copy_json_button'),
              onPressed: _copyToClipboard,
              icon: Icon(
                _copied ? Icons.check : Icons.copy,
                size: 14,
              ),
              label: Text(
                _copied ? 'Copied' : 'Copy JSON',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            key: const Key('json_viewer'),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: SingleChildScrollView(
              child: SelectableText.rich(
                _buildSyntaxHighlightedSpans(_formattedJson, isDark),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _buildSyntaxHighlightedSpans(String code, bool isDark) {
    final spans = <TextSpan>[];

    // Colors matching dark/light mode JSON syntax highlighting
    final keyColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7); // Cyan / Blue
    final stringColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A); // Green
    final numberColor = isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C); // Orange
    final boolColor = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA); // Purple
    final nullColor = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626); // Red
    final punctuationColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B); // Slate

    final regex = RegExp(
      r'("(?:\\.|[^"\\])*")(?=\s*:)|' // Key
      r'("(?:\\.|[^"\\])*")|' // String
      r'\b(true|false)\b|' // Bool
      r'\b(null)\b|' // Null
      r'(-?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)|' // Number
      r'([\{\}\[\]\,\:])', // Punctuation
    );

    int lastMatchEnd = 0;

    for (final match in regex.allMatches(code)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: code.substring(lastMatchEnd, match.start),
          style: TextStyle(color: punctuationColor),
        ));
      }

      final matchedText = match.group(0)!;

      if (match.group(1) != null) {
        // Key
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: keyColor, fontWeight: FontWeight.w600),
        ));
      } else if (match.group(2) != null) {
        // String
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: stringColor),
        ));
      } else if (match.group(3) != null) {
        // Bool
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: boolColor, fontWeight: FontWeight.bold),
        ));
      } else if (match.group(4) != null) {
        // Null
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: nullColor, fontStyle: FontStyle.italic),
        ));
      } else if (match.group(5) != null) {
        // Number
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: numberColor),
        ));
      } else {
        // Punctuation
        spans.add(TextSpan(
          text: matchedText,
          style: TextStyle(color: punctuationColor),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < code.length) {
      spans.add(TextSpan(
        text: code.substring(lastMatchEnd),
        style: TextStyle(color: punctuationColor),
      ));
    }

    return TextSpan(children: spans);
  }
}
