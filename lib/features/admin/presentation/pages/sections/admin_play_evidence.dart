part of '../admin_dashboard_page.dart';

class _PlayEvidenceDemoPanel extends StatefulWidget {
  const _PlayEvidenceDemoPanel();

  @override
  State<_PlayEvidenceDemoPanel> createState() => _PlayEvidenceDemoPanelState();
}

class _PlayEvidenceDemoPanelState extends State<_PlayEvidenceDemoPanel> {
  String _query = '';

  List<_DemoEvidenceRecord> get _filteredRecords {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _evidenceRecords;
    return _evidenceRecords
        .where((record) => record.searchText.contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DemoBanner(),
        const SizedBox(height: 16),
        _Panel(
          title: 'Play-access evidence register',
          subtitle:
              'One dummy record per portal play access or SMS MO, including attempts that were never charged',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Autocomplete<_DemoEvidenceRecord>(
                displayStringForOption: (record) => record.evidenceId,
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return _evidenceRecords;
                  return _evidenceRecords.where(
                    (record) => record.searchText.contains(query),
                  );
                },
                onSelected: (record) {
                  setState(() => _query = record.evidenceId);
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) => setState(() => _query = value),
                        onSubmitted: (_) => onFieldSubmitted(),
                        decoration: InputDecoration(
                          labelText: 'Search evidence',
                          hintText:
                              'Evidence ID, MSISDN, access time, MO, transaction or session',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    controller.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          border: const OutlineInputBorder(),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 12),
              Text(
                '${records.length} evidence record${records.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              if (records.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No matching evidence records.')),
                )
              else
                _EvidenceRegisterTable(records: records, onView: _showEvidence),
            ],
          ),
        ),
      ],
    );
  }

  void _showEvidence(_DemoEvidenceRecord record) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Evidence · ${record.evidenceId}'),
        content: SizedBox(
          width: 900,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AdminDataTable(
                  columns: const ['Field', 'Value'],
                  rows: [
                    ['MSISDN', record.msisdn],
                    ['Channel', record.channel],
                    ['Access time', record.accessAt],
                    ['Access / MO evidence', record.accessEvidence],
                    ['Amount', record.amount],
                    ['Provider transaction', record.providerTransaction],
                    ['Game session', record.gameSession],
                    ['Played duration', record.played],
                    ['Verdict', record.verdict],
                  ],
                ),
                const Divider(height: 32),
                Text(
                  'Evidence chain',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _AdminDataTable(
                  columns: const [
                    'UTC time',
                    'Source',
                    'Evidence',
                    'Reference',
                    'Result',
                  ],
                  rows: record.timeline,
                  statusColumn: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EvidenceRegisterTable extends StatefulWidget {
  const _EvidenceRegisterTable({required this.records, required this.onView});

  final List<_DemoEvidenceRecord> records;
  final ValueChanged<_DemoEvidenceRecord> onView;

  @override
  State<_EvidenceRegisterTable> createState() => _EvidenceRegisterTableState();
}

class _EvidenceRegisterTableState extends State<_EvidenceRegisterTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final records = [...widget.records];
    if (_sortColumnIndex != null) {
      records.sort((left, right) {
        final comparison = _sortValue(
          left,
          _sortColumnIndex!,
        ).compareTo(_sortValue(right, _sortColumnIndex!));
        return _sortAscending ? comparison : -comparison;
      });
    }
    final desiredHeight = 58.0 + (records.length * 56.0);
    return SizedBox(
      height: desiredHeight > 390 ? 390 : desiredHeight,
      child: DataTable2(
        minWidth: 720,
        fixedLeftColumns: 1,
        border: TableBorder.all(color: const Color(0xFF94A3B8)),
        headingRowColor: const WidgetStatePropertyAll(Color(0xFFE2E8F0)),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w800),
        dividerThickness: 1,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: records.length > 5,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        sortArrowBuilder: _adminSortArrow,
        columnSpacing: 12,
        columnResizingParameters: ColumnResizingParameters(
          widgetColor: AppColors.primary,
        ),
        columns: [
          _sortableColumn('Evidence ID', 0, size: ColumnSize.L),
          _sortableColumn('MSISDN', 1, size: ColumnSize.L),
          _sortableColumn('Access time', 2),
          _sortableColumn('Verdict', 3),
          const DataColumn2(label: Text('Action'), size: ColumnSize.S),
        ],
        rows: [
          for (final record in records)
            DataRow2(
              onTap: () => widget.onView(record),
              cells: [
                DataCell(Text(record.evidenceId)),
                DataCell(Text(record.msisdn)),
                DataCell(Text(record.accessAt)),
                DataCell(_StatusChip(label: record.verdict)),
                DataCell(
                  _GridActionButton(
                    onPressed: () => widget.onView(record),
                    tooltip: 'View evidence',
                    icon: const Icon(Icons.visibility_outlined, size: 20),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  DataColumn2 _sortableColumn(
    String label,
    int index, {
    ColumnSize size = ColumnSize.M,
  }) {
    return DataColumn2(
      label: Text(label),
      size: size,
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _sortAscending = ascending;
        });
      },
    );
  }

  static String _sortValue(_DemoEvidenceRecord record, int index) {
    return switch (index) {
      0 => record.evidenceId,
      1 => record.msisdn,
      2 => record.accessAt,
      3 => record.verdict,
      _ => '',
    };
  }
}

class _GridActionButton extends StatelessWidget {
  const _GridActionButton({
    required this.onPressed,
    required this.tooltip,
    required this.icon,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF94A3B8)),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        padding: EdgeInsets.zero,
        icon: icon,
      ),
    );
  }
}

class _DemoEvidenceRecord {
  const _DemoEvidenceRecord({
    required this.evidenceId,
    required this.msisdn,
    required this.channel,
    required this.accessAt,
    required this.accessEvidence,
    required this.amount,
    required this.providerTransaction,
    required this.gameSession,
    required this.played,
    required this.verdict,
    required this.timeline,
  });

  final String evidenceId;
  final String msisdn;
  final String channel;
  final String accessAt;
  final String accessEvidence;
  final String amount;
  final String providerTransaction;
  final String gameSession;
  final String played;
  final String verdict;
  final List<List<String>> timeline;

  String get searchText =>
      '$evidenceId $msisdn $channel $accessAt $accessEvidence $providerTransaction '
              '$gameSession $verdict'
          .toLowerCase();
}

const _evidenceRecords = <_DemoEvidenceRecord>[
  _DemoEvidenceRecord(
    evidenceId: 'EVD-260814-1042',
    msisdn: '255676589824',
    channel: 'SMS',
    accessAt: '10:58:12',
    accessEvidence: 'MO-7B29F1 · 10:58:12',
    amount: 'TZS 1,000',
    providerTransaction: 'YAS-93F8A1',
    gameSession: 'SES-63F1',
    played: '00:05.014',
    verdict: 'Verified',
    timeline: [
      [
        '07:58:12.041',
        'SMS gateway',
        'MO received: PLAY',
        'MO-7B29F1',
        'Recorded',
      ],
      [
        '07:58:12.203',
        'Payment callback',
        'TZS 1,000 confirmed',
        'YAS-93F8A1',
        'Success',
      ],
      [
        '07:58:12.311',
        'Game service',
        'Session linked to MO and charge',
        'SES-63F1',
        'Success',
      ],
      [
        '07:58:13.008',
        'SMS game handler',
        'MO command accepted as play',
        'RND-8804',
        'Recorded',
      ],
      [
        '07:58:36.022',
        'Game service',
        'Round stopped at 00:05.014',
        'RND-8804',
        'Completed',
      ],
    ],
  ),
  _DemoEvidenceRecord(
    evidenceId: 'EVD-260814-1038',
    msisdn: '255754321091',
    channel: 'WEB',
    accessAt: '10:42:09',
    accessEvidence: 'Portal · 10:42:09',
    amount: 'TZS 1,000',
    providerTransaction: 'MP-71C204',
    gameSession: 'SES-58D4',
    played: '00:04.982',
    verdict: 'Verified',
    timeline: [
      [
        '07:42:09.104',
        'API gateway',
        'Portal accessed',
        'REQ-22B1',
        'Recorded',
      ],
      [
        '07:42:17.220',
        'Payment callback',
        'TZS 1,000 confirmed',
        'MP-71C204',
        'Success',
      ],
      [
        '07:42:17.409',
        'Game service',
        'Session allocated',
        'SES-58D4',
        'Success',
      ],
      [
        '07:42:29.801',
        'Game service',
        'Round stopped at 00:04.982',
        'RND-7712',
        'Completed',
      ],
    ],
  ),
  _DemoEvidenceRecord(
    evidenceId: 'EVD-260814-1029',
    msisdn: '255689123443',
    channel: 'SMS',
    accessAt: '10:31:44',
    accessEvidence: 'MO-6C18A0 · 10:31:44',
    amount: 'TZS 1,000',
    providerTransaction: 'YAS-62A119',
    gameSession: 'Not created',
    played: 'No',
    verdict: 'Refund due',
    timeline: [
      [
        '07:31:44.012',
        'SMS gateway',
        'MO received: PLAY',
        'MO-6C18A0',
        'Recorded',
      ],
      [
        '07:31:44.281',
        'Payment callback',
        'TZS 1,000 confirmed',
        'YAS-62A119',
        'Success',
      ],
      [
        '07:31:45.002',
        'Game service',
        'Session allocation failed',
        'REQ-19D7',
        'Failed',
      ],
    ],
  ),
  _DemoEvidenceRecord(
    evidenceId: 'EVD-260814-1017',
    msisdn: '255622987705',
    channel: 'WEB',
    accessAt: '10:18:27',
    accessEvidence: 'Portal · 10:18:27',
    amount: 'Not charged',
    providerTransaction: 'Declined',
    gameSession: 'Not created',
    played: 'No',
    verdict: 'No charge',
    timeline: [
      [
        '07:18:27.813',
        'API gateway',
        'Portal accessed',
        'REQ-11C2',
        'Recorded',
      ],
      [
        '07:18:35.120',
        'Payment provider',
        'Charge declined',
        'REQ-11C2',
        'Failed',
      ],
    ],
  ),
  _DemoEvidenceRecord(
    evidenceId: 'EVD-260814-1008',
    msisdn: '255765111332',
    channel: 'WEB',
    accessAt: '10:06:51',
    accessEvidence: 'Portal session · PS-40A2',
    amount: 'Not requested',
    providerTransaction: 'Not created',
    gameSession: 'Not created',
    played: 'No',
    verdict: 'Accessed',
    timeline: [
      [
        '07:06:51.118',
        'API gateway',
        'Portal play page accessed',
        'PS-40A2',
        'Recorded',
      ],
    ],
  ),
];
