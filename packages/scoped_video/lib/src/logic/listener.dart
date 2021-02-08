part of 'logic.dart';

/// Part of VideoScope logic.
/// Listen for video controller in order to update states accordingly.
abstract class VideoListenerLogicInterface with Logic implements Disposable {
  VideoListenerLogicInterface() {
    initialize();
  }

  @protected
  VideoController get controller;

  @protected
  @nonVirtual
  void updateStates() {
    updateVideoState();
    updateVideoStatus();
    updateVideoFrames();
  }

  @protected
  void updateVideoState() {
    updateState<PlayerState>(playerStateRef, (_) => controller.state);
  }

  @protected
  void updateVideoStatus() {
    updateState<PlayerStatus>(playerStatusRef, (_) => controller.status);
  }

  @protected
  void updateVideoFrames() {
    updateState<Frames>(durationsRef, (_) => controller.durations);
  }

  @protected
  @mustCallSuper
  void initialize() {
    writeState(videoControllerRef, controller);
    controller.addListener(updateStates);
  }

  @override
  @protected
  @mustCallSuper
  void dispose() {
    controller.removeListener(updateStates);
  }
}

/// Part of video scope logic.
/// This object initalize and dispose video controller.
///
/// Video trimming view use another video scope so the method pushToTrimmer
/// is use to cancel states updates on current scope during video trimming.
class MainVideoListenerLogic extends VideoListenerLogicInterface {
  MainVideoListenerLogic(
    this.scope, {
    @required this.dataSources,
    @required this.autoplay,
    @required this.lazy,
  }) : controller = VideoController.network(dataSources.first);

  @override
  final Scope scope;

  /// Provide videos sources.
  final List<String> dataSources;

  /// Should initialize video controller;
  final bool lazy;

  /// Should call play on video controller when is initialized.
  final bool autoplay;

  @override
  final VideoController controller;

  @override
  void initialize() {
    super.initialize();
    if (!lazy) {
      controller.initialize().then((_) {
        if (autoplay) controller.play();
      });
    }
  }

  Future<void> pushToTrimmer(
    Future<void> Function(VideoController controller) callback,
  ) async {
    controller.removeListener(updateStates);
    await callback(controller);
    updateStates();
    controller.addListener(updateStates);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  String toString() => 'VideoViewLogic(dataSources: $dataSources)';
}
