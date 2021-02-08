import '../../scoped_video.dart';

typedef OnStateUpdated = bool Function<T>(
  StateRef<T> ref,
  T oldState,
  T newState,
  Object action,
);

/// An object that observes state changes.
abstract class StateObserver {
  /// Called when a state changed.
  /// This method must return true if the changes have been handled and other
  /// observers must no be called, or false if other observers can be called.
  bool didChanged<T>(StateRef<T> ref, T oldState, T newState, Object action);
}

/// A specific [StateObserver] which delegates the actual implementation to a
/// function.
class DelegatingStateObserver implements StateObserver {
  /// Creates a [DelegatingStateObserver].
  const DelegatingStateObserver(this.onStateUpdated);

  /// The function called when a state changed.
  final OnStateUpdated onStateUpdated;

  @override
  bool didChanged<T>(StateRef<T> ref, T oldState, T newState, Object action) {
    return onStateUpdated(ref, oldState, newState, action);
  }
}
