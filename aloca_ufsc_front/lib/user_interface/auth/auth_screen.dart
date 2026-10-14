import 'package:flutter/material.dart';

import '../../models/api_model.dart';
import '../../models/auth_model.dart';
import '../../../theme.dart';
import '../../../widgets.dart';
import '../../../main.dart'; 
import '../../../shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _loading = false;
  Entity _typeSelected = Entity.student; 

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _idController = TextEditingController(); 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final dynamic response;

    if (_isLogin) {
      final loginReq = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      response = await appState.login(loginReq);
    } else {
      final signUpReq = SignUpRequest(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        entity: _typeSelected.name.toUpperCase(),
      );
      response = await appState.register(signUpReq);
    }

    if (!mounted) return;

    if (response.isError) {
      if (response.error == ApiError.invalidEmailOrPassword) {
        showToast(context, "Senha ou Email incorretos");
      } else if (response.error == ApiError.signUpError) {
        showToast(context, "Erro ao tentar cadastrar o usuário");
      } else {
        showToast(context, response.error.toString().replaceFirst('Exception: ', ''));
      }
      
      setState(() => _loading = false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isLogin
              ? 'Login realizado com sucesso.'
              : 'Cadastro realizado com sucesso.',
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Icon(Icons.school_outlined, size: 48, color: AppColors.mainBlue),
                    const SizedBox(height: 12),
                    const Text(
                      'AlocaUFSC',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainBlue,
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

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(child: _modeButton('Entrar', true)),
                          Expanded(child: _modeButton('Cadastrar', false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (!_isLogin) ...[
                      textField(
                        controller: _nameController,
                        label: 'Nome completo',
                        validator: _requiredField,
                      ),
                      const SizedBox(height: 16),
                      textField(
                        controller: _idController,
                        label: 'Matrícula / SIAPE',
                        validator: _requiredField,
                        keyboard: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Text('Você é...', style: _labelStyle),
                      const SizedBox(height: 8),
                      _profileSelector(),
                      const SizedBox(height: 16),
                    ],

                    textField(
                      controller: _emailController,
                      label: 'E-mail',
                      keyboard: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    textField(
                      controller: _passwordController,
                      label: 'Senha',
                      dim: true,
                      validator: _validatePassword,
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      textField(
                        controller: _passwordConfirmController,
                        label: 'Confirmar senha',
                        dim: true,
                        validator: _validatePasswordConfirm,
                      ),
                    ],

                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _loading ? null : _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
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

  Widget _modeButton(String text, bool isLogin) {
    final selected = _isLogin == isLogin;
    return GestureDetector(
      onTap: () => setState(() => _isLogin = isLogin),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.mainBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.mainBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _profileSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Entity.values.map((tipo) {
        final selected = tipo == _typeSelected;
        return ChoiceChip(
          label: Text(tipo.label), 
          selected: selected,
          onSelected: (_) => setState(() => _typeSelected = tipo),
          selectedColor: AppColors.mainBlue,
          backgroundColor: AppColors.secondaryBlue,
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.mainBlue,
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

  TextStyle get _labelStyle => const TextStyle(
        fontSize: 13,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      );

  String? _requiredField(String? valor) =>
      (valor == null || valor.trim().isEmpty) ? 'Campo obrigatório' : null;

  String? _validateEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu e-mail';
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!regex.hasMatch(valor.trim())) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha';
    if (!_isLogin && valor.length < 6) return 'Mínimo de 6 caracteres';
    return null;
  }

  String? _validatePasswordConfirm(String? valor) {
    if (valor != _passwordController.text) return 'As senhas não coincidem';
    return null;
  }
}
