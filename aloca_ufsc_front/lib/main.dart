import 'package:aloca_ufsc_front/models/api_model.dart';
import 'package:flutter/material.dart';

import 'theme.dart';
import 'shell.dart';
import 'state.dart';
import 'user_interface/auth/auth_screen.dart';
import 'user_interface/home/home_screen.dart';

final appState = AppState();

void main() {
    runApp(const AlocaUFSC());
}

class AlocaUFSC extends StatefulWidget {
    const AlocaUFSC({super.key});

    @override
      State<StatefulWidget> createState() => _AlocaUFSCState();
}

class _AlocaUFSCState extends State<AlocaUFSC> {
    late ApiRequest<void> _loginValidation;
    
    void initState() {
        super.initState();
        _loginValidation = appState.rememberMe();
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Aloca UFSC',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
            home: ListenableBuilder(
                listenable: appState.isLoggedIn,
                builder: (context, child) {
                    return Container(
                        color: AppColors.background,
                        child: FutureBuilder(
                            future: _loginValidation,
                            builder: (_, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                } else if (snapshot.connectionState == ConnectionState.done &&
                                    (snapshot.hasError || snapshot.data!.isError)) {
                                        return AuthScreen();
                                    }
                                return RootShell();
                            }
                        )
                    );
                }
            )
        );
    }
}


