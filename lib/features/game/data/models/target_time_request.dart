class TargetTimeRequest {
  const TargetTimeRequest({required this.msisdn});

  final String msisdn;

  Map<String, dynamic> toJson() => {'msisdn': msisdn};
}
