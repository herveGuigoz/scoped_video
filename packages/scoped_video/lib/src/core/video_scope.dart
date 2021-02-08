part of 'core.dart';

/// A widget that stores video states.
class VideoScope extends StatefulWidget {
  /// Creates a [VideoScope].
  ///
  /// [observers] and [child] must not be null.
  const VideoScope({
    Key key,
    this.overrides = const [],
    this.observers = const [],
    @required this.videoSources,
    @required this.child,
    this.autoPlay = true,
    this.lazy = false,
  })  : assert(overrides != null),
        assert(observers != null),
        assert(child != null),
        assert(autoPlay != null),
        assert(lazy != null),
        super(key: key);

  /// Provide videos sources.
  final List<String> videoSources;

  /// Should initialize video controller;
  final bool autoPlay;

  /// Should call play on video controller when is initialized.
  final bool lazy;

  /// List of objects that are redefining the meaning of refs.
  /// It can also be useful for test purposes.
  final List<ScopeOverride> overrides;

  /// Objects that can observe state changes.
  final List<StateObserver> observers;

  /// The subtree that can display videos.
  final Widget child;

  @override
  VideoScopeState createState() => VideoScopeState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>(
      'overrides',
      overrides.map((x) => x.key.name),
    ));
    properties.add(IterableProperty<String>(
      'observers',
      observers.map(describeIdentity),
    ));
  }
}

@visibleForTesting
class VideoScopeState extends State<VideoScope>
    with VideoContainerMixin, AutomaticKeepAliveClientMixin<VideoScope>
    implements Scope {
  final Set<RefKey> writtenKeys = <RefKey>{};
  bool clearScheduled = false;

  @override
  List<String> get videoSources => widget.videoSources;

  @override
  bool get autoPlay => widget.autoPlay;

  @override
  bool get lazy => widget.lazy;

  // Override listener logic if absent to initialize player controller
  // on widget creation.
  List<ScopeOverride> get _overrides {
    return widget.overrides.any((o) => o.key == videoListenerLogic.key)
        ? widget.overrides
        : [...widget.overrides, videoListenerLogic.overrideWithSelf()];
  }

  @override
  Map<RefKey, Object> states = <RefKey, Object>{};

  @override
  void initState() {
    super.initState();
    _overrides.forEach((override) {
      addWrittenKey(override.key);
      states[override.key] = override.create(this);
    });
  }

  @override
  void dispose() {
    states.values.whereType<Disposable>().forEach((state) => state.dispose());
    super.dispose();
  }

  /// Internal use only.
  @visibleForTesting
  VideoContainer createContainer() {
    return VideoContainer(states.clone());
  }

  @override
  void writeState<T>(StateRef<T> ref, T state, [Object action]) {
    addWrittenKey(ref.key);
    writeAndObserve(ref, state, action, widget.observers);
  }

  void addWrittenKey(RefKey key) {
    writtenKeys.add(key);
    if (!clearScheduled) {
      clearScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        clearScheduled = false;
        writtenKeys.clear();
      });
    }
  }

  /// Internal use only.
  @visibleForTesting
  void writeAndObserve<T>(
    StateRef<T> ref,
    T state,
    Object action,
    List<StateObserver> observers,
  ) {
    void applyNewState() {
      setState(() {
        states[ref.key] = state;
      });
    }

    final effectiveObservers = [...observers, ...widget.observers];

    if (effectiveObservers.isEmpty) {
      applyNewState();
    } else {
      final oldState =
          states.containsKey(ref.key) ? states[ref.key] as T : ref.initialState;
      applyNewState();
      effectiveObservers.any((observer) {
        return observer.didChanged(ref, oldState, state, action);
      });
    }
  }

  @override
  void clearState<T>(StateRef<T> ref) {
    final key = ref.key;
    setState(() {
      addWrittenKey(key);
      states.remove(key);
    });
  }

  @override
  T useState<T>(Watchable<T> ref) {
    return ref.read(fetch);
  }

  @override
  T useLogic<T>(LogicRef<T> ref) {
    return states.putIfAbsent(ref.key, () => ref.create(this)) as T;
  }

  @override
  bool get wantKeepAlive => true;

  Set<RefKey> get allWrittenKeys => writtenKeys.toSet();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InheritedVideoScope(
      container: createContainer(),
      scope: this,
      writtenKeys: allWrittenKeys,
      child: widget.child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    states.forEach((key, state) {
      properties.add(DiagnosticsProperty(key.name, state));
    });
  }
}

extension on Map<RefKey, Object> {
  Map<RefKey, Object> clone() => Map<RefKey, Object>.from(this);
}

/// Interface for business logic components that need to do some action before
/// their state is disposed.
abstract class Disposable {
  void dispose();
}
