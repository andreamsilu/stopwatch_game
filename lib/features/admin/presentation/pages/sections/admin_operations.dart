part of '../admin_dashboard_page.dart';

class _DemoModulePanel extends StatelessWidget {
  const _DemoModulePanel({required this.section});

  final _AdminSection section;

  @override
  Widget build(BuildContext context) {
    final content = switch (section) {
      _AdminSection.users => const _UsersDemoPanel(),
      _AdminSection.billing => const _BillingDemoPanel(),
      _AdminSection.security => const _SecurityDemoPanel(),
      _ => const SizedBox.shrink(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [const _DemoBanner(), const SizedBox(height: 16), content],
    );
  }
}

class _UsersDemoPanel extends StatelessWidget {
  const _UsersDemoPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModuleMetricGrid(metrics: _AdminDemoData.userMetrics),
        SizedBox(height: 16),
        _Panel(
          title: 'User directory',
          subtitle: 'Sample accounts with dummy subscriber numbers',
          child: _AdminDataTable(
            columns: ['User', 'MSISDN', 'Channel', 'Status', 'Last access'],
            rows: [
              ['USR-1042', '255676589824', 'WEB', 'Active', '2 min ago'],
              ['USR-1038', '255754321091', 'WEB', 'Active', '6 min ago'],
              ['USR-1035', '255713456668', 'APP', 'Active', '12 min ago'],
              ['USR-1029', '255689123443', 'SMS', 'Review', '19 min ago'],
              ['USR-1017', '255622987705', 'WEB', 'Inactive', 'Yesterday'],
            ],
            statusColumn: 3,
          ),
        ),
        SizedBox(height: 16),
        _Panel(
          title: 'Registration activity',
          subtitle: 'Dummy sign-ups by channel today',
          child: _BreakdownList(
            items: [
              _DemoBreakdown('Web portal', 31, 0.66),
              _DemoBreakdown('Mobile app', 12, 0.26),
              _DemoBreakdown('SMS', 4, 0.08),
            ],
          ),
        ),
      ],
    );
  }
}

class _BillingDemoPanel extends StatelessWidget {
  const _BillingDemoPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModuleMetricGrid(metrics: _AdminDemoData.billingMetrics),
        SizedBox(height: 16),
        _Panel(
          title: 'Recent transactions',
          subtitle: 'Sample payment requests and provider responses',
          child: _AdminDataTable(
            columns: [
              'Request',
              'MSISDN',
              'Amount',
              'Provider',
              'Status',
              'Time',
            ],
            rows: [
              [
                'REQ-8F21',
                '255676589824',
                'TZS 1,000',
                'Yas',
                'Success',
                '11:26',
              ],
              [
                'REQ-8F20',
                '255754321091',
                'TZS 1,000',
                'M-Pesa',
                'Pending',
                '11:24',
              ],
              [
                'REQ-8F19',
                '255713456668',
                'TZS 2,000',
                'Airtel',
                'Success',
                '11:17',
              ],
              [
                'REQ-8F18',
                '255689123443',
                'TZS 1,000',
                'Yas',
                'Failed',
                '11:11',
              ],
              [
                'REQ-8F17',
                '255622987705',
                'TZS 1,000',
                'M-Pesa',
                'Success',
                '11:03',
              ],
            ],
            statusColumn: 4,
          ),
        ),
      ],
    );
  }
}

class _SecurityDemoPanel extends StatelessWidget {
  const _SecurityDemoPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModuleMetricGrid(metrics: _AdminDemoData.securityMetrics),
        SizedBox(height: 16),
        _Panel(
          title: 'Access and integrity events',
          subtitle: 'Sample security events with sensitive values masked',
          child: _AdminDataTable(
            columns: ['Time', 'Event', 'MSISDN', 'Session', 'Result'],
            rows: [
              [
                '11:29',
                'auth.otp_failed',
                '255689123443',
                'SES-91D2',
                'Review',
              ],
              [
                '11:22',
                'request.signature_invalid',
                '255754321091',
                'SES-80C4',
                'Blocked',
              ],
              [
                '11:16',
                'game.sequence_invalid',
                '255622987705',
                'SES-77A8',
                'Review',
              ],
              [
                '10:58',
                'auth.login_succeeded',
                '255676589824',
                'SES-63F1',
                'Success',
              ],
              [
                '10:47',
                'request.rate_limited',
                '255713456668',
                'SES-52B9',
                'Blocked',
              ],
            ],
            statusColumn: 4,
          ),
        ),
        SizedBox(height: 16),
        _Panel(
          title: 'Control status',
          subtitle: 'Dummy operational state of portal safeguards',
          child: _AdminDataTable(
            columns: ['Control', 'Coverage', 'Status'],
            rows: [
              ['Sensitive-field redaction', 'Requests and responses', 'Active'],
              ['HMAC request validation', 'Protected API routes', 'Active'],
              ['OTP attempt throttling', 'Authentication', 'Active'],
              ['Admin role enforcement', 'Demo route only', 'Pending'],
            ],
            statusColumn: 2,
          ),
        ),
      ],
    );
  }
}

class _ModuleMetricGrid extends StatelessWidget {
  const _ModuleMetricGrid({required this.metrics});

  final List<_DemoMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 2.8 : 2.05,
          ),
          itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
        );
      },
    );
  }
}

class _AdminDataTable extends StatefulWidget {
  const _AdminDataTable({
    required this.columns,
    required this.rows,
    this.statusColumn,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final int? statusColumn;

  @override
  State<_AdminDataTable> createState() => _AdminDataTableState();
}

class _AdminDataTableState extends State<_AdminDataTable> {
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final rows = [
      for (final row in widget.rows) [...row],
    ];
    if (_sortColumnIndex != null) {
      rows.sort((left, right) {
        final comparison = left[_sortColumnIndex!].compareTo(
          right[_sortColumnIndex!],
        );
        return _sortAscending ? comparison : -comparison;
      });
    }
    final desiredHeight = 58.0 + (rows.length * 56.0);
    final minWidth = widget.columns.length * 150.0;
    return SizedBox(
      height: desiredHeight > 390 ? 390 : desiredHeight,
      child: DataTable2(
        minWidth: minWidth < 620 ? 620 : minWidth,
        fixedLeftColumns: widget.columns.length > 2 ? 1 : 0,
        border: TableBorder.all(color: const Color(0xFF94A3B8)),
        headingRowColor: const WidgetStatePropertyAll(Color(0xFFE2E8F0)),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.w800),
        dividerThickness: 1,
        isHorizontalScrollBarVisible: true,
        isVerticalScrollBarVisible: rows.length > 5,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        sortArrowBuilder: _adminSortArrow,
        columnSpacing: 20,
        columnResizingParameters: ColumnResizingParameters(
          widgetColor: AppColors.primary,
        ),
        empty: const Center(child: Text('No records found.')),
        columns: [
          for (var index = 0; index < widget.columns.length; index++)
            DataColumn2(
              label: Text(widget.columns[index]),
              size: index == 0 ? ColumnSize.L : ColumnSize.M,
              onSort: (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
              },
            ),
        ],
        rows: [
          for (final row in rows)
            DataRow2(
              cells: [
                for (var index = 0; index < row.length; index++)
                  DataCell(
                    index == widget.statusColumn
                        ? _StatusChip(label: row[index])
                        : Text(row[index]),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _BreakdownList extends StatelessWidget {
  const _BreakdownList({required this.items});

  final List<_DemoBreakdown> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _FunnelRow(
            item: _DemoFunnelItem(
              items[index].label,
              items[index].count,
              items[index].rate,
            ),
          ),
          if (index != items.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
