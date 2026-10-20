import 'package:flutter/material.dart';

import '../../../models/venue_model.dart';
import '../../../models/api_model.dart';
import '../../../theme.dart';
import '../../../main.dart'; 
import 'allocation_form_screen.dart';

class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  late ApiRequest<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _venuesFuture = appState.fetchVenues();
  }

  Future<void> _refreshVenues() async {
    final future = appState.fetchVenues();
    setState(() {
      _venuesFuture = future;
    });
    await future;
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _refreshVenues,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Alocações',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.mainBlue,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          ),
          
          Expanded(
            child: FutureBuilder(
              future: _venuesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                final result = snapshot.data!;

                if (result.isError) {
                  return _buildErrorState(result.error.toString());
                }

                final venues = result.data ?? [];

                if (venues.isEmpty) {
                  return const Center(child: Text('Nenhum espaço cadastrado.'));
                }

                return RefreshIndicator(
                  onRefresh: _refreshVenues,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 80 + MediaQuery.paddingOf(context).bottom),
                    itemCount: venues.length,
                    separatorBuilder: (context, index) => const Divider(height: 32, color: Colors.transparent),
                    itemBuilder: (context, index) {
                      final item = venues[index];
                      
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AllocationFormScreen(venue: item),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.code ?? 'SEM-COD',
                                style: const TextStyle(
                                  color: AppColors.mainBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),

                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text: item.location,
                              ),
                              _InfoRow(
                                icon: Icons.people_outline,
                                text: '${item.capacity} pessoas',
                              ),
                              _InfoRow(
                                icon: Icons.verified_user_outlined,
                                text: item.allowedRoles?.join(', ') ?? 'Permissões não definidas',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
