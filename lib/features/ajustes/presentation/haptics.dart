import 'package:fat_fish_mobile/features/ajustes/presentation/cubit/settings_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Haptic feedback that honors the "Vibración" setting. Without a [SettingsCubit]
/// above (some tests) it vibrates.
abstract final class Haptics {
  static bool _enabled(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.vibration;
    } on ProviderNotFoundException {
      return true;
    }
  }

  static void selection(BuildContext context) {
    if (_enabled(context)) HapticFeedback.selectionClick();
  }

  static void light(BuildContext context) {
    if (_enabled(context)) HapticFeedback.lightImpact();
  }

  static void medium(BuildContext context) {
    if (_enabled(context)) HapticFeedback.mediumImpact();
  }
}
