import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';
import 'package:stopwatch_game/core/widgets/experience_background.dart';

/// Temporary administration dashboard backed by clearly labelled demo data.
///
/// Replace [_AdminDemoData] with authenticated admin API providers before
/// production. The `/admin` route is intentionally open during this phase.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExperienceBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _AdminHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1240),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DemoBanner(),
                          SizedBox(height: 16),
                          _SummaryGrid(),
                          SizedBox(height: 16),
                          _AdminDetailGrid(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
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
                  const AppLogo(size: 38),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Console',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Stopwatch Challenge operations',
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
    final success = label == 'Success';
    final color = success ? const Color(0xFF15803D) : const Color(0xFFB45309);
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
