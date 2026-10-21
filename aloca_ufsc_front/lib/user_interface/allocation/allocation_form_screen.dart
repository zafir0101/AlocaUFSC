import 'package:flutter/material.dart';
import '../../../models/venue_model.dart';
import '../../../models/allocation_model.dart';
import '../../../models/event_model.dart';
import '../../../main.dart';
import '../../../theme.dart';

class AllocationFormScreen extends StatefulWidget {
  final Venue venue;

  const AllocationFormScreen({super.key, required this.venue});

  @override
  State<AllocationFormScreen> createState() => _AllocationFormScreenState();
}

class _AllocationFormScreenState extends State<AllocationFormScreen> {
  bool _loading = true;
  String? _error;
  List<Event> _events = [];
  
  Event? _selectedEvent;
  DateTime? _start;
  DateTime? _end; 

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final result = await appState.fetchEligibleEvents(); 
      if (!mounted) return;

      if (result.isError) {
        setState(() {
          _error = "Erro de sessão. Tente fazer login novamente.";
          _loading = false;
        });
      } else {
        setState(() {
          _events = result.data ?? [];
          if (_events.isNotEmpty) {
              _selectedEvent = _events.first;
              _start = _selectedEvent!.start;
              _end = _selectedEvent!.end;
          }
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_selectedEvent == null) return;
    
    setState(() => _loading = true);
    
    try {
      final result = await appState.createAllocation(
        _selectedEvent!.id!, 
        widget.venue.id!, 
        _start!, 
        _end!
      );
      
      if (!mounted) return;
      
      if (result.isError) {
        throw Exception("Sessão inválida. Tente fazer login novamente.");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido de alocação enviado com sucesso!')),
      );
      Navigator.of(context).pop();
      
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Alocação')),
      body: _loading 
        ? const Center(child: CircularProgressIndicator()) 
        : _error != null 
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
              )
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Espaço: ${widget.venue.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<Event>(
                  decoration: const InputDecoration(labelText: 'Selecione o Evento', border: OutlineInputBorder()),
                  value: _selectedEvent,
                  items: _events.map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.title),
                  )).toList(),
                  onChanged: (val) => setState(() { 
                        _selectedEvent = val;
                        _start = _selectedEvent!.start;
                        _end = _selectedEvent!.end;
                    }),
                ),
                const SizedBox(height: 24),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                  leading: const Icon(Icons.access_time),
                  title: const Text('Início'),
                  subtitle: Text(_start != null ? _start.toString().substring(0, 16) : "Evento não selecionado."),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                  leading: const Icon(Icons.access_time),
                  title: const Text('Fim'),
                  subtitle: Text(_end != null ? _end.toString().substring(0, 16) : "Evento não selecionado."), 
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _events.isEmpty ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirmar Pedido'),
                ),
                if (_events.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text('Não tem eventos elegíveis para alocação.', style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ),
              ],
            ),
    );
  }
}
