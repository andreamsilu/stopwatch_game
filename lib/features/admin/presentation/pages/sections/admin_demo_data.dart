part of '../admin_dashboard_page.dart';

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
