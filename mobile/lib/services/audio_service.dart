import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../data/session_store.dart';

/// Audio & haptics never affect the offline railway simulation.
class GameAudio {
  GameAudio(this.store) { store.addListener(refresh); }

  final SessionStore store;
  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _wheels = AudioPlayer();
  final AudioPlayer _effects = AudioPlayer();
  bool _inGame = false;
  bool _moving = false;
  bool _menuPlaying = false;
  bool _trainPlaying = false;
  bool _disposed = false;

  void showMenu() {
    _inGame = false;
    _moving = false;
    refresh();
  }
  void showGame() {
    _inGame = true;
    refresh();
  }
  void setMoving(bool moving) {
    if (_moving == moving) return;
    _moving = moving;
    refresh();
  }
  void refresh() {
    if (_disposed) return;
    final wantsMenu = !_inGame && store.musicEnabled &&
        store.masterVolume > .01;
    final wantsTrain = _inGame && _moving && store.trainSoundsEnabled &&
        store.masterVolume > .01;
    unawaited(_music.setVolume(store.masterVolume * .25));
    unawaited(_wheels.setVolume(store.masterVolume * .4));
    if (_menuPlaying != wantsMenu) {
      _menuPlaying = wantsMenu;
      unawaited(_switch(_music, wantsMenu, 'audio/menu_theme.wav'));
    }
    if (_trainPlaying != wantsTrain) {
      _trainPlaying = wantsTrain;
      unawaited(_switch(_wheels, wantsTrain, 'audio/train_wheels.wav'));
    }
  }
  Future<void> _switch(AudioPlayer player, bool on, String file) async {
    try {
      if (!on) { await player.stop(); return; }
      await player.setReleaseMode(ReleaseMode.loop);
      if (_disposed) return;
      await player.play(AssetSource(file));
      if (_disposed || file.contains('menu') && !_menuPlaying ||
          file.contains('wheels') && !_trainPlaying) {
        await player.stop();
      }
    } catch (_) { /* audio plugins are optional on some emulators */ }
  }
  Future<void> horn() async {
    if (_disposed || !store.trainSoundsEnabled) return;
    try {
      await _effects.setVolume(store.masterVolume * .48);
      await _effects.play(AssetSource('audio/train_horn.wav'));
    } catch (_) {}
  }
  Future<void> success() async {
    if (!_disposed && store.trainSoundsEnabled) {
      try {
        await _effects.setVolume(store.masterVolume * .42);
        await _effects.play(AssetSource('audio/success.wav'));
      } catch (_) {}
    }
    haptic(HapticStyle.success);
  }
  void haptic(HapticStyle style) {
    if (_disposed || !store.hapticsEnabled) return;
    final result = switch (style) {
      HapticStyle.tap => HapticFeedback.selectionClick(),
      HapticStyle.success => HapticFeedback.lightImpact(),
      HapticStyle.warning => HapticFeedback.heavyImpact(),
    };
    unawaited(result);
  }
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    store.removeListener(refresh);
    unawaited(_music.dispose());
    unawaited(_wheels.dispose());
    unawaited(_effects.dispose());
  }
}
enum HapticStyle { tap, success, warning }
