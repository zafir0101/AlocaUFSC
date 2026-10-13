import 'package:flutter/material.dart';

import '../../../api/venue_service.dart';
import '../../../theme.dart';
import 'venue_card.dart';
import 'venue_model.dart';


class VenueScreen extends StatefulWidget {
  const VenueScreen({super.key});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  final VenueService _venueService = VenueService();
  late Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _venuesFuture = _venueService.fetchVenues();
  }

  Future<void> _refreshVenues() async {
    final future = _venueService.fetchVenues();
    setState(() => _venuesFuture = future);
    await future.catchError((_) => <Venue>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Alocações',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.mainBlue),
        ),
      ),
      body: FutureBuilder<List<Venue>>(
        future: _venuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(snapshot.error.toString().replaceFirst('Exception: ', ''), textAlign: TextAlign.center),
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

          final venues = snapshot.data ?? [];
          if (venues.isEmpty) {
            return const Center(child: Text('Nenhum espaço cadastrado.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshVenues,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.paddingOf(context).bottom),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Espaços físicos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
                for (final venue in venues) VenueCard(venue: venue),
              ],
            ),
          );
        },
      ),
    );
  }
}