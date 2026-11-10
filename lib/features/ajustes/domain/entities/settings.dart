import 'package:equatable/equatable.dart';

/// What the player chose in Ajustes. The defaults are the first visit: sound off.
class Settings extends Equatable {
  const Settings({
    this.ambienceOn = false,
    this.tableSoundsOn = false,
    this.volume = defaultVolume,
    this.vibration = true,
  });

  static const defaultVolume = 6;
  static const maxVolume = 10;

  /// Room tone and lamp hum, looping while the player browses.
  final bool ambienceOn;

  /// Clicks and roll of the ball and its fall into the pocket.
  final bool tableSoundsOn;

  /// Level from 0 to [maxVolume].
  final int volume;

  /// Light vibration when changing tabs and when the ball falls.
  final bool vibration;

  Settings copyWith({
    bool? ambienceOn,
    bool? tableSoundsOn,
    int? volume,
    bool? vibration,
  }) => Settings(
    ambienceOn: ambienceOn ?? this.ambienceOn,
    tableSoundsOn: tableSoundsOn ?? this.tableSoundsOn,
    volume: volume ?? this.volume,
    vibration: vibration ?? this.vibration,
  );

  @override
  List<Object?> get props => [ambienceOn, tableSoundsOn, volume, vibration];
}
