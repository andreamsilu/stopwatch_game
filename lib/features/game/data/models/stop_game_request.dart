class StopGameRequest {
  const StopGameRequest({required this.sessionRef});

  final String sessionRef;

  /// Server records stop time; only [sessionRef] is accepted by the API.
  Map<String, dynamic> toJson() => {'sessionRef': sessionRef};
}
