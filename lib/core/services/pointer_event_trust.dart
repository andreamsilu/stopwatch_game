import 'pointer_event_trust_stub.dart'
    if (dart.library.html) 'pointer_event_trust_web.dart' as trust_impl;

class PointerEventTrust {
  const PointerEventTrust._();

  static bool? currentIsTrusted() => trust_impl.currentIsTrusted();
}
