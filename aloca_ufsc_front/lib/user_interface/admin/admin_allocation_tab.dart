import 'package:flutter/material.dart';
import '../../../models/allocation_model.dart';
import '../../../main.dart';
import '../../../theme.dart';

class AdminAllocationsTab extends StatefulWidget {
  const AdminAllocationsTab({super.key});

  @override
  State<AdminAllocationsTab> createState() => _AdminAllocationsTabState();
}

class _AdminAllocationsTabState extends State<AdminAllocationsTab> {
  bool _loading = true;
  List<Allocation> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    final result = await appState.fetchAllocationsByStatus('PENDING'); 
    
    if (mounted) {
      setState(() {
        if (!result.isError) _requests = result.data ?? [];
        _loading = false;
      });
    }
  }

  Future<void> _handleAction(Allocation request, bool approve) async {
    String reason = '';
    
    if (!approve) {
      final inputReason = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Motivo da Rejeição'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Explique o motivo...'),
              maxLines: 3,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Rejeitar')),
            ],
          );
        }
      );
      if (inputReason == null) return; // Cancelou
      reason = inputReason;
    }

    setState(() => _loading = true);
    try {
      final res = approve 
        ? await appState.approveAllocation(request.id) 
        : await appState.rejectAllocation(request.id, reason);
        
      if (res.isError) throw Exception("Erro na API.");
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(approve ? 'Alocação Aprovada!' : 'Alocação Rejeitada.'),
        backgroundColor: approve ? Colors.green : Colors.red,
      ));
      
      _loadRequests();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_requests.isEmpty) {
      return const Center(child: Text('Não existem solicitações pendentes.', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 80 + MediaQuery.paddingOf(context).bottom),
        itemCount: _requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final req = _requests[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req.eventTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Espaço: ${req.venueName}'),
                  Text('Requerente: ${req.requesterName}'),
                  Text('Início: ${req.start.toString().substring(0, 16)}'),
                  Text('Fim: ${req.end.toString().substring(0, 16)}'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleAction(req, false),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('Rejeitar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _handleAction(req, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text('Aprovar'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
