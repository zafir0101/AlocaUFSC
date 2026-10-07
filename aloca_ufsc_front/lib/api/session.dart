// Sessão do usuário logado, mantida só em memória por enquanto.
class Session {
  Session._();

  static String? token;
  static String? userName;

  static void clear() {
    token = null;
    userName = null;
  }
}