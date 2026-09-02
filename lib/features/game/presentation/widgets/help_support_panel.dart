import 'package:flutter/material.dart';
import 'package:stopwatch_game/core/constants/app_colors.dart';
import 'package:stopwatch_game/core/copy/app_copy.dart';

class HelpSupportPanel extends StatelessWidget {
  const HelpSupportPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _YasCustomerCare(),
          SizedBox(height: 20),
          _QuestionsAndAnswers(),
        ],
      ),
    );
  }
}

class _YasCustomerCare extends StatelessWidget {
  const _YasCustomerCare();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8E3F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.headset_mic_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GameCopy.customerCareTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        GameCopy.customerCareSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF3D69A6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 12.0;
                final columns = constraints.maxWidth >= 960
                    ? 4
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;
                final width =
                    (constraints.maxWidth - (gap * (columns - 1))) / columns;

                final channels = [
                  _CareChannel(
                    icon: Icons.phone_in_talk_outlined,
                    label: GameCopy.customerCareCall,
                    value: '100',
                    detail: GameCopy.customerCareCallDetail,
                  ),
                  _CareChannel(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: GameCopy.customerCareWhatsApp,
                    value: '0714 100 100',
                    detail: GameCopy.customerCareWhatsAppDetail,
                  ),
                  _CareChannel(
                    icon: Icons.mail_outline_rounded,
                    label: GameCopy.customerCareEmail,
                    value: 'customercare@yas.co.tz',
                    detail: GameCopy.customerCareEmailDetail,
                    highlightedIcon: true,
                  ),
                  _CareChannel(
                    icon: Icons.storefront_outlined,
                    label: GameCopy.customerCareVisit,
                    value: GameCopy.customerCareStore,
                    detail: GameCopy.customerCareVisitDetail,
                  ),
                ];

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final channel in channels)
                      SizedBox(width: width, child: channel),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CareChannel extends StatelessWidget {
  const _CareChannel({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    this.highlightedIcon = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final bool highlightedIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 176),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E3F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: highlightedIcon
                  ? const Color(0xFFFFF7D6)
                  : const Color(0xFFEAF2FB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: highlightedIcon
                    ? const Color(0xFFFFDF68)
                    : const Color(0xFFD8E5F3),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 25),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: const Color(0xFF3D69A6),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF3D69A6),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionsAndAnswers extends StatelessWidget {
  const _QuestionsAndAnswers();

  @override
  Widget build(BuildContext context) {
    final items = [
      (question: GameCopy.faqPlayQuestion, answer: GameCopy.faqPlayAnswer),
      (question: GameCopy.faqChargeQuestion, answer: GameCopy.faqChargeAnswer),
      (question: GameCopy.faqTargetQuestion, answer: GameCopy.faqTargetAnswer),
      (
        question: GameCopy.faqPaymentQuestion,
        answer: GameCopy.faqPaymentAnswer,
      ),
      (
        question: GameCopy.faqHistoryQuestion,
        answer: GameCopy.faqHistoryAnswer,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFDFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8E3F0)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: AppColors.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GameCopy.faqTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        GameCopy.faqSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF3D69A6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (var index = 0; index < items.length; index++) ...[
              _FaqItem(
                question: items[index].question,
                answer: items[index].answer,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, color: Color(0xFFE3EBF4)),
            ],
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        childrenPadding: const EdgeInsets.fromLTRB(4, 0, 42, 16),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.primary,
        title: Text(
          question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF3D5F8B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
