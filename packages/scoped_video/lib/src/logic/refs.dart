part of 'logic.dart';

final videoControllerRef = StateRef<VideoController>(null);

final videoSourcesRef = StateRef<List<String>>(null);

final playerStateRef = StateRef<PlayerState>(PlayerState.buffering());

final playerStatusRef = StateRef<PlayerStatus>(PlayerStatus.initialization());

final framesRef = StateRef<Frames>(Frames(), name: 'durationsRef');

final overlayVisibilityRef = StateRef(false, name: 'overlayVisibility');

final videoListenerLogic = LogicRef<VideoListenerLogicInterface>((scope) {
  return MainVideoListenerLogic(
    scope,
    dataSources: scope.videoSources,
    autoplay: scope.autoPlay,
    lazy: scope.lazy,
  );
}, name: 'videoListenerLogic');

final videoControllerLogic = LogicRef<VideoControllerLogic>((scope) {
  return VideoControllerLogic(scope);
});
