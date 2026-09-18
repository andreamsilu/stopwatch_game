enum PlayCreditSource {
  interaction,
  renewal;

  static PlayCreditSource? fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'interaction':
        return PlayCreditSource.interaction;
      case 'renewal':
        return PlayCreditSource.renewal;
      default:
        return null;
    }
  }
}

class PlayCredit {
  const PlayCredit({
    required this.id,
    required this.amount,
    required this.source,
    this.renewalRequestId,
    this.createdAt,
  });

  factory PlayCredit.fromJson(Map<String, dynamic> json) => PlayCredit(
    id: (json['id'] as num).toInt(),
    amount: (json['amount'] as num).toDouble(),
    source:
        PlayCreditSource.fromApi(json['source'] as String?) ??
        PlayCreditSource.renewal,
    renewalRequestId: json['renewalRequestId'] as String?,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );

  final int id;
  final double amount;
  final PlayCreditSource source;
  final String? renewalRequestId;
  final DateTime? createdAt;
}

class CreditsWallet {
  const CreditsWallet({
    required this.msisdn,
    required this.credits,
    required this.renewalCredits,
    required this.availablePlayCredits,
  });

  factory CreditsWallet.fromJson(Map<String, dynamic> json) {
    final available = json['availablePlayCredits'];
    return CreditsWallet(
      msisdn: json['msisdn'] as String? ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      renewalCredits: (json['renewalCredits'] as num?)?.toInt() ?? 0,
      availablePlayCredits: available is List
          ? available
                .whereType<Map<String, dynamic>>()
                .map(PlayCredit.fromJson)
                .toList(growable: false)
          : const [],
    );
  }

  final String msisdn;
  final int credits;
  final int renewalCredits;
  final List<PlayCredit> availablePlayCredits;

  List<PlayCredit> forSource(PlayCreditSource source) => availablePlayCredits
      .where((credit) => credit.source == source)
      .toList(growable: false);

  int countForSource(PlayCreditSource source) =>
      source == PlayCreditSource.interaction ? credits : renewalCredits;

  List<PlayCredit> eligibleForSource(
    PlayCreditSource source, {
    required double requiredAmount,
  }) {
    if (countForSource(source) <= 0) return const [];
    return availablePlayCredits
        .where(
          (credit) =>
              credit.source == source && credit.amount >= requiredAmount,
        )
        .toList(growable: false);
  }
}
