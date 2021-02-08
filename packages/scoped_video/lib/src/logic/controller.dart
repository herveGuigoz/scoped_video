part of 'logic.dart';

class VideoControllerLogic with Logic {
  VideoControllerLogic(this.scope);

  @override
  final Scope scope;

  VideoController get _controller => useState(videoControllerRef);

  void playOrPauseVideo() => _controller.value.isPlaying ? pause() : play();

  Future<void> play() async => _controller.play();

  Future<void> pause() async => _controller.pause();

  Future<void> seekTo(Duration position) async => _controller.seekTo(position);
}
