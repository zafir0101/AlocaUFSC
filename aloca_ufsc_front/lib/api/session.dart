class Session {
  Session._();

  static String? token;
  static String? userName;
  static String? role;

  static bool get isAdmin => role == 'ADMINISTRADOR';

  static void clear() {
    token = null;
    userName = null;
    role = null;
  }
}