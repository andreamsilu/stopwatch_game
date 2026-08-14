import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/services/api_session_trace_store.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';

Widget _adminSortArrow(bool ascending, bool sorted) {
  return Icon(
    sorted
        ? ascending
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded
        : Icons.unfold_more_rounded,
    size: 17,
    color: sorted ? AppColors.primary : const Color(0xFF64748B),
  );
}

/// Temporary administration dashboard backed by clearly labelled demo data.
///
/// Replace [_AdminDemoData] with authenticated admin API providers before
/// production. The `/admin` route uses dummy client-side credentials only.
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  static const _dummyAdminEmail = 'admin@greentelecom.co.tz';
  static const _dummyAdminPassword = 'admin123';

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _traceStore = ApiSessionTraceStore.instance;
  _AdminSection _section = _AdminSection.overview;
  bool _authenticated = false;
  bool _obscurePassword = true;
  String? _loginError;
  bool _refreshScheduled = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim().toLowerCase();
    if (email == _dummyAdminEmail &&
        _passwordController.text == _dummyAdminPassword) {
      setState(() {
        _authenticated = true;
        _loginError = null;
        _passwordController.clear();
      });
      return;
    }
    setState(() => _loginError = 'Invalid admin email or password.');
  }

  void _logout() {
    setState(() {
      _authenticated = false;
      _section = _AdminSection.overview;
      _loginError = null;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  void _refresh() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      setState(() {});
      return;
    }
    if (_refreshScheduled) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (mounted) setState(() {});
    });
  }

  void _selectSection(_AdminSection section) {
    setState(() => _section = section);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return _AdminLoginView(
        emailController: _emailController,
        passwordController: _passwordController,
        obscurePassword: _obscurePassword,
        error: _loginError,
        onTogglePassword: () {
          setState(() => _obscurePassword = !_obscurePassword);
        },
        onLogin: _login,
      );
    }

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
                    onLogout: _logout,
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
      case _AdminSection.evidence:
        return const _PlayEvidenceDemoPanel();
      case _AdminSection.users:
      case _AdminSection.billing:
      case _AdminSection.security:
        return _DemoModulePanel(section: _section);
    }
  }
}

class _AdminLoginView extends StatelessWidget {
  const _AdminLoginView({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.error,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExperienceBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Align(child: AppLogo(size: 58)),
                          const SizedBox(height: 18),
                          Text(
                            'Admin sign in',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Demo administration access',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppColors.onBackground.withValues(
                                    alpha: 0.65,
                                  ),
                                ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            key: const ValueKey('admin-email'),
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.username],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            key: const ValueKey('admin-password'),
                            controller: passwordController,
                            obscureText: obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => onLogin(),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                onPressed: onTogglePassword,
                                tooltip: obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          if (error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: onLogin,
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Sign in'),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Dummy login only · Replace with backend authentication before production.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({
    required this.section,
    required this.onLogout,
    this.onOpenMenu,
  });

  final _AdminSection section;
  final VoidCallback onLogout;
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
                  IconButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (_) => false),
                    tooltip: 'Player portal',
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                  IconButton(
                    onPressed: onLogout,
                    tooltip: 'Admin logout',
                    icon: const Icon(Icons.logout_rounded),
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

enum _AdminSection { overview, sessions, evidence, users, billing, security }

extension on _AdminSection {
  String get label {
    switch (this) {
      case _AdminSection.overview:
        return 'Dashboard';
      case _AdminSection.sessions:
        return 'Session Trace';
      case _AdminSection.evidence:
        return 'Play Evidence';
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
      case _AdminSection.evidence:
        return Icons.fact_check_outlined;
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
            for (final section in _AdminSection.values.where(
              (section) => section != _AdminSection.sessions,
            ))
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
        'Local session only\nLive sensitive values are redacted.',
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
      subtitle: 'Sample activity records',
      child: _AdminDataTable(
        columns: const ['Time', 'User', 'Event', 'Result', 'Reference'],
        rows: [
          for (final activity in _AdminDemoData.activity)
            [
              activity.time,
              activity.user,
              activity.event,
              activity.result,
              activity.reference,
            ],
        ],
        statusColumn: 3,
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
      'success' ||
      'active' ||
      'completed' ||
      'verified' ||
      'recorded' => const Color(0xFF15803D),
      'failed' ||
      'blocked' ||
      'inactive' ||
      'refund due' => const Color(0xFFB91C1C),
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
