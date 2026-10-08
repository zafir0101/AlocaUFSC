import 'package:flutter/material.dart';
import '../../models/venue_model.dart';
import '../../../theme.dart';
import '../../../main.dart';
import '../../../widgets.dart';
import '../../models/api_model.dart';

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

    Future<bool> _refreshVenues() async {
        final result = await appState.fetchVenues();
        setState(() {
            _venuesFuture = Future.value(result);
        });

        return (result.isOk);
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
                                appState.createVenue(newVenue).then((result) {
                                if (result.isError && context.mounted) showToast(context, "Não foi possível criar o Espaço");
                                });
                         } else {
                                appState.updateVenue(venue.id!, newVenue).then((result) {
                                if (result.isError && context.mounted) showToast(context, "Não foi possível atualizar o Espaço");
                                });
                         }

                            if (mounted) Navigator.pop(context);
                            _refreshVenues().then((hasLoad) {
                                if (!hasLoad && context.mounted) showToast(context, "Não foi possível carregar os Espaços");
                            });
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
            ),
            body: FutureBuilder(
                future: _venuesFuture,
                builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.data!.isEmpty) {
            return const Center(child: Text('Sem espaços cadastrados'));
          }

                    final venues = snapshot.data!.data!;
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
                            appState.deleteVenue(item.id!).then((result) {
                                if (result.isError && context.mounted) showToast(context, "Não foi possível deletar o Espaço");
                            });
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
            // floatingActionButton: FloatingActionButton(
            //     onPressed: () => _openVenueForm(),
            //     child: const Icon(Icons.add),
            // ),
        );
    }
}
