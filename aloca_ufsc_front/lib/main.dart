import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme.dart';
import 'user_interface/auth/auth_screen.dart';

void main() {
  runApp(const AlocaUFSC());
}

class AlocaUFSC extends StatelessWidget {
  const AlocaUFSC({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Começa no login: os eventos precisam saber quem é o usuário. Depois do login vai para o RootShell.
      home: const AuthScreen(),
      title: 'Aloca UFSC',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}