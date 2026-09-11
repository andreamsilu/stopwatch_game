part of '../admin_dashboard_page.dart';

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
