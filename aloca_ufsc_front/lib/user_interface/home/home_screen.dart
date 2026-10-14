import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../../theme.dart';
import '../notification/notification_bell.dart';
import '../../main.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

void _logout(BuildContext context) {
    appState.logout();
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(Icons.school_outlined, size: 36, color: AppColors.mainBlue),
                ),
                const Text(
                  'AlocaUFSC',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainBlue,
                  ),
                ),
              ]
            ),
            Row(
              children: [
                const NotificationBell(),
                IconButton(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.settings, size: 24, color: AppColors.mainBlue),
                  alignment: Alignment.topRight,
                ),
              ],
            ),
          ]   
        ),
      ),
    );
  }
}
