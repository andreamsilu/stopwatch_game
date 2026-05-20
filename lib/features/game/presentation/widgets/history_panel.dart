import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';
import 'package:stopwatch_game/features/game/data/models/game_history_play.dart';
import 'package:stopwatch_game/features/game/presentation/bloc/game_history_provider.dart';

class HistoryPanel extends ConsumerStatefulWidget {
  const HistoryPanel({super.key});

  @override
  ConsumerState<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends ConsumerState<HistoryPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameHistoryProvider.notifier).load(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(gameHistoryProvider);
    final notifier = ref.read(gameHistoryProvider.notifier);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              GameCopy.historyTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              GameCopy.historySubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (historyState.isLoading && historyState.plays.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (historyState.errorMessage != null &&
                historyState.plays.isEmpty)
              _HistoryMessage(
                message: historyState.errorMessage!,
                isError: true,
                onRetry: () => notifier.load(refresh: true),
              )
            else if (historyState.plays.isEmpty)
              _HistoryMessage(message: GameCopy.historyEmpty)
            else ...[
              _HistoryTable(
                plays: historyState.plays,
                isLoading: historyState.isLoading,
              ),
              const SizedBox(height: 12),
              _HistoryPaginationBar(
                displayPage: historyState.displayPage,
                hasPrevious: historyState.hasPreviousPage,
                hasNext: historyState.hasNextPage,
                isLoading: historyState.isLoading,
                onPrevious: notifier.previousPage,
                onNext: notifier.nextPage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({
    required this.message,
    this.isError = false,
    this.onRetry,
  });

  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isError ? Theme.of(context).colorScheme.error : null,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text(GameCopy.historyRetry),
          ),
        ],
      ],
    );
  }
}

class _HistoryTable extends StatelessWidget {
  const _HistoryTable({
    required this.plays,
    required this.isLoading,
  });

  final List<GameHistoryPlay> plays;
  final bool isLoading;

  static const _minTableWidth = 520.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );
    final cellStyle = theme.textTheme.bodyMedium;
    final border = TableBorder.all(
      color: AppColors.primary.withValues(alpha: 0.15),
      width: 1,
    );

    Widget table = Table(
      border: border,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1.4),
        1: FlexColumnWidth(1.1),
        2: FlexColumnWidth(1.1),
        3: FlexColumnWidth(0.7),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
          ),
          children: [
            _HeaderCell(GameCopy.historyColPlayed, style: headerStyle),
            _HeaderCell(GameCopy.historyColTarget, style: headerStyle),
            _HeaderCell(GameCopy.historyColYourStop, style: headerStyle),
            _HeaderCell(GameCopy.historyColResult, style: headerStyle),
          ],
        ),
        ...plays.map((play) {
          final outcomeColor = play.winner
              ? const Color(0xFF0F7B3D)
              : const Color(0xFFB91C1C);
          return TableRow(
            children: [
              _DataCell(_formatPlayedAt(play.playedAt), style: cellStyle),
              _DataCell(play.targetTimeLabel, style: cellStyle),
              _DataCell(play.stoppedTimeLabel, style: cellStyle),
              _DataCell(
                play.outcomeLabel,
                style: cellStyle?.copyWith(
                  color: outcomeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
        }),
      ],
    );

    if (isLoading) {
      table = Stack(
        children: [
          Opacity(opacity: 0.45, child: table),
          const Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth < _minTableWidth
                      ? _minTableWidth
                      : constraints.maxWidth,
                ),
                child: table,
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatPlayedAt(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(text, style: style),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(text, style: style),
    );
  }
}

class _HistoryPaginationBar extends StatelessWidget {
  const _HistoryPaginationBar({
    required this.displayPage,
    required this.hasPrevious,
    required this.hasNext,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  final int displayPage;
  final bool hasPrevious;
  final bool hasNext;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: hasPrevious && !isLoading ? onPrevious : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: GameCopy.historyPreviousPage,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            GameCopy.historyPageLabel(displayPage),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: hasNext && !isLoading ? onNext : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: GameCopy.historyNextPage,
        ),
      ],
    );
  }
}
