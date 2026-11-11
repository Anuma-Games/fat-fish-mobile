part of 'my_player_cubit.dart';

sealed class MyPlayerState extends Equatable {
  const MyPlayerState();

  @override
  List<Object?> get props => [];
}

/// Reading the saved player from the device.
final class MyPlayerLoading extends MyPlayerState {
  const MyPlayerLoading();
}

/// No player chosen on this device yet.
final class MyPlayerNone extends MyPlayerState {
  const MyPlayerNone();
}

final class MyPlayerChosen extends MyPlayerState {
  const MyPlayerChosen(this.player);

  final PlayerSummary player;

  @override
  List<Object?> get props => [player];
}
