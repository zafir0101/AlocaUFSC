import 'package:flutter/material.dart';

import '../../api/event_service.dart';
import '../theme.dart';
import 'event_form_screen.dart';
import 'event_model.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final EventService _eventService = EventService();

  late Event _event;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Event>(
      MaterialPageRoute(builder: (context) => EventFormScreen(event: _event)),
    );
    if (updated == null || !mounted) return;
    if (_event.isSuspended && !updated.isSuspended) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _event = updated);
  }

  Future<void> _suspend() async {
    await _changeStatus(
      dialogTitle: 'Suspender evento?',
      dialogMessage: 'O evento "${_event.title}" sai dos próximos e fica em Suspensos '
          'até você reativá-lo. Você ainda poderá editar a data.',
      confirmLabel: 'Suspender',
      confirmColor: Colors.amber.shade800,
      action: () => _eventService.suspendEvent(_event.id!),
      successMessage: 'Evento suspenso.',
    );
  }

  Future<void> _reactivate() async {
    await _changeStatus(
      dialogTitle: 'Reativar evento?',
      dialogMessage: 'Reativar o evento "${_event.title}" no período '
          '${formatPeriod(_event.start, _event.end)}?',
      confirmLabel: 'Reativar',
      confirmColor: AppColors.mainBlue,
      action: () => _eventService.reactivateEvent(_event.id!),
      successMessage: 'Evento reativado.',
    );
  }

  Future<void> _cancel() async {
    await _changeStatus(
      dialogTitle: 'Cancelar evento?',
      dialogMessage: 'Esta ação é definitiva: o evento "${_event.title}" não poderá mais '
          'ser editado nem reativado.',
      confirmLabel: 'Cancelar evento',
      confirmColor: Colors.red,
      action: () => _eventService.cancelEvent(_event.id!),
      successMessage: 'Evento cancelado.',
    );
  }

  Future<void> _changeStatus({
    required String dialogTitle,
    required String dialogMessage,
    required String confirmLabel,
    required Color confirmColor,
    required Future<Event> Function() action,
    required String successMessage,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Text(dialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do evento')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _event.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              EventBadge(event: _event),
            ],
          ),
          const SizedBox(height: 24),
          _DetailItem(icon: Icons.calendar_today, label: 'Período', value: formatPeriod(_event.start, _event.end)),
          _DetailItem(
            icon: Icons.place_outlined,
            label: 'Local',
            value: _event.venueName ?? 'A definir (será definido na alocação de espaço)',
          ),
          if (_event.creatorName != null)
            _DetailItem(icon: Icons.person_outline, label: 'Organizador', value: _event.creatorName!),
          _DetailItem(
            icon: Icons.notes,
            label: 'Descrição',
            value: _event.description.isEmpty ? 'Sem descrição' : _event.description,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _event.isFinished ? _buildFinishedNotice() : _buildActions(),
        ),
      ),
    );
  }

  Widget _buildFinishedNotice() {
    return Text(
      _event.isCancelled
          ? 'Este evento foi cancelado e não pode mais ser alterado.'
          : 'Este evento já passou e não pode mais ser alterado.',
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textSecondary),
    );
  }

  Widget _buildActions() {
    final Widget statusButton = _event.isSuspended
        ? ElevatedButton.icon(
      onPressed: _loading || !_event.canReactivate ? null : _reactivate,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Reativar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainBlue,
        foregroundColor: Colors.white,
      ),
    )
        : OutlinedButton.icon(
      onPressed: _loading ? null : _suspend,
      icon: const Icon(Icons.pause),
      label: const Text('Suspender'),
      style: OutlinedButton.styleFrom(foregroundColor: Colors.amber.shade800),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_event.isSuspended && !_event.canReactivate)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'A data deste evento já passou. Edite a data para poder reativá-lo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _edit,
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: statusButton),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _loading ? null : _cancel,
            icon: const Icon(Icons.event_busy),
            label: const Text('Cancelar evento'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.mainBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventBadge extends StatelessWidget {
  final Event event;

  const EventBadge({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.isCancelled) {
      return _Badge(label: 'Cancelado', background: Colors.red.shade50, foreground: Colors.red.shade700);
    }
    if (event.isSuspended) {
      return _Badge(label: 'Suspenso', background: Colors.amber.shade50, foreground: Colors.amber.shade900);
    }
    if (event.isInProgress) {
      return _Badge(label: 'Em andamento', background: Colors.green.shade50, foreground: Colors.green.shade700);
    }
    return const SizedBox.shrink();
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Badge({required this.label, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}