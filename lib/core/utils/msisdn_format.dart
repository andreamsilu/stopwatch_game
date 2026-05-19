/// Display formatting for Tanzania MSISDN values.
class MsisdnFormat {
  MsisdnFormat._();

  static String normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('255')) return digits;
    if (digits.startsWith('0')) return '255${digits.substring(1)}';
    return '255$digits';
  }

  /// e.g. `255656692469` → `+255 656 692 469`
  static String display(String msisdn) {
    final digits = normalize(msisdn);
    if (digits.length < 12) return '+$digits';

    final local = digits.substring(3);
    return '+255 ${local.substring(0, 3)} ${local.substring(3, 6)} ${local.substring(6)}';
  }
}
