/// Paths shared by the router and the features. They live in core, so a feature can
/// navigate without importing the router, which imports every feature.
abstract final class AppRoutes {
  /// First screen without a saved player; outside the tabs.
  static const bienvenida = '/bienvenida';

  static const expediente = '/expediente';
  static const historial = '/expediente/historial';
  static const mesa = '/mesa';
  static const ranking = '/ranking';

  /// Search and choose a player. Opened over the tabs with `push`, so back returns.
  static const jugador = '/jugador';

  /// Sound, vibration and the help line. Opened over the tabs with `push`.
  static const ajustes = '/ajustes';
}
