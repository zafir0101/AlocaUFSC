import 'package:flutter/material.dart';
import '../../../api/venue_service.dart';
import '../../auth/auth_screen.dart';
import 'venue_model.dart';

class VenueScreen extends StatefulWidget {
  const VenueScreen({Key? key}) : super(key: key);

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  final VenueService _venueService = VenueService();
  late Future<List<Venue>> _venuesFuture;

  @override
  void initState() {
    super.initState();
    _refreshVenues();
  }

  void _refreshVenues() {
    setState(() {
      _venuesFuture = _venueService.fetchVenues();
    });
  }

  void _openVenueForm({Venue? venue}) {
    final nameController = TextEditingController(text: venue?.name ?? '');
    final locationController =
        TextEditingController(text: venue?.location ?? '');
    final capacityController =
        TextEditingController(text: venue?.capacity.toString() ?? '');
    final descriptionController =
        TextEditingController(text: venue?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(venue == null ? 'Create Venue' : 'Edit Venue'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome')),
              TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Localização')),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(labelText: 'Capacidade'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição')),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final newVenue = Venue(
                id: venue?.id,
                name: nameController.text,
                location: locationController.text,
                capacity: int.tryParse(capacityController.text) ?? 0,
                description: descriptionController.text,
              );

              if (venue == null) {
                await _venueService.createVenue(newVenue);
              } else {
                await _venueService.updateVenue(venue.id!, newVenue);
              }

              if (mounted) Navigator.pop(context);
              _refreshVenues();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Espaços Físicos'),
        // <-- Adicionado o botão de logout no topo da tela
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Venue>>(
        future: _venuesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Sem espaços cadastrados'));
          }

          final venues = snapshot.data!;
          return ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, index) {
              final item = venues[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: ListTile(
                  title: Text(item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle:
                      Text('${item.location} | Capacity: ${item.capacity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openVenueForm(venue: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (item.id != null) {
                            await _venueService.deleteVenue(item.id!);
                            _refreshVenues();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openVenueForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
