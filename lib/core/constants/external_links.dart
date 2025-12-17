class ExternalLinks {
  static const String devUrl = 'http://10.0.2.2:3000/api/v1';

  static const String prodUrl =
      'https://pdf-tools-backend-gyoh.onrender.com/api/v1';

  static const bool useProduction = true;

  static String get baseUrl => useProduction ? prodUrl : devUrl;
}
