import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

/// Sound of the room and the roulette, the same as the landing of the PWA (`sonido-mesa.ts`):
/// the room tone and the lamp hum, the ball rolling and clicking on the frets, and its fall
/// into the pocket. The ambience and the table sounds turn on apart; nothing plays until the
/// player turns it on.
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

  /// The ball against a fret: [strength] from 0 to 1 and [tone] the center of the click in
  /// Hz, from 3600 on the track down to 2700 among the pockets, 1700 for a bounce.
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

/// [TableSound] with the WAV files of `assets/sonidos/`, made by `tool/sonidos_mesa.py`,
/// played by SoLoud: a game audio engine whose loops have no seam and whose sounds start
/// at once, so the clicks follow the ball and stop with it.
class AudioTableSound implements TableSound {
  AudioTableSound({math.Random? random}) : _random = random ?? math.Random();

  static const _folder = 'assets/sonidos';

  /// Tones of the click files, in Hz; three takes of each.
  static const _tones = [3600, 3300, 3000, 2700, 1700];
  static const _takes = 3;

  /// Level of the ambience against the ball.
  static const _ambienceGain = 0.6;

  final math.Random _random;
  final _soloud = SoLoud.instance;
  Future<void>? _loading;
  bool _loaded = false;

  AudioSource? _ambienceSource;
  AudioSource? _rollHigh;
  AudioSource? _rollLow;
  AudioSource? _fall;
  AudioSource? _switchOn;
  final _clicks = <int, List<AudioSource>>{};

  SoundHandle? _ambience;
  SoundHandle? _rollingHigh;
  SoundHandle? _rollingLow;

  bool _ambienceOn = false;
  bool _effectsOn = false;
  bool _paused = false;
  double _volume = 0.6;

  /// Each sound plays only while it is on and the app is in the foreground.
  bool get _ambienceAudible => _ambienceOn && !_paused;
  bool get _effectsAudible => _effectsOn && !_paused && _loaded;

  @override
  Future<void> configure({
    required bool ambience,
    required bool effects,
    required double volume,
  }) async {
    final turnedOn = ambience && !_ambienceOn;
    _ambienceOn = ambience;
    _effectsOn = effects;
    _volume = volume;
    if (!effects) stopRoll();
    if (ambience || effects) {
      await _safeAsync(_prepare);
      if (!_loaded) return;
    }
    _safe(() {
      _applyAmbience();
      // The lamp switching on, as in the PWA.
      if (turnedOn && _ambienceAudible) _play(_switchOn, 1);
    });
  }

  @override
  Future<void> pause() async {
    _paused = true;
    stopRoll();
    _safe(() {
      final handle = _ambience;
      if (handle != null) _soloud.setPause(handle, true);
    });
  }

  @override
  Future<void> resume() async {
    _paused = false;
    _safe(() {
      final handle = _ambience;
      if (handle != null && _soloud.getIsValidVoiceHandle(handle)) {
        _soloud.setPause(handle, false);
      }
      _applyAmbience();
    });
  }

  @override
  void click(double strength, {double tone = 3000}) {
    if (!_effectsAudible) return;
    var nearest = _tones.first;
    for (final t in _tones) {
      if ((t - tone).abs() < (nearest - tone).abs()) nearest = t;
    }
    final takes = _clicks[nearest]!;
    _safe(() => _play(takes[_random.nextInt(takes.length)], strength));
  }

  @override
  void roll(double speed, double amongFrets) {
    if (!_effectsAudible) return;
    _safe(() {
      _rollingHigh ??= _soloud.play(_rollHigh!, volume: 0, looping: true);
      _rollingLow ??= _soloud.play(_rollLow!, volume: 0, looping: true);
      // The PWA lowers a filter from 380 to 180 Hz as the ball slows: here the high and
      // the low rumble trade places.
      final level = _volume * speed * (1 - 0.5 * amongFrets);
      const glide = Duration(milliseconds: 100);
      _soloud
        ..fadeVolume(_rollingHigh!, level * speed, glide)
        ..fadeVolume(_rollingLow!, level * (1 - speed), glide);
    });
  }

  @override
  void stopRoll() {
    final handles = <SoundHandle>[?_rollingHigh, ?_rollingLow];
    _rollingHigh = null;
    _rollingLow = null;
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
    if (_effectsAudible) _safe(() => _play(_fall, 1));
  }

  @override
  Future<void> dispose() async {
    if (_soloud.isInitialized) _safe(_soloud.deinit);
  }

  /// Loads the files the first time a sound turns on.
  Future<void> _prepare() => _loading ??= _load();

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
    if (!_soloud.isInitialized) await _soloud.init();

    Future<AudioSource> load(String name) =>
        _soloud.loadAsset('$_folder/$name.wav');
    _ambienceSource = await load('ambiente');
    _rollHigh = await load('rodado_agudo');
    _rollLow = await load('rodado_grave');
    _fall = await load('caida');
    _switchOn = await load('encendido');
    for (final tone in _tones) {
      _clicks[tone] = [
        for (var take = 1; take <= _takes; take++)
          await load('clic_${tone}_$take'),
      ];
    }
    _loaded = true;
  }

  void _applyAmbience() {
    final handle = _ambience;
    if (_ambienceAudible) {
      final level = _volume * _ambienceGain;
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

  void _play(AudioSource? source, double strength) {
    if (source == null) return;
    _soloud.play(source, volume: _volume * strength);
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
