import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api/event_service.dart';
import '../../theme.dart';
import '../../widgets.dart';
import 'event_detail_screen.dart';
import 'event_model.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final EventService _eventService = EventService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _start;
  DateTime? _end;
  String? _periodError;
  bool _loading = false;

  bool get _isEditing => widget.event != null;

  bool get _editingSuspended => widget.event?.isSuspended ?? false;

  bool get _hasChanges =>
      _titleController.text.trim() != (widget.event?.title ?? '') ||
          _descriptionController.text.trim() != (widget.event?.description ?? '') ||
          _start != widget.event?.start ||
          _end != widget.event?.end;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    _start = widget.event?.start;
    _end = widget.event?.end;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(String title, DateTime? initial) {
    var selected = _roundToFiveMinutes(initial ?? DateTime.now().add(const Duration(hours: 1)));
    final now = _roundToFiveMinutes(DateTime.now());
    final minimum = selected.isBefore(now) ? selected : now;

    return showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(
                height: 216,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: selected,
                  minimumDate: minimum,
                  use24hFormat: true,
                  minuteInterval: 5,
                  onDateTimeChanged: (value) => selected = value,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Confirmar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _roundToFiveMinutes(DateTime d) {
    final minutes = (d.minute / 5).ceil() * 5;
    return DateTime(d.year, d.month, d.day, d.hour).add(Duration(minutes: minutes));
  }

  Future<void> _pickStart() async {
    final picked = await _pickDateTime('Início do evento', _start);
    if (picked == null) return;
    setState(() {
      _start = picked;
      if (_end == null || !_end!.isAfter(picked)) {
        _end = picked.add(const Duration(hours: 1));
      }
      _periodError = null;
    });
  }

  Future<void> _pickEnd() async {
    final picked = await _pickDateTime('Fim do evento', _end ?? _start);
    if (picked == null) return;
    setState(() {
      _end = picked;
      _periodError = null;
    });
  }

  bool _validatePeriod() {
    String? error;
    if (_start == null || _end == null) {
      error = 'Informe o início e o fim do evento.';
    } else if (!_end!.isAfter(_start!)) {
      error = 'O fim deve ser depois do início.';
    }
    setState(() => _periodError = error);
    return error == null;
  }

  Future<void> _save({bool reactivate = false}) async {
    final fieldsValid = _formKey.currentState!.validate();
    final periodValid = _validatePeriod();
    if (!fieldsValid || !periodValid) return;

    setState(() => _loading = true);

    final event = Event(
      id: widget.event?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      start: _start!,
      end: _end!,
    );

    try {
      var saved = _isEditing
          ? await _eventService.updateEvent(widget.event!.id!, event)
          : await _eventService.createEvent(event);
      if (reactivate) {
        saved = await _eventService.reactivateEvent(saved.id!);
      }
      if (!mounted) return;
      final message = reactivate ? 'Evento atualizado e reativado.' : (_isEditing ? 'Evento atualizado.' : 'Evento criado.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.of(context).pop(saved);
    } on DuplicateEventException catch (e) {
      if (!mounted) return;
      await _showDuplicateDialog(e);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmExit() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('Você tem alterações que ainda não foram salvas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'continue'),
            child: const Text('Continuar editando'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'discard') {
      Navigator.of(context).pop();
    } else if (choice == 'save') {
      await _save();
    }
  }

  Future<void> _showDuplicateDialog(DuplicateEventException e) async {
    final openExisting = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Evento já existe'),
        content: Text(e.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Voltar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ver evento existente'),
          ),
        ],
      ),
    );
    if (openExisting != true || !mounted) return;

    try {
      final existing = await _eventService.fetchEvent(e.existingEventId);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => EventDetailScreen(event: existing)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_hasChanges && !_loading) {
          _confirmExit();
        } else if (!_loading) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Editar evento' : 'Criar evento')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                textField(
                  controller: _titleController,
                  label: 'Título',
                  maxLength: 100,
                  validator: (value) => value == null || value.trim().isEmpty ? 'Informe o título do evento.' : null,
                ),
                const SizedBox(height: 16),
                textField(
                  controller: _descriptionController,
                  label: 'Descrição',
                  keyboard: TextInputType.multiline,
                  maxLines: 4,
                  maxLength: 1000,
                  validator: (_) => null,
                ),
                const SizedBox(height: 16),
                _DateTimeField(label: 'Início', value: _start, onTap: _pickStart),
                const SizedBox(height: 12),
                _DateTimeField(label: 'Fim', value: _end, onTap: _pickEnd),
                if (_periodError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      _periodError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 32),
                if (_editingSuspended) ...[
                  _primaryButton(label: 'Salvar e reativar evento', onPressed: () => _save(reactivate: true)),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _loading ? null : _save,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Salvar alterações'),
                  ),
                ] else
                  _primaryButton(label: _isEditing ? 'Salvar alterações' : 'Criar evento', onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: _loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _loading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(label),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  const _DateTimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.secondaryBlue,
          suffixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Text(value != null ? formatDateTime(value!) : 'Selecionar data e hora'),
      ),
    );
  }
}