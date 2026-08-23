import 'package:flutter/material.dart';

/// Category of form diagnostic events
enum FormEventCategory {
  stateChange,
  validation,
  asyncValidation,
  userAction,
  info,
}

/// A single entry in the form event log feed
class FormEventLogEntry {
  final DateTime timestamp;
  final String title;
  final String detail;
  final FormEventCategory category;
  final bool isError;

  FormEventLogEntry({
    DateTime? timestamp,
    required this.title,
    required this.detail,
    this.category = FormEventCategory.info,
    this.isError = false,
  }) : timestamp = timestamp ?? DateTime.now();

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

/// Scrollable live event log feed widget recording state transitions,
/// validation triggers, and async validation pipeline state changes.
class EventLogWidget extends StatefulWidget {
  final List<FormEventLogEntry> logs;
  final VoidCallback onClearLogs;
  final bool autoScroll;

  const EventLogWidget({
    super.key,
    required this.logs,
    required this.onClearLogs,
    this.autoScroll = true,
  });

  @override
  State<EventLogWidget> createState() => _EventLogWidgetState();
}

class _EventLogWidgetState extends State<EventLogWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant EventLogWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length > oldWidget.logs.length && widget.autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'Event Log (${widget.logs.length})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            IconButton(
              key: const Key('clear_event_log_button'),
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Clear Event Log',
              onPressed: widget.logs.isEmpty ? null : widget.onClearLogs,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: widget.logs.isEmpty
                ? Center(
                    child: Text(
                      'No events recorded yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const Key('event_log_list'),
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: widget.logs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final log = widget.logs[index];
                      return _buildLogTile(context, log, theme);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogTile(
    BuildContext context,
    FormEventLogEntry log,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    Color categoryColor;
    String categoryName;

    switch (log.category) {
      case FormEventCategory.stateChange:
        categoryColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
        categoryName = 'STATE';
        break;
      case FormEventCategory.validation:
        categoryColor = log.isError
            ? (isDark ? Colors.red.shade300 : Colors.red.shade700)
            : (isDark ? Colors.green.shade300 : Colors.green.shade700);
        categoryName = 'VALID';
        break;
      case FormEventCategory.asyncValidation:
        categoryColor = isDark ? Colors.purple.shade300 : Colors.purple.shade700;
        categoryName = 'ASYNC';
        break;
      case FormEventCategory.userAction:
        categoryColor = isDark ? Colors.amber.shade300 : Colors.amber.shade800;
        categoryName = 'ACTION';
        break;
      case FormEventCategory.info:
        categoryColor = theme.colorScheme.onSurface.withValues(alpha: 0.7);
        categoryName = 'INFO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: categoryColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  categoryName,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  log.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                log.formattedTime,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          if (log.detail.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              log.detail,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
