import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../logic/logic.dart';
import 'observer.dart';
import 'video_container.dart';

part 'inherited_video_scope.dart';
part 'video_scope.dart';

/// Signature for determining whether two states are the same.
typedef EqualityComparer<T> = bool Function(T a, T b);

/// Signature for selecting a part of a state.
typedef Selector<T, S> = S Function(T state);

/// Signature for updating a state.
typedef Updater<T> = T Function(T oldState);

/// Signature for creating a derived state from other states.
///
/// Used by [Computed].
typedef StateWatcher = T Function<T>(Watchable<T> ref);

/// Signature for creating a derived state from other states on demand.
///
/// Used by [Computed].
typedef StateBuilder<T> = T Function(StateWatcher watch);

/// Internal use only.
typedef StateReader = T Function<T>(RefKey key, T defaultState);

/// Signature for creating an object.
typedef InstanceFactory<T> = T Function(Scope scope);

/// An object which holds states.
abstract class Scope {
  /// Provide videos sources.
  List<String> get videoSources;

  /// Should initialize video controller;
  bool get lazy;

  /// Should call play on video controller when is initialized.
  bool get autoPlay;

  /// Updates the value of the state referenced by [ref] with [state].
  ///
  /// An optional [action] can be send to track which method did the update.
  void writeState<T>(StateRef<T> ref, T state, [Object action]);

  /// Removes the state referenced by [ref] from the scope.
  void clearState<T>(StateRef<T> ref);

  /// Gets the current state referenced by [ref].
  T useState<T>(Watchable<T> ref);

  /// Gets the current logic component referenced by [ref].
  T useLogic<T>(LogicRef<T> ref);
}

/// A state that can be watched.
@immutable
abstract class Watchable<T> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const Watchable(this.equalityComparer);

  /// The predicate determining if two states are the same.
  final EqualityComparer<T> equalityComparer;

  /// Internal use only.
  List<RefKey> get keys;

  /// Internal use only.
  bool equals(T oldState, T newState) =>
      _equals(equalityComparer, oldState, newState);

  /// Internal use only.
  @visibleForTesting
  T read(StateReader read);
}

/// A reference to a part of the video state.
class StateRef<T> extends Watchable<T> {
  /// Creates a reference to a part of the video state with an [initialState].
  ///
  /// An [equalityComparer] can be provided to determine whether two instances
  /// are the same.
  ///
  /// A [name] can be provided to this reference for debugging purposes.
  StateRef(
    T initialState, {
    EqualityComparer<T> equalityComparer,
    String name,
  }) : this._(
          initialState,
          equalityComparer,
          RefKey(name ?? 'StateRef<$T>'),
        );

  StateRef._(
    this.initialState,
    EqualityComparer<T> equalityComparer,
    this.key,
  )   : keys = [key],
        super(equalityComparer);

  /// This is the initial value of the state.
  final T initialState;

  /// Internal use.
  final RefKey key;

  @override
  final List<RefKey> keys;

  @override
  T read(StateReader read) {
    return read<T>(key, initialState);
  }
}

/// A watchable derived state.
class Computed<T> extends Watchable<T> {
  /// Creates a derived state which combine the current state of other parts and
  /// allows any widget to be rebuilt when the underlaying value changes.
  Computed(
    this.stateBuilder, {
    EqualityComparer<T> equalityComparer,
  })  : keys = <RefKey>[],
        super(equalityComparer);

  /// The function used to build the state.
  final StateBuilder<T> stateBuilder;

  @override
  final List<RefKey> keys;

  @override
  T read(StateReader read) {
    keys.clear();
    X watch<X>(Watchable<X> p) {
      keys.addAll(p.keys);
      return p.read(read);
    }

    return stateBuilder(watch);
  }
}

/// A watchable derived state.
class StateSelector<T, S> extends Watchable<S> {
  /// Creates a derived state to select only the part of the state.
  StateSelector(
    this.ref,
    this.selector,
    EqualityComparer<S> equalityComparer,
  )   : keys = ref.keys,
        super(equalityComparer);

  final Watchable<T> ref;
  final Selector<T, S> selector;

  @override
  final List<RefKey> keys;

  @override
  S read(StateReader read) {
    return selector(ref.read(read));
  }
}

/// Extensions for [Watchable].
extension WatchableExtensions<T> on Watchable<T> {
  /// Creates a selector on a reference that can be watched.
  Watchable<S> select<S>(
    Selector<T, S> selector, {
    EqualityComparer<S> equalityComparer,
  }) {
    return StateSelector(this, selector, equalityComparer);
  }
}

/// A reference to a business logic component.
@immutable
class LogicRef<T> {
  /// Creates a reference to a business logic component.
  ///
  /// The [create] parameter must not be null and it's used to generate a
  /// logic component instance.
  ///
  /// A [name] can be provided to this reference for debugging purposes.
  LogicRef(
    this.create, {
    String name,
  })  : assert(create != null),
        key = RefKey(name ?? 'LogicRef<$T>');

  /// The function used to generate an instance.
  final InstanceFactory<T> create;

  /// Internal use.
  final RefKey key;

  /// Overrides the logic component with a new factory.
  /// This can be useful for mocking purposes.
  ScopeOverride<T> overrideWith(InstanceFactory<T> create) {
    return ScopeOverride<T>._(key, create);
  }

  /// Overrides the logic component with the same factory.
  ScopeOverride<T> overrideWithSelf() {
    return ScopeOverride<T>._(key, create);
  }
}

bool _equals<T>(EqualityComparer<T> equalityComparer, T oldState, T newState) {
  if (equalityComparer != null) {
    return equalityComparer(oldState, newState);
  } else {
    return const DeepCollectionEquality().equals(oldState, newState);
  }
}

/// A redefinition of a [StateRef] or [LogicRef].
@immutable
class ScopeOverride<T> {
  const ScopeOverride._(this.key, this.create);

  /// Internal use.
  final RefKey key;

  /// Internal use.
  final InstanceFactory<T> create;
}
