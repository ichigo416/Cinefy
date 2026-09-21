class AppConfig {
  const AppConfig();

  static const bool isRelease = bool.fromEnvironment('dart.vm.product');
  static const String environment = String.fromEnvironment(
    'CINEFY_ENVIRONMENT',
    defaultValue: isRelease ? 'production' : 'development',
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'CINEFY_API_BASE_URL',
    defaultValue: isRelease ? '' : 'http://10.0.2.2:8000/api/v1',
  );
  static const bool enableLogging = bool.fromEnvironment(
    'CINEFY_API_LOGGING',
    defaultValue: !isRelease,
  );
  static const bool enableMockData = bool.fromEnvironment(
    'CINEFY_MOCK_DATA',
    defaultValue: !isRelease,
  );
}
