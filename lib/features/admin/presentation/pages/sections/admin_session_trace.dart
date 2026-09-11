part of '../admin_dashboard_page.dart';

class _SessionTracePanel extends StatelessWidget {
  const _SessionTracePanel({required this.store});

  final ApiSessionTraceStore store;

  @override
  Widget build(BuildContext context) {
    final records = store.records;
    final apiCount = records
        .where((record) => record.kind == SessionTraceKind.api)
        .length;
    final eventCount = records.length - apiCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DemoBanner(),
        const SizedBox(height: 16),
        _Panel(
          title: 'Current browser session',
          subtitle: 'Cleared automatically when this Flutter app is reloaded',
          child: Wrap(
            spacing: 18,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _TraceSummary(label: 'Session', value: _shortId(store.sessionId)),
              _TraceSummary(
                label: 'MSISDN',
                value: store.maskedMsisdn ?? 'Not observed',
              ),
              _TraceSummary(label: 'API calls', value: '$apiCount'),
              _TraceSummary(label: 'Events', value: '$eventCount'),
              OutlinedButton.icon(
                onPressed: store.addDemoRecords,
                icon: const Icon(Icons.science_outlined),
                label: const Text('Add demo trace'),
              ),
              TextButton.icon(
                onPressed: records.isEmpty ? null : store.clear,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          title: 'Requests, responses and events',
          subtitle:
              'Newest first · OTPs, tokens, signatures and full phone numbers are never shown',
          child: records.isEmpty
              ? const _EmptyTrace()
              : _SessionTraceDataTable(records: records),
        ),
      ],
    );
  }

  static String _shortId(String value) {
    if (value.length <= 12) return value;
    return '${value.substring(0, 8)}…${value.substring(value.length - 4)}';
  }
}

class _TraceSummary extends StatelessWidget {
  const _TraceSummary({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 112),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EmptyTrace extends StatelessWidget {
  const _EmptyTrace();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        children: [
          Icon(Icons.timeline_rounded, size: 34, color: AppColors.secondary),
          SizedBox(height: 10),
          Text(
            'No activity captured in this browser session.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Use the player portal in this tab or add a demo trace.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SessionTraceDataTable extends StatelessWidget {
  const _SessionTraceDataTable({required this.records});

  final List<SessionTraceRecord> records;

  @override
  Widget build(BuildContext context) {
    final desiredHeight = 58.0 + (records.length * 96.0);
    return SizedBox(
      height: desiredHeight > 520 ? 520 : desiredHeight,
      child: DataTable2(
        minWidth: 1700,
        fixedLeftColumns: 2,
        border: TableBorder.all(color: const Color(0xFF94A3B8)),
        headingRowColor: const WidgetStatePropertyAll(Color(0xFFE2E8F0)),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w800),
        dividerThickness: 1,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: records.length > 4,
        columnSpacing: 24,
        dataRowHeight: 96,
        columnResizingParameters: ColumnResizingParameters(
          widgetColor: AppColors.primary,
        ),
        columns: const [
          DataColumn2(label: Text('Time'), size: ColumnSize.S),
          DataColumn2(label: Text('Type'), size: ColumnSize.S),
          DataColumn2(label: Text('Event / method')),
          DataColumn2(label: Text('Endpoint'), size: ColumnSize.L),
          DataColumn2(label: Text('MSISDN')),
          DataColumn2(label: Text('Status'), size: ColumnSize.S),
          DataColumn2(label: Text('Duration'), size: ColumnSize.S),
          DataColumn2(label: Text('Request / properties'), size: ColumnSize.L),
          DataColumn2(label: Text('Response / error'), size: ColumnSize.L),
        ],
        rows: [for (final record in records) _row(record)],
      ),
    );
  }

  static DataRow _row(SessionTraceRecord record) {
    final isEvent = record.kind == SessionTraceKind.event;
    final result = isEvent
        ? 'Event'
        : record.error != null
        ? 'Failed'
        : '${record.statusCode ?? 'Pending'}';
    final response = record.error ?? _pretty(record.response);

    return DataRow(
      cells: [
        DataCell(Text(_formatTime(record.occurredAt))),
        DataCell(_StatusChip(label: isEvent ? 'Event' : 'API')),
        DataCell(Text(isEvent ? record.label : record.method ?? 'API')),
        DataCell(Text(record.path ?? 'Client event')),
        DataCell(Text(record.maskedMsisdn ?? 'Not observed')),
        DataCell(
          Text(
            result,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: record.succeeded
                  ? const Color(0xFF15803D)
                  : record.error != null
                  ? const Color(0xFFB91C1C)
                  : const Color(0xFFB45309),
            ),
          ),
        ),
        DataCell(
          Text(record.durationMs == null ? '—' : '${record.durationMs} ms'),
        ),
        DataCell(_TracePayloadCell(value: _pretty(record.request))),
        DataCell(_TracePayloadCell(value: response)),
      ],
    );
  }

  static String _formatTime(DateTime value) =>
      value.toLocal().toIso8601String().split('T').last.split('.').first;

  static String _pretty(Object? value) {
    if (value == null) return '—';
    if (value is String) return value;
    return jsonEncode(value);
  }
}

class _TracePayloadCell extends StatelessWidget {
  const _TracePayloadCell({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: value,
      child: SizedBox(
        width: 240,
        child: SelectableText(
          value,
          maxLines: 4,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
