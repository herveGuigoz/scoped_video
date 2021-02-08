import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part '../models.freezed.dart';

abstract class VideoState {}

@freezed
abstract class PlayerState extends VideoState with _$PlayerState {
  factory PlayerState.playing() = Playing;
  factory PlayerState.paused() = Paused;
  factory PlayerState.buffering() = Buffering;
}

@freezed
abstract class PlayerStatus extends VideoState implements _$PlayerStatus {
  factory PlayerStatus.initialization() = PlayerStatusInitialization;
  factory PlayerStatus.initialized() = PlayerStatusInitialized;
  factory PlayerStatus.error() = PlayerStatusError;
  factory PlayerStatus.done() = PlayerStatusDone;
}

@freezed
abstract class Frames extends VideoState implements _$Frames {
  factory Frames({
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(Duration.zero) Duration lastFrame,
  }) = _Frames;
}
