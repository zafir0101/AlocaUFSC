import 'package:flutter/material.dart';

import 'theme.dart';
import 'shell.dart';
import 'user_interface/auth/auth_screen.dart';
import 'user_interface/home/home_screen.dart';

void main() {
    runApp(const AlocaUFSC());
}

class AlocaUFSC extends StatelessWidget {
    const AlocaUFSC({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            // home: AuthScreen(),
            home: RootShell(),
            title: 'Aloca UFSC',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(),
        );
    }
}


