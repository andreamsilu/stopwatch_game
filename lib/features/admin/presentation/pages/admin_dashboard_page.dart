import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/services/api_session_trace_store.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';

/// Temporary administration dashboard backed by clearly labelled demo data.
///
/// Replace [_AdminDemoData] with authenticated admin API providers before
/// production. The `/admin` route is intentionally open during this phase.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _traceStore = ApiSessionTraceStore.instance;
  _AdminSection _section = _AdminSection.overview;

  @override
  void initState() {
    super.initState();
    if (_traceStore.records.isEmpty) {
      _traceStore.addDemoRecords();
    }
    _traceStore.addListener(_refresh);
  }

  @override
  void dispose() {
    _traceStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _selectSection(_AdminSection section) {
    setState(() => _section = section);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: _AdminSidebar(selected: _section, onSelected: _selectSection),
        ),
      ),
      body: ExperienceBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final workspace = Column(
                children: [
                  _AdminHeader(
                    section: _section,
                    onOpenMenu: compact
                        ? () => _scaffoldKey.currentState?.openDrawer()
                        : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: _buildSection(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
              if (compact) return workspace;
              return Row(
                children: [
                  SizedBox(
                    width: 248,
                    child: _AdminSidebar(
                      selected: _section,
                      onSelected: _selectSection,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: workspace),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSection() {
    switch (_section) {
      case _AdminSection.overview:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DemoBanner(),
            SizedBox(height: 16),
            _SummaryGrid(),
            SizedBox(height: 16),
            _AdminDetailGrid(),
          ],
        );
      case _AdminSection.sessions:
        return _SessionTracePanel(store: _traceStore);
      case _AdminSection.users:
      case _AdminSection.billing:
      case _AdminSection.security:
        return _DemoModulePanel(section: _section);
    }
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.section, this.onOpenMenu});

  final _AdminSection section;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final isCompact = onOpenMenu != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  if (onOpenMenu != null) ...[
                    IconButton(
                      onPressed: onOpenMenu,
                      tooltip: 'Open admin navigation',
                      icon: const Icon(Icons.menu_rounded),
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (!isCompact) ...[
                    const AppLogo(size: 36),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.label,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Admin Console · Demo mode',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.onBackground.withValues(
                                  alpha: 0.65,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompact)
                    IconButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (_) => false),
                      tooltip: 'Player portal',
                      icon: const Icon(Icons.open_in_new_rounded),
                    )
                  else
                    TextButton.icon(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (_) => false),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Player portal'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _AdminSection { overview, sessions, users, billing, security }

extension on _AdminSection {
  String get label {
    switch (this) {
      case _AdminSection.overview:
        return 'Dashboard';
      case _AdminSection.sessions:
        return 'Session Trace';
      case _AdminSection.users:
        return 'Users';
      case _AdminSection.billing:
        return 'Billing';
      case _AdminSection.security:
        return 'Security';
    }
  }

  IconData get icon {
    switch (this) {
      case _AdminSection.overview:
        return Icons.dashboard_outlined;
      case _AdminSection.sessions:
        return Icons.timeline_rounded;
      case _AdminSection.users:
        return Icons.people_outline_rounded;
      case _AdminSection.billing:
        return Icons.payments_outlined;
      case _AdminSection.security:
        return Icons.security_outlined;
    }
  }
}

class _AdminSidebar extends StatelessWidget {
  const _AdminSidebar({required this.selected, required this.onSelected});

  final _AdminSection selected;
  final ValueChanged<_AdminSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.94),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                AppLogo(size: 38),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Stopwatch\nAdmin',
                    style: TextStyle(fontWeight: FontWeight.w800, height: 1.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (final section in _AdminSection.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _SidebarDestination(
                  section: section,
                  selected: section == selected,
                  onTap: () => onSelected(section),
                ),
              ),
            const Spacer(),
            const _SidebarPrivacyNote(),
          ],
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final _AdminSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        selected: selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(section.icon),
        title: Text(section.label),
        onTap: onTap,
      ),
    );
  }
}

class _SidebarPrivacyNote extends StatelessWidget {
  const _SidebarPrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Local session only\nSensitive values are redacted.',
        style: TextStyle(fontSize: 12, height: 1.35),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Demo data warning',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD6A800)),
        ),
        child: const Row(
          children: [
            Icon(Icons.science_outlined, color: Color(0xFF805F00)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Demo mode — figures below are sample data and are not connected to production records.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final ratio = columns == 1 ? 2.8 : 2.05;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _AdminDemoData.metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: ratio,
          ),
          itemBuilder: (context, index) =>
              _MetricCard(metric: _AdminDemoData.metrics[index]),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _DemoMetric metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: metric.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(metric.icon, color: metric.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metric.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    metric.label,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _AdminDetailGrid extends StatelessWidget {
  const _AdminDetailGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final funnel = const _FunnelCard();
        final alerts = const _AlertsCard();
        final activity = const _ActivityCard();
        if (constraints.maxWidth < 850) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FunnelCard(),
              SizedBox(height: 16),
              _AlertsCard(),
              SizedBox(height: 16),
              _ActivityCard(),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: funnel),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: alerts),
              ],
            ),
            const SizedBox(height: 16),
            activity,
          ],
        );
      },
    );
  }
}

class _FunnelCard extends StatelessWidget {
  const _FunnelCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Player funnel',
      subtitle: 'Sample conversion for the last 24 hours',
      child: Column(
        children: [
          for (final item in _AdminDemoData.funnel) ...[
            _FunnelRow(item: item),
            if (item != _AdminDemoData.funnel.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  const _FunnelRow({required this.item});

  final _DemoFunnelItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Text(item.label)),
            Text(
              '${item.count}  ·  ${(item.rate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: item.rate,
            minHeight: 9,
            backgroundColor: const Color(0xFFE2E8F0),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Security signals',
      subtitle: 'Sample events requiring review',
      child: Column(
        children: [
          for (final alert in _AdminDemoData.alerts)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: alert.color.withValues(alpha: 0.13),
                foregroundColor: alert.color,
                child: Icon(alert.icon, size: 20),
              ),
              title: Text(alert.title),
              subtitle: Text(alert.detail),
              trailing: Text(alert.count.toString()),
            ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Recent activity',
      subtitle: 'Masked sample records',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Event')),
            DataColumn(label: Text('Result')),
            DataColumn(label: Text('Reference')),
          ],
          rows: [
            for (final activity in _AdminDemoData.activity)
              DataRow(
                cells: [
                  DataCell(Text(activity.time)),
                  DataCell(Text(activity.user)),
                  DataCell(Text(activity.event)),
                  DataCell(_StatusChip(label: activity.result)),
                  DataCell(Text(activity.reference)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onBackground.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = switch (label.toLowerCase()) {
      'success' || 'active' || 'completed' => const Color(0xFF15803D),
      'failed' || 'blocked' || 'inactive' => const Color(0xFFB91C1C),
      _ => const Color(0xFFB45309),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

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
              : Column(
                  children: [
                    for (final record in records)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TraceRecordTile(record: record),
                      ),
                  ],
                ),
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

class _TraceRecordTile extends StatelessWidget {
  const _TraceRecordTile({required this.record});

  final SessionTraceRecord record;

  @override
  Widget build(BuildContext context) {
    final isEvent = record.kind == SessionTraceKind.event;
    final status = record.statusCode == null ? null : '${record.statusCode}';
    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFF8FAFC),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: (isEvent ? AppColors.secondary : AppColors.primary)
              .withValues(alpha: 0.12),
          foregroundColor: isEvent ? AppColors.secondary : AppColors.primary,
          child: Icon(
            isEvent ? Icons.bolt_rounded : Icons.http_rounded,
            size: 20,
          ),
        ),
        title: Text(
          record.label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${_formatTime(record.occurredAt)}'
          '${record.durationMs == null ? '' : ' · ${record.durationMs} ms'}'
          '${record.maskedMsisdn == null ? '' : ' · ${record.maskedMsisdn}'}',
        ),
        trailing: status == null
            ? const Text('EVENT')
            : Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: record.succeeded
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB45309),
                ),
              ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (record.path != null)
                  _TraceField(label: 'Path', value: record.path!),
                if (record.request != null)
                  _TraceField(
                    label: isEvent ? 'Properties' : 'Request',
                    value: _pretty(record.request),
                  ),
                if (record.response != null)
                  _TraceField(
                    label: 'Response',
                    value: _pretty(record.response),
                  ),
                if (record.error != null)
                  _TraceField(label: 'Error', value: record.error!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) =>
      value.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first;

  static String _pretty(Object? value) {
    if (value is String) return value;
    return const JsonEncoder.withIndent('  ').convert(value);
  }
}

class _TraceField extends StatelessWidget {
  const _TraceField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(9),
            ),
            child: SelectableText(
              value,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          subtitle: 'Sample accounts with masked subscriber numbers',
          child: _AdminDataTable(
            columns: ['User', 'MSISDN', 'Channel', 'Status', 'Last access'],
            rows: [
              ['USR-1042', '255676***824', 'WEB', 'Active', '2 min ago'],
              ['USR-1038', '255754***091', 'WEB', 'Active', '6 min ago'],
              ['USR-1035', '255713***668', 'APP', 'Active', '12 min ago'],
              ['USR-1029', '255689***443', 'SMS', 'Review', '19 min ago'],
              ['USR-1017', '255622***705', 'WEB', 'Inactive', 'Yesterday'],
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
                '255676***824',
                'TZS 1,000',
                'Yas',
                'Success',
                '11:26',
              ],
              [
                'REQ-8F20',
                '255754***091',
                'TZS 1,000',
                'M-Pesa',
                'Pending',
                '11:24',
              ],
              [
                'REQ-8F19',
                '255713***668',
                'TZS 2,000',
                'Airtel',
                'Success',
                '11:17',
              ],
              [
                'REQ-8F18',
                '255689***443',
                'TZS 1,000',
                'Yas',
                'Failed',
                '11:11',
              ],
              [
                'REQ-8F17',
                '255622***705',
                'TZS 1,000',
                'M-Pesa',
                'Success',
                '11:03',
              ],
            ],
            statusColumn: 4,
          ),
        ),
        SizedBox(height: 16),
        _Panel(
          title: 'Provider performance',
          subtitle: 'Dummy successful-payment share for the last 24 hours',
          child: _BreakdownList(
            items: [
              _DemoBreakdown('Yas', 218, 0.94),
              _DemoBreakdown('M-Pesa', 146, 0.89),
              _DemoBreakdown('Airtel Money', 72, 0.86),
            ],
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
                '255689***443',
                'SES-91D2',
                'Review',
              ],
              [
                '11:22',
                'request.signature_invalid',
                '255754***091',
                'SES-80C4',
                'Blocked',
              ],
              [
                '11:16',
                'game.sequence_invalid',
                '255622***705',
                'SES-77A8',
                'Review',
              ],
              [
                '10:58',
                'auth.login_succeeded',
                '255676***824',
                'SES-63F1',
                'Success',
              ],
              [
                '10:47',
                'request.rate_limited',
                '255713***668',
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

class _AdminDataTable extends StatelessWidget {
  const _AdminDataTable({
    required this.columns,
    required this.rows,
    this.statusColumn,
  });

  final List<String> columns;
  final List<List<String>> rows;
  final int? statusColumn;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          for (final column in columns) DataColumn(label: Text(column)),
        ],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                for (var index = 0; index < row.length; index++)
                  DataCell(
                    index == statusColumn
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

class _AdminDemoData {
  static const metrics = [
    _DemoMetric(
      '128',
      'Active users',
      Icons.people_alt_outlined,
      AppColors.primary,
    ),
    _DemoMetric(
      '92.4%',
      'Login success',
      Icons.verified_user_outlined,
      Color(0xFF15803D),
    ),
    _DemoMetric(
      '88.1%',
      'Billing success',
      Icons.payments_outlined,
      Color(0xFFB8860B),
    ),
    _DemoMetric(
      '436',
      'Completed rounds',
      Icons.timer_outlined,
      AppColors.secondary,
    ),
  ];

  static const funnel = [
    _DemoFunnelItem('Portal visits', 620, 1),
    _DemoFunnelItem('Authenticated', 481, 0.776),
    _DemoFunnelItem('Billing successful', 424, 0.684),
    _DemoFunnelItem('Round completed', 396, 0.639),
  ];

  static const alerts = [
    _DemoAlert(
      'Repeated OTP failures',
      'Last hour',
      7,
      Icons.password_rounded,
      Color(0xFFB45309),
    ),
    _DemoAlert(
      'Invalid game sequence',
      'Start/stop order',
      3,
      Icons.rule_rounded,
      Color(0xFFB91C1C),
    ),
    _DemoAlert(
      'Billing timeouts',
      'Awaiting callback',
      5,
      Icons.schedule_rounded,
      AppColors.primary,
    ),
  ];

  static const activity = [
    _DemoActivity(
      '11:28',
      'USR-1042',
      'auth.login_succeeded',
      'Success',
      'evt…81a',
    ),
    _DemoActivity(
      '11:26',
      'USR-1038',
      'billing.succeeded',
      'Success',
      'req…4c2',
    ),
    _DemoActivity('11:24', 'USR-1035', 'game.completed', 'Success', 'ses…9fd'),
    _DemoActivity(
      '11:21',
      'USR-1029',
      'round.preparation_failed',
      'Review',
      'req…0b7',
    ),
  ];

  static const userMetrics = [
    _DemoMetric(
      '1,284',
      'Total users',
      Icons.groups_outlined,
      AppColors.primary,
    ),
    _DemoMetric(
      '128',
      'Active now',
      Icons.online_prediction_rounded,
      Color(0xFF15803D),
    ),
    _DemoMetric(
      '47',
      'New today',
      Icons.person_add_alt_1_outlined,
      AppColors.secondary,
    ),
    _DemoMetric(
      '92.4%',
      'Login success',
      Icons.login_rounded,
      Color(0xFFB8860B),
    ),
  ];

  static const billingMetrics = [
    _DemoMetric(
      'TZS 436K',
      'Collected today',
      Icons.account_balance_wallet_outlined,
      AppColors.primary,
    ),
    _DemoMetric(
      '436',
      'Successful',
      Icons.check_circle_outline_rounded,
      Color(0xFF15803D),
    ),
    _DemoMetric('18', 'Pending', Icons.schedule_rounded, Color(0xFFB8860B)),
    _DemoMetric('12', 'Failed', Icons.error_outline_rounded, Color(0xFFB91C1C)),
  ];

  static const securityMetrics = [
    _DemoMetric('7', 'OTP failures', Icons.password_rounded, Color(0xFFB45309)),
    _DemoMetric(
      '3',
      'Invalid signatures',
      Icons.gpp_bad_outlined,
      Color(0xFFB91C1C),
    ),
    _DemoMetric('5', 'Rate limited', Icons.speed_rounded, AppColors.primary),
    _DemoMetric(
      '2',
      'Sessions blocked',
      Icons.block_rounded,
      Color(0xFFB91C1C),
    ),
  ];
}

class _DemoMetric {
  const _DemoMetric(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class _DemoFunnelItem {
  const _DemoFunnelItem(this.label, this.count, this.rate);
  final String label;
  final int count;
  final double rate;
}

class _DemoAlert {
  const _DemoAlert(this.title, this.detail, this.count, this.icon, this.color);
  final String title;
  final String detail;
  final int count;
  final IconData icon;
  final Color color;
}

class _DemoActivity {
  const _DemoActivity(
    this.time,
    this.user,
    this.event,
    this.result,
    this.reference,
  );
  final String time;
  final String user;
  final String event;
  final String result;
  final String reference;
}

class _DemoBreakdown {
  const _DemoBreakdown(this.label, this.count, this.rate);

  final String label;
  final int count;
  final double rate;
}
