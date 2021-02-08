import 'package:flutter/foundation.dart';

class RefKey {
  const RefKey(this.name);
  final String name;
}

mixin VideoContainerMixin {
  Map<RefKey, Object> get states;

  T fetch<T>(RefKey key, T defaultState) {
    if (states.containsKey(key)) {
      return states[key] as T;
    } else {
      return defaultState;
    }
  }
}

@immutable
class VideoContainer with VideoContainerMixin {
  const VideoContainer(this.states);

  @override
  final Map<RefKey, Object> states;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoContainer && mapEquals(other.states, states);
  }

  @override
  int get hashCode => states.hashCode;
}
