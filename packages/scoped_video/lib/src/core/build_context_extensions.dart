import 'package:flutter/widgets.dart';

import 'core.dart';

/// Public extensions on [BuildContext].
extension VideoBuildContextExtensions on BuildContext {
  /// Reads the current state of [watchable] and rebuilds the widget calling
  /// this methods when the state changes.
  ///
  /// Cannot be called outside a build method.
  T watch<T>(Watchable<T> watchable) {
    assert(
        widget is LayoutBuilder ||
            widget is SliverWithKeepAliveWidget ||
            debugDoingBuild,
        'Cannot call watch() outside a build method.');
    return watchScope(watchable).useState(watchable);
  }

  /// Gets the instance of the business logic component referenced by [ref].
  ///
  /// Cannot be called while building a widget.
  T useLogic<T>(LogicRef<T> ref) {
    assert(!debugDoingBuild, 'Cannot call use() while building a widget.');
    return readScope().useLogic(ref);
  }
}

/// Internal extensions on [BuildContext].
extension VideoBuildContextInternalExtensions on BuildContext {
  /// Read currents states
  Scope readScope() {
    return getVideoScope(
      getElementForInheritedWidgetOfExactType<InheritedVideoScope>()?.widget
          as InheritedVideoScope,
    );
  }

  /// Subscribe to states
  Scope watchScope<T>(Watchable<T> ref) {
    return getVideoScope(InheritedVideoScope.of(this, Aspect<T>(ref)));
  }

  /// Get access to the scope.
  static Scope getVideoScope(InheritedVideoScope inheritedScope) {
    if (inheritedScope == null) {
      throw StateError('No VideoScope found');
    }
    return inheritedScope?.scope;
  }

  /// Update states
  void write<X>(StateRef<X> ref, X state, [Object action]) {
    assert(!debugDoingBuild, 'Cannot use write while building a widget.');
    readScope().writeState(ref, state, action);
  }
}
