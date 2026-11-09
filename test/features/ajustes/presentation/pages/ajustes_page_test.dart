import 'package:drift/native.dart';
import 'package:fat_fish_mobile/core/storage/app_database.dart';
import 'package:fat_fish_mobile/features/ajustes/data/datasources/settings_local_data_source.dart';
import 'package:fat_fish_mobile/features/ajustes/data/repositories/settings_repository_impl.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/get_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/domain/usecases/save_settings.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/pages/ajustes_page.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/widgets/pixel_switch.dart';
import 'package:fat_fish_mobile/features/ajustes/presentation/widgets/volume_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SettingsCubit cubit;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    final repository = SettingsRepositoryImpl(
      local: SettingsLocalDataSource(db),
    );
    cubit = SettingsCubit(
      getSettings: GetSettings(repository),
      saveSettings: SaveSettings(repository),
    );
  });
  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  Future<void> pumpAjustes(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: AjustesPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('three switches: ambience, table sounds and vibration', (
    tester,
  ) async {
    await pumpAjustes(tester);
    expect(find.byType(PixelSwitch), findsNWidgets(3));
    expect(cubit.state.ambienceOn, isFalse);
    expect(cubit.state.tableSoundsOn, isFalse);

    await tester.tap(find.bySemanticsLabel('Ambiente de fondo'));
    await tester.pumpAndSettle();
    expect(cubit.state.ambienceOn, isTrue);
    expect(cubit.state.tableSoundsOn, isFalse);

    await tester.tap(find.bySemanticsLabel('Sonidos de la mesa'));
    await tester.tap(find.bySemanticsLabel('Vibración'));
    await tester.pumpAndSettle();
    expect(cubit.state.tableSoundsOn, isTrue);
    expect(cubit.state.vibration, isFalse);
  });

  testWidgets('the volume moves by taps and by the screen reader', (
    tester,
  ) async {
    await pumpAjustes(tester);
    expect(find.text('60 %'), findsOneWidget);

    // The last block is full volume.
    final bar = find.bySemanticsLabel('Volumen');
    await tester.tapAt(tester.getTopRight(bar) + const Offset(-1, 20));
    await tester.pump();
    expect(cubit.state.volume, 10);
    expect(find.text('100 %'), findsOneWidget);

    // What a screen reader calls when the player swipes down on the slider.
    tester
        .widget<Semantics>(
          find
              .descendant(
                of: find.byType(VolumeBar),
                matching: find.byType(Semantics),
              )
              .first,
        )
        .properties
        .onDecrease!();
    await tester.pump();
    expect(cubit.state.volume, 9);
  });

  testWidgets('shows the help line', (tester) async {
    await pumpAjustes(tester);

    expect(find.text('Línea de la Vida: 800 911 2000'), findsOneWidget);
    expect(AjustesPage.helpLine.toString(), 'tel:8009112000');
  });
}
