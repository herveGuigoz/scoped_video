import 'package:video_player/video_player.dart';

import '../models/models.dart';

/// Reimplementation of Flutter [VideoPlayerController] to add utilities
/// on state and status observer.
class VideoController extends VideoPlayerController {
  /// Use network constructor to build video controller.
  VideoController.network(this.source) : super.network(source);

  /// Video url.
  final String source;

  bool _disposed = false;
  bool _hasError = false;

  @override
  Future<void> initialize() async {
    try {
      await super.initialize();
    } catch (error) {
      _hasError = true;
    }
  }

  /// Notify when player is on initilization, has error or initialized.
  PlayerStatus get status {
    if (value == null || !value.initialized) {
      return PlayerStatus.initialization();
    }

    if (_hasError || value.hasError) return PlayerStatus.error();

    if (value.position >= value.duration) return PlayerStatus.done();

    return PlayerStatus.initialized();
  }

  /// Notify when player is buffering, playing or paused.
  PlayerState get state {
    if (value.isBuffering) return PlayerState.buffering();

    return value.isPlaying ? PlayerState.playing() : PlayerState.paused();
  }

  /// Notify when current position is updated.
  Frames get durations {
    return Frames(
      position: value.position,
      duration: value.duration,
      lastFrame: _lastFrame,
    );
  }

  /// Notify last buffered frame to build progress bar indicator.
  Duration get _lastFrame {
    final buffered = value.buffered;
    if (buffered == null || buffered.isEmpty) return Duration.zero;

    final bufferedMilliseconds = buffered
        .map((e) => e.end.inMilliseconds - e.start.inMilliseconds)
        .toList()
        .reduce((a, b) => a + b);

    return Duration(milliseconds: bufferedMilliseconds.toInt());
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await super.dispose();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoController &&
        other.source == source &&
        other._disposed == _disposed &&
        other._hasError == _hasError;
  }

  @override
  int get hashCode => source.hashCode ^ _disposed.hashCode ^ _hasError.hashCode;

  @override
  String toString() => 'VideoController($source, _disposed: $_disposed)';
}
