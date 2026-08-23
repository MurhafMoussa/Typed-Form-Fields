import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typed_form_fields/typed_form_fields.dart';

import 'diagnostic_actions.dart';
import 'event_log_widget.dart';
import 'json_viewer.dart';
import 'showcase_card.dart';
import 'validation_strategy_selector.dart';

/// Reusable dual-pane and inspector component providing real-time JSON state inspection,
/// dynamic strategy switching, diagnostic action triggers, and live event logging.
class InspectorPanel extends StatefulWidget {
  final TypedFormController controller;
  final Widget? child;
  final String? groupName;
  final double desktopBreakpoint;

  const InspectorPanel({
    super.key,
    required this.controller,
    this.child,
    this.groupName,
    this.desktopBreakpoint = 768.0,
  });

  @override
  State<InspectorPanel> createState() => _InspectorPanelState();
}

class _InspectorPanelState extends State<InspectorPanel> {
  final List<FormEventLogEntry> _eventLogs = [];

  @override
  void initState() {
    super.initState();
    _logEvent(
      FormEventLogEntry(
        title: 'Form Initialized',
        detail: 'Strategy: ${widget.controller.state.validationStrategy.name}',
        category: FormEventCategory.info,
      ),
    );
  }

  void _logEvent(FormEventLogEntry entry) {
    if (mounted) {
      setState(() {
        _eventLogs.add(entry);
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _eventLogs.clear();
    });
  }

  Map<String, dynamic> _buildFormStateJson(TypedFormState state) {
    return {
      'values': state.values,
      'errors': state.errors,
      'touched': widget.controller.touchedFields,
      'isDirty': widget.controller.isDirty,
      'isValid': state.isValid,
      'validatingFields': state.validatingFields.toList(),
      'isValidating': state.isValidating,
      'validationStrategy': state.validationStrategy.name,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TypedFormController, TypedFormState>(
      bloc: widget.controller,
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        final previous = widget.controller.state;
        if (previous.validationStrategy != state.validationStrategy) {
          _logEvent(
            FormEventLogEntry(
              title: 'Strategy Changed',
              detail: 'Switched to ${state.validationStrategy.name}',
              category: FormEventCategory.stateChange,
            ),
          );
        } else if (previous.validatingFields != state.validatingFields) {
          _logEvent(
            FormEventLogEntry(
              title: 'Async Validation Pipeline',
              detail: 'Validating fields: ${state.validatingFields.toList()}',
              category: FormEventCategory.asyncValidation,
            ),
          );
        } else {
          _logEvent(
            FormEventLogEntry(
              title: 'Form State Updated',
              detail: 'isValid: ${state.isValid}, errors: ${state.errors.length}',
              category: FormEventCategory.stateChange,
            ),
          );
        }
      },
      child: BlocBuilder<TypedFormController, TypedFormState>(
        bloc: widget.controller,
        builder: (context, state) {
          final isDesktop = MediaQuery.of(context).size.width >= widget.desktopBreakpoint;

          if (widget.child == null) {
            return Container(
              key: const Key('inspector_panel'),
              child: _buildInspectorCard(context, state),
            );
          }

          if (isDesktop) {
            return Container(
              key: const Key('inspector_panel'),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: widget.child!,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 700,
                      child: _buildInspectorCard(context, state),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              key: const Key('inspector_panel'),
              child: DefaultTabController(
                length: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(key: Key('tab_preview'), text: 'Form Preview'),
                        Tab(key: Key('tab_json_state'), text: 'State JSON'),
                        Tab(key: Key('tab_event_log'), text: 'Event Log'),
                        Tab(key: Key('tab_diagnostics'), text: 'Diagnostics'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 550,
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(child: widget.child!),
                          ShowcaseCard(
                            child: SingleChildScrollView(
                              child: JsonViewer(
                                jsonMap: _buildFormStateJson(state),
                              ),
                            ),
                          ),
                          ShowcaseCard(
                            child: SingleChildScrollView(
                              child: EventLogWidget(
                                logs: _eventLogs,
                                onClearLogs: _clearLogs,
                              ),
                            ),
                          ),
                          ShowcaseCard(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ValidationStrategySelector(
                                    currentStrategy: state.validationStrategy,
                                    onStrategyChanged: (newStrategy) {
                                      widget.controller.setValidationStrategy(newStrategy);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  DiagnosticActions(
                                    controller: widget.controller,
                                    groupName: widget.groupName,
                                    onEventLogged: _logEvent,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInspectorCard(BuildContext context, TypedFormState state) {
    return ShowcaseCard(
      title: 'Live State Inspector',
      description: 'Real-time state tree, validation strategy, and event log.',
      headerLeading: const Icon(Icons.bug_report_outlined, size: 18),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(key: Key('tab_json_state'), text: 'State JSON'),
                Tab(key: Key('tab_event_log'), text: 'Event Log'),
                Tab(key: Key('tab_diagnostics'), text: 'Actions & Strategy'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 420,
              child: TabBarView(
                children: [
                  JsonViewer(
                    jsonMap: _buildFormStateJson(state),
                  ),
                  EventLogWidget(
                    logs: _eventLogs,
                    onClearLogs: _clearLogs,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValidationStrategySelector(
                          currentStrategy: state.validationStrategy,
                          onStrategyChanged: (newStrategy) {
                            widget.controller.setValidationStrategy(newStrategy);
                          },
                        ),
                        const SizedBox(height: 16),
                        DiagnosticActions(
                          controller: widget.controller,
                          groupName: widget.groupName,
                          onEventLogged: _logEvent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
