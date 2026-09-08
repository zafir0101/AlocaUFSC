import 'package:aloca_ufsc_front/api/auth_service.dart';
import 'package:aloca_ufsc_front/user_interface/auth/auth_model.dart';
import 'package:aloca_ufsc_front/user_interface/home/home_screen.dart';
import 'package:flutter/material.dart';

import '../allocation/manage_venue/venue_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum Entity { discente, docente, organizacao, administrador }

extension EntityInfo on Entity {
  String get label {
    switch (this) {
      case Entity.discente:
        return 'Discente';
      case Entity.docente:
        return 'Docente';
      case Entity.organizacao:
        return 'Organização';
      case Entity.administrador:
        return 'Administrador';
    }
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _carregando = false;
  Entity _tipoSelecionado = Entity.discente;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _identificadorController = TextEditingController();

  static const Color azulPrincipal = Color(0xFF1565C0);
  static const Color azulClaro = Color(0xFFE8F1FB);

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _identificadorController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final AuthResponse response;

      if (_isLogin) {
        final loginReq = LoginRequest(
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        );
        response = await _authService.login(loginReq);
      } else {
        final signUpReq = SignUpRequest(
          nomeCompleto: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
          entity: _tipoSelecionado.name.toUpperCase(),
          identificador: _identificadorController.text.trim(),
        );
        response = await _authService.signUp(signUpReq);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Login realizado com sucesso.'
                : 'Cadastro realizado com sucesso.',
          ),
        ),
      );

      if (response.entity == 'ADMINISTRADOR') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const VenueScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (!mounted) return;

      final mensagemErro = e.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagemErro)),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Icon(Icons.school_outlined, size: 48, color: azulPrincipal),
                    const SizedBox(height: 12),
                    Text(
                      'AlocaUFSC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: azulPrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin
                          ? 'Entre com sua conta'
                          : 'Crie sua conta para participar',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Seletor Entrar / Cadastrar
                    Container(
                      decoration: BoxDecoration(
                        color: azulClaro,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(child: _botaoModo('Entrar', true)),
                          Expanded(child: _botaoModo('Cadastrar', false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!_isLogin) ...[
                      _campoTexto(
                        controller: _nomeController,
                        rotulo: 'Nome completo',
                        validator: _obrigatorio,
                      ),
                      const SizedBox(height: 16),
                      Text('Você é...', style: _rotuloEstilo),
                      const SizedBox(height: 8),
                      _seletorPerfil(),
                      const SizedBox(height: 16),
                    ],

                    _campoTexto(
                      controller: _emailController,
                      rotulo: 'E-mail',
                      teclado: TextInputType.emailAddress,
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 16),
                    _campoTexto(
                      controller: _senhaController,
                      rotulo: 'Senha',
                      obscuro: true,
                      validator: _validarSenha,
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      _campoTexto(
                        controller: _confirmarSenhaController,
                        rotulo: 'Confirmar senha',
                        obscuro: true,
                        validator: _validarConfirmacaoSenha,
                      ),
                    ],

                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _carregando ? null : _enviar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: azulPrincipal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(_isLogin ? 'Entrar' : 'Criar conta'),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botaoModo(String texto, bool ehLogin) {
    final selecionado = _isLogin == ehLogin;
    return GestureDetector(
      onTap: () => setState(() => _isLogin = ehLogin),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selecionado ? azulPrincipal : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          texto,
          style: TextStyle(
            color: selecionado ? Colors.white : azulPrincipal,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _seletorPerfil() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Entity.values.map((tipo) {
        final selecionado = tipo == _tipoSelecionado;
        return ChoiceChip(
          label: Text(tipo.label),
          selected: selecionado,
          onSelected: (_) => setState(() => _tipoSelecionado = tipo),
          selectedColor: azulPrincipal,
          backgroundColor: azulClaro,
          labelStyle: TextStyle(
            color: selecionado ? Colors.white : azulPrincipal,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide.none,
          ),
        );
      }).toList(),
    );
  }

  TextStyle get _rotuloEstilo => const TextStyle(
        fontSize: 13,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      );

  Widget _campoTexto({
    required TextEditingController controller,
    required String rotulo,
    bool obscuro = false,
    TextInputType teclado = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      validator: validator,
      decoration: InputDecoration(
        labelText: rotulo,
        filled: true,
        fillColor: azulClaro,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: azulPrincipal, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  String? _obrigatorio(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu e-mail';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(valor.trim())) return 'E-mail inválido';
    return null;
  }

  String? _validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    if (!_isLogin && valor.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  String? _validarConfirmacaoSenha(String? valor) {
    if (valor != _senhaController.text) return 'As senhas não coincidem';
    return null;
  }
}
