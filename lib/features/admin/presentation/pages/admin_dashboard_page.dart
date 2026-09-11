import 'package:stopwatch_game/features/admin/presentation/widgets/admin_game_settings_panel.dart';
import 'dart:convert';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/services/api_session_trace_store.dart';
import 'package:stopwatch_game/core/widgets/app_logo.dart';

part 'sections/admin_login.dart';
part 'sections/admin_navigation.dart';
part 'sections/admin_overview.dart';
part 'sections/admin_shared_widgets.dart';
part 'sections/admin_session_trace.dart';
part 'sections/admin_play_evidence.dart';
part 'sections/admin_operations.dart';
part 'sections/admin_demo_data.dart';

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

  final _gameSettingsDraft = AdminGameSettingsDraft();
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
    _gameSettingsDraft.dispose();
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
      body: ColoredBox(
        color: const Color(0xFFF6F9FE),
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
                      key: PageStorageKey(_section),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: _section == _AdminSection.settings
                                ? 960
                                : 1240,
                          ),
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
      case _AdminSection.settings:
        return AdminGameSettingsPanel(draft: _gameSettingsDraft);
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
