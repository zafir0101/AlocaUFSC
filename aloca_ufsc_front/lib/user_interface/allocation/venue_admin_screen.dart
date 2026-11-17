import 'package:flutter/material.dart';

import 'package:aloca_ufsc_front/main.dart';
import '../../../theme.dart';
import 'venue_card.dart';
import 'venue_form_screen.dart';
import '../../../models/venue_model.dart';

class VenueAdminScreen extends StatefulWidget {
  final String? centerCode;
  final String? building;

  const VenueAdminScreen({super.key, this.centerCode, this.building});

  @override
  State<VenueAdminScreen> createState() => _VenueAdminScreenState();
}

class _VenueAdminScreenState extends State<VenueAdminScreen> {
  static const List<int> _capacityFilters = [20, 50, 100];

  final TextEditingController _searchController = TextEditingController();

  List<Venue> _venues = [];
  List<CampusCenter> _campus = [];
  bool _loading = true;
  String? _error;
  String _query = '';
  int? _minCapacity;

  bool get _isRoot => widget.centerCode == null;
  bool get _isSearching => _query.isNotEmpty || _minCapacity != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _venues.isEmpty;
      _error = null;
    });
    
    try {
      final venuesFuture = appState.fetchVenues();
      final campusFuture = appState.fetchCampus();
      
      final venuesResult = await venuesFuture;
      final campusResult = await campusFuture;
      
      if (!mounted) return;
      
      setState(() {
        if (venuesResult.isError) {
          _error = venuesResult.error.toString().replaceFirst('Exception: ', '');
        } else if (campusResult.isError) {
          _error = campusResult.error.toString().replaceFirst('Exception: ', '');
        } else {
          _venues = venuesResult.data ?? [];
          _campus = campusResult.data ?? [];
        }
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

  List<Venue> get _scoped => _venues
      .where((v) => widget.centerCode == null || v.center == widget.centerCode)
      .where((v) => widget.building == null || v.building == widget.building)
      .toList();

  List<Venue> get _searchResults {
    final query = _normalize(_query);
    return _scoped.where((v) {
      if (_minCapacity != null && v.capacity < _minCapacity!) return false;
      if (query.isEmpty) return true;
      final text = _normalize('${v.name} ${v.code} ${v.center} ${_centerName(v.center)} ${v.building}');
      return text.contains(query);
    }).toList();
  }

  String _centerName(String code) => _campus.where((c) => c.code == code).firstOrNull?.name ?? code;

  String _centerLabel(String code) => _campus.where((c) => c.code == code).firstOrNull?.label ?? code;

  String _normalize(String text) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    var result = text.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }

  Future<void> _openFolder({required String centerCode, String? building}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => VenueAdminScreen(centerCode: centerCode, building: building),
    ));
    _load();
  }

  Future<void> _openForm({Venue? venue}) async {
    final saved = await Navigator.of(context, rootNavigator: true).push<Venue>(MaterialPageRoute(
      builder: (context) => VenueFormScreen(
        venue: venue,
        initialCenter: widget.centerCode,
        initialBuilding: widget.building,
      ),
    ));
    if (saved != null) _load();
  }

  Future<void> _confirmDelete(Venue venue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir espaço?'),
        content: Text('O espaço "${venue.name}" (${venue.code}) será excluído. Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final result = await appState.deleteVenue(venue.id!);
      
      if (!mounted) return;
      
      if (result.isError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error.toString().replaceFirst('Exception: ', ''))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espaço excluído.')));
        _load();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();
    if (_isRoot) return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.building ?? _centerLabel(widget.centerCode!), overflow: TextOverflow.ellipsis),
      ),
      body: body,
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
              OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 8),
          _buildFilters(),
          const SizedBox(height: 8),
          ..._isSearching ? _buildSearchResults() : _buildFolderContents(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final scope = _isRoot ? 'todos os espaços' : (widget.building ?? widget.centerCode!);
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value.trim()),
      decoration: InputDecoration(
        hintText: 'Buscar em $scope (nome, código, centro, prédio)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _searchController.clear();
                  _query = '';
                }),
              ),
        filled: true,
        fillColor: AppColors.secondaryBlue,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Tooltip(
                  message: 'Capacidade mínima',
                  child: Icon(Icons.people_outline, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 6),
                for (final min in _capacityFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text('$min+'),
                      tooltip: 'Pelo menos $min pessoas',
                      selected: _minCapacity == min,
                      onSelected: (selected) => setState(() => _minCapacity = selected ? min : null),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IconButton.filled(
          onPressed: () => _openForm(),
          tooltip: 'Cadastrar espaço',
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  List<Widget> _buildSearchResults() {
    final results = _searchResults;
    if (results.isEmpty) {
      return [const _EmptyMessage('Nenhum espaço encontrado.')];
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text('${results.length} ${results.length == 1 ? 'espaço encontrado' : 'espaços encontrados'}',
            style: const TextStyle(color: AppColors.textSecondary)),
      ),
      for (final venue in results) _venueCard(venue),
    ];
  }

  List<Widget> _buildFolderContents() {
    final scoped = _scoped;
    if (scoped.isEmpty) {
      return [const _EmptyMessage('Nenhum espaço cadastrado aqui. Use o + para cadastrar.')];
    }

    if (_isRoot) {
      final codes = _campus.map((c) => c.code).where((code) => scoped.any((v) => v.center == code)).toList();
      return [
        for (final code in codes)
          _FolderTile(
            icon: Icons.apartment,
            title: _centerLabel(code),
            count: scoped.where((v) => v.center == code).length,
            onTap: () => _openFolder(centerCode: code),
          ),
      ];
    }

    if (widget.building == null) {
      final buildings = scoped.map((v) => v.building).toSet().toList()..sort();
      return [
        for (final building in buildings)
          _FolderTile(
            icon: Icons.business_outlined,
            title: building,
            count: scoped.where((v) => v.building == building).length,
            onTap: () => _openFolder(centerCode: widget.centerCode!, building: building),
          ),
      ];
    }

    return [for (final venue in scoped) _venueCard(venue)];
  }

  Widget _venueCard(Venue venue) {
    return VenueCard(
      venue: venue,
      onTap: () => _openForm(venue: venue),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        tooltip: 'Excluir espaço',
        onPressed: () => _confirmDelete(venue),
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  const _FolderTile({required this.icon, required this.title, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.mainBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(count == 1 ? '1 espaço' : '$count espaços'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String text;

  const _EmptyMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          const Icon(Icons.meeting_room_outlined, size: 56, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
