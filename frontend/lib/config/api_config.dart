class ApiConfig {
  // Base URL for API requests
  static const String baseUrl = 'http://localhost:5000';

  // API endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String stockHistoryEndpoint = '/api/price/stock-history';
  static const String backtestingEndpoint = '/backtesting';

  // Request timeouts in seconds
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
