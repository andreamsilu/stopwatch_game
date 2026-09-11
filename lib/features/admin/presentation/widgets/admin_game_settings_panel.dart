import 'package:flutter/material.dart';

/// In-memory draft only. API loading and saving will be added when available.
/// Kept by the admin page so navigation does not discard the form.
class AdminGameSettingsDraft {
  final tolerance = TextEditingController(text: '50');
  final speed = TextEditingController(text: '1.00');

  double get previewSpeed => (double.tryParse(speed.text) ?? 1).clamp(.25, 4);

  void dispose() {
    tolerance.dispose();
    speed.dispose();
  }
}

class AdminGameSettingsPanel extends StatefulWidget {
  const AdminGameSettingsPanel({required this.draft, super.key});
  final AdminGameSettingsDraft draft;

  @override
  State<AdminGameSettingsPanel> createState() => _AdminGameSettingsPanelState();
}

class _AdminGameSettingsPanelState extends State<AdminGameSettingsPanel> {
  AdminGameSettingsDraft get draft => widget.draft;

  String? _integer(String? text, int min, int max) {
    final value = int.tryParse(text ?? '');
    return value == null || value < min || value > max
        ? 'Enter a whole number from $min to $max.'
        : null;
  }

  String? _speedError(String? text) {
    final value = double.tryParse(text ?? '');
    if (value == null || !value.isFinite || value < .25 || value > 4) {
      return 'Enter a speed from 0.25 to 4.00.';
    }
    if ((value * 20 - (value * 20).round()).abs() > .000001) {
      return 'Use increments of 0.05.';
    }
    return null;
  }

  Widget _field(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    bool decimal = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      onChanged: (_) => setState(() {}),
    );
  }

  void _setSpeed(double value) => setState(() {
    draft.speed.text = value.toStringAsFixed(2);
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final valid =
        _integer(draft.tolerance.text, 1, 5000) == null &&
        _speedError(draft.speed.text) == null;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Stopwatch configuration', style: text.headlineSmall),
              const SizedBox(height: 8),
              const Text('Configure win tolerance and timer speed.'),
              const SizedBox(height: 16),
              _section(
                context,
                'API integration pending',
                const Text(
                  'Preview only. These are reference defaults, not live settings. Edits stay in this admin session and do not change gameplay. Saving will be available when the API is connected.',
                ),
              ),
              const SizedBox(height: 24),
              _field(
                'Near-win tolerance (± ms)',
                draft.tolerance,
                (s) => _integer(s, 1, 5000),
              ),
              const SizedBox(height: 8),
              const Text(
                'Allowed range: 1–5000 ms. The tolerance is the maximum timing error allowed for a near win.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Text('Timer speed', style: text.titleMedium),
              Slider(
                value: draft.previewSpeed,
                min: .25,
                max: 4,
                divisions: 75,
                label: '${draft.previewSpeed.toStringAsFixed(2)}×',
                onChanged: _setSpeed,
              ),
              _field(
                'Speed multiplier',
                draft.speed,
                _speedError,
                decimal: true,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in const [
                    ('Slow', .5),
                    ('Normal', 1.0),
                    ('Fast', 1.5),
                    ('Very fast', 2.0),
                  ])
                    OutlinedButton(
                      onPressed: () => _setSpeed(preset.$2),
                      child: Text('${preset.$1} (${preset.$2}×)'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'One real second equals the selected multiplier in timer seconds. Allowed range: 0.25–4.00×, in steps of 0.05. Future saved settings apply to new rounds.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                'Preview',
                valid
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Near-win tolerance: ±${draft.tolerance.text} ms',
                          ),
                          Text(
                            'Timer runs at ${draft.previewSpeed.toStringAsFixed(2)}×',
                          ),
                        ],
                      )
                    : const Text(
                        'Enter valid values to preview the configuration.',
                      ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.save_outlined),
                  label: Text('Save settings'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) => Material(
    color: const Color(0xFFF2F5F9),
    borderRadius: BorderRadius.circular(12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    ),
  );
}
