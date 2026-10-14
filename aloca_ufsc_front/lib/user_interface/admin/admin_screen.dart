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
            // TODO(alocação): trocar pela tela de aprovação de solicitações de alocação.
            _AllocationRequestsPlaceholder(),
          ],
        ),
      ),
    );
  }
}

class _AllocationRequestsPlaceholder extends StatelessWidget {
  const _AllocationRequestsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fact_check_outlined, size: 64, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text('Nenhuma solicitação', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 4),
          Text('As solicitações de alocação aparecerão aqui.', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
