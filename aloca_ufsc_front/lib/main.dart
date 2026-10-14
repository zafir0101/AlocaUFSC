import 'package:flutter/material.dart';

import 'theme.dart';
import 'shell.dart';
import 'user_interface/auth/auth_screen.dart';
import 'state.dart';
import 'models/api_model.dart';

final appState = AppState();

void main() {
  runApp(const AlocaUfscApp());
}

class AlocaUfscApp extends StatefulWidget {
  const AlocaUfscApp({super.key});

  @override
  State<AlocaUfscApp> createState() => _AlocaUfscAppState();
}

class _AlocaUfscAppState extends State<AlocaUfscApp> {
  late ApiRequest<void> _loginValidation;

  @override
  void initState() {
    super.initState();
    _loginValidation = appState.rememberMe();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlocaUFSC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.mainBlue,
        scaffoldBackgroundColor: AppColors.background,
      ),
            home: ListenableBuilder(
                listenable: appState.isLoggedIn,
                builder: (context, child) {
                    return Container(
                        color: AppColors.background,
                        child: FutureBuilder(
                            future: _loginValidation,
                            builder: (_, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (appState.isLoggedIn.value) {
                  return const RootShell();
                } else {
                  return const AuthScreen();
                }
                            },
                        ),
                    );
                },
            ),
        );
    }
}
