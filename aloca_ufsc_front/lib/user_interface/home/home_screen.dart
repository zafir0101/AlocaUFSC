import 'package:flutter/material.dart';

import '../../api/event_service.dart';
import '../../api/session.dart';
import '../auth/auth_screen.dart';
import '../event/event_detail_screen.dart';
import '../event/event_form_screen.dart';
import '../event/event_model.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EventService _eventService = EventService();

  List<Event> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final events = await _eventService.fetchMyEvents();
      if (!mounted) return;
      setState(() {
        _events = events;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _openCreateForm() async {
    await Navigator.of(context).push<Event>(
      MaterialPageRoute(builder: (context) => const EventFormScreen()),
    );
    _loadEvents();
  }

  Future<void> _openDetails(Event event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => EventDetailScreen(event: event)),
    );
    _loadEvents();
  }

  void _logout(BuildContext context) {
    Session.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasEvents = !_loading && _error == null && _events.isNotEmpty;

    final upcoming = _events.where((e) => !e.isFinished && !e.isSuspended).toList();
    final suspended = _events.where((e) => e.isSuspended).toList();
    final finished = _events.where((e) => e.isFinished).toList()..sort((a, b) => b.start.compareTo(a.start));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'AlocaUFSC',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.mainBlue,
            ),
          ),
          actions: [
            if (hasEvents)
              TextButton.icon(
                onPressed: _openCreateForm,
                icon: const Icon(Icons.add),
                label: const Text('Criar evento'),
              ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _logout(context),
            ),
          ],
          bottom: hasEvents
              ? TabBar(
            labelColor: AppColors.mainBlue,
            indicatorColor: AppColors.mainBlue,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Próximos (${upcoming.length})'),
              Tab(text: 'Suspensos (${suspended.length})'),
              Tab(text: 'Finalizados (${finished.length})'),
            ],
          )
              : null,
        ),
        body: hasEvents
            ? TabBarView(
          children: [
            _buildEventList(upcoming, emptyMessage: 'Nenhum evento próximo.', showCreateButton: true),
            _buildEventList(suspended, emptyMessage: 'Nenhum evento suspenso.'),
            _buildEventList(finished, emptyMessage: 'Nenhum evento finalizado.'),
          ],
        )
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadEvents,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return _EmptyState(
      message: 'Você ainda não criou nenhum evento',
      onCreate: _openCreateForm,
    );
  }

  Widget _buildEventList(List<Event> events, {required String emptyMessage, bool showCreateButton = false}) {
    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadEvents,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            _EmptyState(message: emptyMessage, onCreate: showCreateButton ? _openCreateForm : null),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final event in events)
            _EventCard(event: event, onTap: () => _openDetails(event)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onCreate;

  const _EmptyState({required this.message, this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note, size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (onCreate != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Criar evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: event.isFinished ? 0.6 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    EventBadge(event: event),
                  ],
                ),
                const SizedBox(height: 8),
                _InfoRow(icon: Icons.calendar_today, text: formatPeriod(event.start, event.end)),
                const SizedBox(height: 4),
                _InfoRow(icon: Icons.place_outlined, text: event.venueName ?? 'Local a definir'),
                if (event.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ),
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
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
      ],
    );
  }
}