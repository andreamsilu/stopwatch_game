import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/providers/app_locale_provider.dart';

class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({this.compact = false, super.key});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final isSwahili = locale.languageCode == 'sw';

    return PopupMenuButton<String>(
      tooltip: isSwahili ? 'Badilisha lugha' : 'Change language',
      initialValue: locale.languageCode,
      onSelected: (code) {
        ref
            .read(appLocaleProvider.notifier)
            .select(code == 'en' ? englishLocale : swahiliLocale);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'sw', child: Text('Kiswahili')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4DEEB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, size: 19),
            if (!compact) ...[
              const SizedBox(width: 6),
              Text(
                isSwahili ? 'SW' : 'EN',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
            const Icon(Icons.arrow_drop_down_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
