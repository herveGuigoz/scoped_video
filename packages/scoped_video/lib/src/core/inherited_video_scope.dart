part of 'core.dart';

class InheritedVideoScope extends InheritedWidget {
  const InheritedVideoScope({
    Key key,
    @required this.container,
    @required this.scope,
    @required this.writtenKeys,
    @required Widget child,
  })  : assert(container != null),
        assert(child != null),
        assert(writtenKeys != null),
        super(key: key, child: child);

  final VideoContainer container;
  final Scope scope;
  final Set<RefKey> writtenKeys;

  @override
  InheritedElement createElement() => InheritedVideoScopeElement(this);

  @override
  bool updateShouldNotify(InheritedVideoScope oldWidget) {
    return oldWidget.container != container;
  }

  bool updateShouldNotifyDependent(
    InheritedVideoScope oldWidget,
    Dependencies dependencies,
  ) {
    final oldReader = oldWidget.container.fetch;
    final newReader = container.fetch;

    return dependencies.aspects.where((aspect) {
      // We only test the impacted aspects.
      return aspect.ref.keys.any((key) => writtenKeys.contains(key));
    }).any((aspect) {
      return aspect.shouldRebuild(oldReader, newReader);
    });
  }

  static InheritedVideoScope of(BuildContext context, [Aspect aspect]) {
    return context.dependOnInheritedWidgetOfExactType<InheritedVideoScope>(
      aspect: aspect,
    );
  }
}

/// An [Element] that uses a [InheritedModel] as its configuration.
class InheritedVideoScopeElement extends InheritedElement {
  /// Creates an element that uses the given widget as its configuration.
  InheritedVideoScopeElement(InheritedVideoScope widget) : super(widget);

  @override
  InheritedVideoScope get widget => super.widget as InheritedVideoScope;

  @override
  void updateDependencies(Element dependent, Object aspect) {
    final dependencies = getDependencies(dependent) as Dependencies;
    if (dependencies != null && dependencies.isEmpty) {
      return;
    }

    if (aspect == null) {
      setDependencies(dependent, Dependencies());
    } else {
      setDependencies(
          dependent, (dependencies ?? Dependencies())..add(aspect as Aspect));
    }
  }

  @override
  void notifyDependent(InheritedVideoScope oldWidget, Element dependent) {
    final dependencies = getDependencies(dependent) as Dependencies;
    if (dependencies == null) {
      return;
    }
    if (dependencies.isEmpty ||
        widget.updateShouldNotifyDependent(oldWidget, dependencies)) {
      dependent.didChangeDependencies();
    }
  }
}

class Dependencies {
  Dependencies([List<Aspect> aspects]) : aspects = aspects ?? <Aspect>[];

  final List<Aspect> aspects;
  bool shouldClearAspects = false;
  bool shouldClearAspectsScheduled = false;

  bool get isEmpty => aspects.isEmpty;

  void add(Aspect aspect) {
    // We need to clear the aspects between two rebuilds
    // because otherwise we may have memory leaks.
    if (shouldClearAspects) {
      shouldClearAspects = false;
      aspects.clear();
    }

    // We only want the cleaning to occur one time.
    if (!shouldClearAspectsScheduled) {
      shouldClearAspectsScheduled = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        shouldClearAspects = true;
        shouldClearAspectsScheduled = false;
      });
    }

    aspects.add(aspect);
  }
}

@immutable
@visibleForTesting
class Aspect<T> {
  const Aspect(this.ref);

  final Watchable<T> ref;

  bool shouldRebuild(StateReader oldReader, StateReader newReader) {
    final oldState = ref.read(oldReader);
    final newState = ref.read(newReader);
    final result = !ref.equals(oldState, newState);

    return result;
  }
}
