/// Paths shared by the router and the features. They live in core, so a feature can
/// navigate without importing the router, which imports every feature.
abstract final class AppRoutes {
  static const expediente = '/expediente';
  static const historial = '/expediente/historial';
  static const ranking = '/ranking';
  static const jugador = '/jugador';
}
