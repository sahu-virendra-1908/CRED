import 'dart:async';

/// Coalesces concurrent identical in-flight network requests into a single Future.
class RequestDeduplicator {
  final Map<String, Future<dynamic>> _inFlight = {};

  Future<T> run<T>(String key, Future<T> Function() action) {
    final existing = _inFlight[key];
    if (existing != null) {
      return existing as Future<T>;
    }

    final completer = Completer<T>();
    _inFlight[key] = completer.future;

    action().then(
      (value) {
        _inFlight.remove(key);
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        _inFlight.remove(key);
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );

    return completer.future;
  }

  bool isInFlight(String key) => _inFlight.containsKey(key);
}
