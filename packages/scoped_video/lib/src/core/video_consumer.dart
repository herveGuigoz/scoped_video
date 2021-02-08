import 'package:flutter/widgets.dart';
import 'package:scoped_video/scoped_video.dart';

/// A widget whose content stays synced with a [Watchable].
///
/// Given a [Watchable<T>] and a [builder] which builds widgets from
/// concrete values of `T`, this class will automatically register itself as a
/// listener of the [Watchable] and call the [builder] with updated values
/// when the value changes.
///
/// ## Performance optimizations
///
/// If your [builder] function contains a subtree that does not depend on the
/// value of the [Watchable], it's more efficient to build that subtree
/// once instead of rebuilding it on every animation tick.
///
/// Using the pre-built child is entirely optional, but can improve
/// performance significantly in some cases and is therefore a good practice.
class VideoConsumer<T> extends StatelessWidget {
  /// The [watchable] and [builder] arguments must not be null.
  /// The [child] is optional but is good practice to use if part of the widget
  /// subtree does not depend on the value of the [watchable].
  const VideoConsumer({
    Key key,
    @required this.watchable,
    @required this.builder,
    this.child,
  })  : assert(watchable != null),
        assert(builder != null),
        super(key: key);

  /// The [Watchable] whose state you depend on, in order to build.
  ///
  /// Must not be null.
  final Watchable<T> watchable;

  /// A [ValueWidgetBuilder] which builds a widget depending on the
  /// [watchable]'s current state.
  ///
  /// Can incorporate a [watchable] value-independent widget subtree
  /// from the [child] parameter into the returned widget tree.
  ///
  /// Must not be null.
  final ValueWidgetBuilder<T> builder;

  /// A [watchable]-independent widget which is passed back to the [builder].
  ///
  /// This argument is optional and can be null if the entire widget subtree
  /// the [builder] builds depends on the value of the [watchable]. For
  /// example, if the [watchable]'s state is a [String] and the [builder] simply
  /// returns a [Text] widget with the [String] value.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return builder(context, context.watch(watchable), child);
  }
}
