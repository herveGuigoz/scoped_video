import 'package:flutter/widgets.dart';

import 'build_context_extensions.dart';
import 'core.dart';

typedef OnStateChanged<T> = void Function(BuildContext context, T state);

/// A widget which watches a [StateRef] and calls a function when
/// the underlying state changes.
class VideoListener<T> extends StatelessWidget {
  /// Creates a [VideoListener].
  ///
  /// The parameters [watchable], [onStateChanged] and [child] must not be null.
  const VideoListener({
    Key key,
    @required this.watchable,
    @required this.onStateChanged,
    @required this.child,
  })  : assert(watchable != null),
        assert(onStateChanged != null),
        assert(child != null),
        super(key: key);

  /// The reference to watch.
  final Watchable<T> watchable;

  /// The function called when the state referenced changed.
  final OnStateChanged<T> onStateChanged;

  /// The widget below in the tree.
  ///
  /// {@macro flutter.widgets.child}.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final value = context.watch(watchable);
    return _ValueListener<T>(
      value: value,
      onValueChanged: onStateChanged,
      equalityComparer: watchable.equalityComparer,
      child: child,
    );
  }
}

bool _defaultEqualityComparer<T>(T previous, T current) => previous == current;

/// A widget that watches a value and calls a function when it changed.
class _ValueListener<T> extends StatefulWidget {
  /// Creates a [_ValueListener].
  ///
  /// The parameters [onValueChanged] and [child] must not be null.
  const _ValueListener({
    Key key,
    @required this.value,
    @required this.onValueChanged,
    EqualityComparer<T> equalityComparer,
    @required this.child,
  })  : assert(onValueChanged != null),
        assert(child != null),
        equalityComparer = equalityComparer ?? _defaultEqualityComparer,
        super(key: key);

  /// The value to listen to changes.
  final T value;

  /// The function called when the [value] changed.
  final OnStateChanged<T> onValueChanged;

  /// The comparer used to know if the old and new value are equals.
  final EqualityComparer<T> equalityComparer;

  /// The widget below in the tree.
  ///
  /// {@macro flutter.widgets.child}.
  final Widget child;

  @override
  _ValueListenerState<T> createState() => _ValueListenerState<T>();
}

class _ValueListenerState<T> extends State<_ValueListener<T>> {
  @override
  void didUpdateWidget(_ValueListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.equalityComparer(oldWidget.value, widget.value)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onValueChanged(context, widget.value),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
