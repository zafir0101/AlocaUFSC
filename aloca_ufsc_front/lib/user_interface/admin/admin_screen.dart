import 'package:aloca_ufsc_front/user_interface/admin/admin_allocation_tab.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../allocation/venue_admin_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Administração',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.mainBlue),
          ),
          bottom: const TabBar(
            labelColor: AppColors.mainBlue,
            indicatorColor: AppColors.mainBlue,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Espaços'),
              Tab(text: 'Solicitações'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            VenueAdminScreen(),
            AdminAllocationsTab(),
          ],
        ),
      ),
    );
  }
}

