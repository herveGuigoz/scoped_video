import 'package:meta/meta.dart';

import 'core.dart';

/// Implements utilities methods for accessing the scope where this logic is
/// stored.
abstract class Logic {
  /// The scope where this logic is stored.
  @visibleForOverriding
  Scope get scope;

  @protected
  @nonVirtual
  void writeState<T>(StateRef<T> ref, T state, [Object action]) {
    scope.writeState(ref, state, action);
  }

  /// Updates the value of the state referenced by [ref] with a function which
  /// provides the current state.
  ///
  /// An optional [action] can be send to track which method did the update.
  @protected
  @nonVirtual
  void updateState<T>(StateRef<T> ref, Updater<T> updater, [Object action]) {
    final currentState = scope.useState(ref);
    final newState = updater(currentState);
    if (ref.equals(currentState, newState)) return;
    scope.writeState(ref, newState, action);
  }

  @protected
  @nonVirtual
  void clearState<T>(StateRef<T> ref) {
    scope.clearState(ref);
  }

  @protected
  @nonVirtual
  T useState<T>(Watchable<T> ref) {
    return scope.useState(ref);
  }

  @protected
  @nonVirtual
  T useLogic<T>(LogicRef<T> ref) {
    return scope.useLogic(ref);
  }
}
