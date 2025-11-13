class ApiConfig {

  static const String baseUrl = 'http://192.168.2.3:6768';
  
  static const String clienteBasePath = '/api/cliente';
  static const String elevadorBasePath = '/api/elevador';
  
  static String get clienteUrl => '$baseUrl$clienteBasePath';
  static String get elevadorUrl => '$baseUrl$elevadorBasePath';
}

