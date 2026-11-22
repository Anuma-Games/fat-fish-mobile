import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Calm GameSynth music and the recorded roulette bank used by the game:
/// the ball rolling and clicking on the frets, and its fall into the pocket.
/// The background and the table sounds turn on apart; nothing plays until the player turns it on.
abstract interface class TableSound {
  /// Turns the background [ambience] and the [effects] of the table on or off and sets
  /// their level, from 0 to 1.
  Future<void> configure({
    required bool ambience,
    required bool effects,
    required double volume,
  });

  /// While the app is in the background nothing plays.
  Future<void> pause();
  Future<void> resume();

  /// The croupier releasing the ball, once at the start of an animated spin.
  void launch();

  /// A recorded impact, with [strength] from 0 to 1. [tone] is the animation's
  /// contact hint: 3600 for a light fret touch, 2700 for a full one, 1700 for wood.
  void click(double strength, {double tone = 3000});

  /// The rumble of the wheel under the ball: [speed] from 1 (just thrown) to 0, and
  /// [amongFrets] from 0 (on the track) to 1 (among the pockets), where it gets quieter.
  void roll(double speed, double amongFrets);
  void stopRoll();

  /// The ball settling in its pocket.
  void fall();

  Future<void> dispose();
}

/// No sound at all: widget tests, and devices where audio fails.
class SilentTableSound implements TableSound {
  const SilentTableSound();

  @override
  Future<void> configure({
    required bool ambience,
    required bool effects,
    required double volume,
  }) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> resume() async {}
  @override
  void launch() {}
  @override
  void click(double strength, {double tone = 3000}) {}
  @override
  void roll(double speed, double amongFrets) {}
  @override
  void stopRoll() {}
  @override
  void fall() {}
  @override
  Future<void> dispose() async {}
}

/// [TableSound] with the WAV files of `assets/sonidos/`, including the game's
/// original recordings in `roulette/`, imported by `tool/import_roulette.py`,
/// played by SoLoud: a game audio engine whose loops have no seam and whose sounds start
/// at once, so the clicks follow the ball and stop with it.
class AudioTableSound implements TableSound {
  AudioTableSound({math.Random? random}) : _random = random ?? math.Random();

  static const _folder = 'assets/sonidos';

  static const _hitCount = 14;
  // A softer, steady rolling texture underneath the recorded impacts.
  static const _rollGain = 0.35;
  static const _hitGain = 0.6;

  /// Level of the ambience against the ball.
  static const _ambienceGain = 0.6;

  final math.Random _random;
  final _soloud = SoLoud.instance;
  Future<void>? _loading;
  bool _loaded = false;

  AudioSource? _ambienceSource;
  AudioSource? _roll;
  AudioSource? _launch;
  AudioSource? _fall;
  AudioSource? _switchOn;
  final _hits = <AudioSource>[];
  int _lastHit = -1;

  SoundHandle? _ambience;
  SoundHandle? _rolling;

  bool _ambienceOn = false;
  bool _effectsOn = false;
  bool _paused = false;
  bool _interrupted = false;
  double _volume = 0.6;
  StreamSubscription<AudioInterruptionEvent>? _interruptions;

  /// In the background, or during a call: nothing plays.
  bool get _held => _paused || _interrupted;

  /// Each sound plays only while it is on and the app is in the foreground.
  bool get _ambienceAudible => _ambienceOn && !_held;
  bool get _effectsAudible => _effectsOn && !_held && _loaded;

  @override
  Future<void> configure({
    required bool ambience,
    required bool effects,
    required double volume,
  }) async {
    final turnedOn = ambience && !_ambienceOn;
    final turnedOff = (_ambienceOn && !ambience) || (_effectsOn && !effects);
    _ambienceOn = ambience;
    _effectsOn = effects;
    _volume = volume.clamp(0, 1);
    if (turnedOff) {
      _hold();
    } else if (!effects) {
      stopRoll();
    }
    if (ambience || effects) {
      await _safeAsync(_prepare);
      if (!_loaded) return;
    }
    _safe(() {
      // One master level also changes short sounds that are already playing.
      if (_loaded) _soloud.setGlobalVolume(_volume);
      _applyAmbience();
      // The lamp switching on, as in the PWA.
      if (turnedOn && _ambienceAudible) _play(_switchOn, 1);
    });
  }

  @override
  Future<void> pause() async {
    _paused = true;
    _hold();
  }

  @override
  Future<void> resume() async {
    _paused = false;
    _release();
  }

  /// A call or another app took the audio: silence until it gives it back.
  void _interrupt({required bool begin}) {
    _interrupted = begin;
    if (begin) {
      _hold();
    } else {
      unawaited(_safeAsync(_soloud.startAudioDevice));
      _release();
    }
  }

  void _hold() {
    _ambience = null;
    _rolling = null;
    _safe(() {
      // Stop transient clicks, the fall and the lamp relay too, not just loops.
      if (_loaded) _soloud.stopAll();
    });
  }

  void _release() {
    if (_held || !_loaded) return;
    _safe(_applyAmbience);
  }

  @override
  void launch() {
    if (_effectsAudible) _safe(() => _play(_launch, 0.7 * _hitGain));
  }

  @override
  void click(double strength, {double tone = 3000}) {
    if (!_effectsAudible) return;
    final index = _lastHit < 0
        ? _random.nextInt(_hits.length)
        : (_lastHit + 1 + _random.nextInt(_hits.length - 1)) % _hits.length;
    _lastHit = index;
    final force = strength.clamp(0.0, 1.0);
    final wood = tone <= 1800;
    final gain = wood ? 0.15 + 0.45 * force : 0.4 + 0.6 * force;
    final pitch =
        (0.96 + 0.1 * _random.nextDouble()) *
        (wood ? 0.74 : (tone >= 3300 ? 1.04 : 1.0));
    _safe(() => _play(_hits[index], gain * _hitGain, pitch: pitch));
  }

  @override
  void roll(double speed, double amongFrets) {
    if (!_effectsAudible) return;
    _safe(() {
      _rolling ??= _soloud.play(_roll!, volume: 0, looping: true);
      final pace = speed.clamp(0.0, 1.0);
      final level =
          _rollGain * (0.45 + 0.55 * pace) * (1 - amongFrets.clamp(0.0, 1.0));
      // Keep the recording's natural pitch instead of a sweeping effect.
      // Only the level follows the ball and fades on descent.
      _soloud.fadeVolume(_rolling!, level, const Duration(milliseconds: 100));
    });
  }

  @override
  void stopRoll() {
    final handles = <SoundHandle>[?_rolling];
    _rolling = null;
    _safe(() {
      for (final handle in handles) {
        _soloud
          ..fadeVolume(handle, 0, const Duration(milliseconds: 80))
          ..scheduleStop(handle, const Duration(milliseconds: 100));
      }
    });
  }

  @override
  void fall() {
    if (_effectsAudible) _safe(() => _play(_fall, 0.6 * _hitGain));
  }

  @override
  Future<void> dispose() async {
    await _interruptions?.cancel();
    if (_soloud.isInitialized) _safe(_soloud.deinit);
  }

  /// Loads the files the first time a sound turns on. A failed load is tried again
  /// the next time, instead of leaving the app silent until it restarts.
  Future<void> _prepare() => _loading ??= _load().catchError((Object error) {
    _loading = null;
    throw error;
  });

  Future<void> _load() async {
    // Ambient: mixes with other apps and keeps quiet with the silent switch.
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.game,
        ),
        androidWillPauseWhenDucked: true,
      ),
    );
    _interruptions ??= session.interruptionEventStream.listen(
      (event) => _interrupt(begin: event.begin),
    );
    if (!_soloud.isInitialized) await _soloud.init();
    // Leave the mix below full scale when clicks overlap. Threshold 0 avoids
    // the limiter's automatic makeup gain; the WAVs already have their gain.
    final limiter = _soloud.filters.limiterFilter;
    limiter.activate();
    limiter.threshold.value = 0;
    limiter.outputCeiling.value = -1;

    Future<AudioSource> load(String name) =>
        _soloud.loadAsset('$_folder/$name.wav');
    _ambienceSource = await load('ambiente');
    _roll = await load('roulette/roll');
    _launch = await load('roulette/launch');
    _fall = await load('roulette/settle');
    _switchOn = await load('encendido');
    _hits.clear();
    for (var i = 1; i <= _hitCount; i++) {
      _hits.add(await load('roulette/hit_${i.toString().padLeft(2, '0')}'));
    }
    _loaded = true;
  }

  void _applyAmbience() {
    final handle = _ambience;
    if (_ambienceAudible) {
      const level = _ambienceGain;
      if (handle == null || !_soloud.getIsValidVoiceHandle(handle)) {
        // Fades in like the PWA, without a jump.
        final started = _soloud.play(
          _ambienceSource!,
          volume: 0,
          looping: true,
        );
        _ambience = started;
        _soloud.fadeVolume(started, level, const Duration(milliseconds: 300));
      } else {
        _soloud.fadeVolume(handle, level, const Duration(milliseconds: 100));
      }
    } else if (handle != null && !_ambienceOn) {
      _ambience = null;
      _soloud
        ..fadeVolume(handle, 0, const Duration(milliseconds: 150))
        ..scheduleStop(handle, const Duration(milliseconds: 200));
    }
  }

  void _play(AudioSource? source, double strength, {double pitch = 1}) {
    if (source == null) return;
    final handle = _soloud.play(source, volume: strength, paused: pitch != 1);
    if (pitch != 1) {
      _soloud
        ..setRelativePlaySpeed(handle, pitch)
        ..setPause(handle, false);
    }
  }

  /// Sound is an extra: a failure is logged and the app goes on in silence.
  static void _safe(void Function() action) {
    try {
      action();
    } on Object catch (error) {
      debugPrint('TableSound: $error');
    }
  }

  static Future<void> _safeAsync(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error) {
      debugPrint('TableSound: $error');
    }
  }
}
