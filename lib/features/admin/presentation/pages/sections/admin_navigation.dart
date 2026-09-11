part of '../admin_dashboard_page.dart';

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
                          section.description,
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

enum _AdminSection {
  overview,
  settings,
  sessions,
  evidence,
  users,
  billing,
  security,
}

extension on _AdminSection {
  String get description => switch (this) {
    _AdminSection.overview => 'Activity, performance, and recent events',
    _AdminSection.settings => 'Win tolerance and timer speed',
    _AdminSection.users => 'Player accounts and registration activity',
    _AdminSection.billing => 'Payments and transaction history',
    _AdminSection.evidence => 'Review play access and supporting records',
    _AdminSection.security => 'Access checks and integrity events',
    _AdminSection.sessions => 'Inspect local request and response traces',
  };
  String get label {
    switch (this) {
      case _AdminSection.overview:
        return 'Dashboard';
      case _AdminSection.settings:
        return 'Game settings';
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
      case _AdminSection.settings:
        return Icons.settings_outlined;
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
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                AppLogo(size: 40),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Stopwatch\nAdmin',
                    style: TextStyle(fontWeight: FontWeight.w800, height: 1.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  for (final group in const [
                    ('OVERVIEW', [_AdminSection.overview]),
                    (
                      'OPERATIONS',
                      [
                        _AdminSection.users,
                        _AdminSection.billing,
                        _AdminSection.evidence,
                      ],
                    ),
                    (
                      'ADMINISTRATION',
                      [_AdminSection.settings, _AdminSection.security],
                    ),
                  ]) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Text(
                        group.$1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF64748B),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (final section in group.$2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _SidebarDestination(
                          section: section,
                          selected: section == selected,
                          onTap: () => onSelected(section),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
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
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: ListTile(
        selected: selected,
        selectedColor: Colors.white,
        iconColor: AppColors.primary,
        textColor: AppColors.primary,
        titleTextStyle: Theme.of(context).textTheme.labelLarge,
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
