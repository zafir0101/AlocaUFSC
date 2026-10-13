import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../api/venue_service.dart';
import '../../../theme.dart';
import '../../../widgets.dart';
import 'venue_model.dart';

// Cadastro e edição de espaço físico: se [venue] for nulo, cadastra um novo.
// [initialCenter] e [initialBuilding] já vêm preenchidos quando o cadastro é aberto de dentro de uma pasta.
class VenueFormScreen extends StatefulWidget {
  final Venue? venue;
  final String? initialCenter;
  final String? initialBuilding;

  const VenueFormScreen({super.key, this.venue, this.initialCenter, this.initialBuilding});

  @override
  State<VenueFormScreen> createState() => _VenueFormScreenState();
}

class _VenueFormScreenState extends State<VenueFormScreen> {
  final VenueService _venueService = VenueService();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _buildingController;
  late final FocusNode _buildingFocus;
  late final TextEditingController _codeController;
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _descriptionController;
  late final Set<String> _roles;
  String? _center;
  String? _rolesError;
  bool _loading = false;

  List<CampusCenter> _campus = [];
  bool _campusLoading = true;
  String? _campusError;

  bool get _isEditing => widget.venue != null;

  @override
  void initState() {
    super.initState();
    final v = widget.venue;
    _center = v?.center ?? widget.initialCenter;
    _buildingController = TextEditingController(text: v?.building ?? widget.initialBuilding ?? '');
    _buildingFocus = FocusNode();
    _codeController = TextEditingController(text: v?.code ?? '');
    _nameController = TextEditingController(text: v?.name ?? '');
    _capacityController = TextEditingController(text: v != null ? '${v.capacity}' : '');
    _descriptionController = TextEditingController(text: v?.description ?? '');
    _roles = {...?v?.allowedRoles};
    _loadCampus();
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _buildingFocus.dispose();
    _codeController.dispose();
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCampus() async {
    setState(() {
      _campusLoading = true;
      _campusError = null;
    });
    try {
      final campus = await _venueService.fetchCampus();
      if (!mounted) return;
      setState(() {
        _campus = campus;
        _campusLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _campusError = e.toString().replaceFirst('Exception: ', '');
        _campusLoading = false;
      });
    }
  }

  Iterable<String> _buildingOptions(String typed) {
    final center = _campus.where((c) => c.code == _center).firstOrNull;
    if (center == null) return const [];
    final query = _normalize(typed);
    return center.buildings.where((b) => _normalize(b).contains(query));
  }

  String _normalize(String text) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    var result = text.toLowerCase();
    for (var i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }

  bool get _hasChanges {
    final v = widget.venue;
    return _center != (v?.center ?? widget.initialCenter) ||
        _buildingController.text.trim() != (v?.building ?? widget.initialBuilding ?? '') ||
        _codeController.text.trim() != (v?.code ?? '') ||
        _nameController.text.trim() != (v?.name ?? '') ||
        _capacityController.text.trim() != (v != null ? '${v.capacity}' : '') ||
        _descriptionController.text.trim() != (v?.description ?? '') ||
        !_sameRoles(_roles, {...?v?.allowedRoles});
  }

  bool _sameRoles(Set<String> a, Set<String> b) => a.length == b.length && a.containsAll(b);

  bool? get _allRolesState {
    if (_roles.isEmpty) return false;
    if (_roles.length == venueRoleLabels.length) return true;
    return null;
  }

  void _toggleAllRoles() {
    setState(() {
      if (_roles.length == venueRoleLabels.length) {
        _roles.clear();
      } else {
        _roles.addAll(venueRoleLabels.keys);
      }
      _rolesError = null;
    });
  }

  void _toggleRole(String role, bool selected) {
    setState(() {
      selected ? _roles.add(role) : _roles.remove(role);
      _rolesError = null;
    });
  }

  Future<void> _save() async {
    final fieldsValid = _formKey.currentState!.validate();
    final rolesValid = _roles.isNotEmpty;
    setState(() => _rolesError = rolesValid ? null : 'Selecione pelo menos um perfil.');
    if (!fieldsValid || !rolesValid) return;

    setState(() => _loading = true);
    final venue = Venue(
      id: widget.venue?.id,
      center: _center!,
      building: _buildingController.text.trim(),
      code: _codeController.text.trim(),
      name: _nameController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      description: _descriptionController.text.trim(),
      allowedRoles: venueRoleLabels.keys.where(_roles.contains).toList(),
    );

    try {
      final saved = _isEditing
          ? await _venueService.updateVenue(widget.venue!.id!, venue)
          : await _venueService.createVenue(venue);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Espaço atualizado.' : 'Espaço cadastrado.')),
      );
      Navigator.of(context).pop(saved);
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
          TextButton(onPressed: () => Navigator.pop(context, 'continue'), child: const Text('Continuar editando')),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Descartar'),
          ),
          TextButton(onPressed: () => Navigator.pop(context, 'save'), child: const Text('Salvar')),
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

  String? _required(String? value, String message) => value == null || value.trim().isEmpty ? message : null;

  InputDecoration _decoration(String label, {String? helper}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      filled: true,
      fillColor: AppColors.secondaryBlue,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _loading) return;
        if (_hasChanges) {
          _confirmExit();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isEditing ? 'Editar espaço' : 'Cadastrar espaço')),
        body: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_campusLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_campusError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_campusError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(onPressed: _loadCampus, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
            ],
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<String>(
            value: _campus.any((c) => c.code == _center) ? _center : null,
            isExpanded: true,
            decoration: _decoration('Centro'),
            items: [
              for (final c in _campus) DropdownMenuItem(value: c.code, child: Text(c.label, overflow: TextOverflow.ellipsis)),
            ],
            validator: (v) => v == null ? 'Selecione o centro.' : null,
            onChanged: (value) => setState(() {
              if (value != _center) _buildingController.clear();
              _center = value;
            }),
          ),
          const SizedBox(height: 16),
          RawAutocomplete<String>(
            textEditingController: _buildingController,
            focusNode: _buildingFocus,
            optionsBuilder: (value) => _buildingOptions(value.text),
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) => TextFormField(
              controller: controller,
              focusNode: focusNode,
              enabled: _center != null,
              decoration: _decoration(
                'Prédio / bloco',
                helper: _center == null ? 'Selecione o centro primeiro.' : 'Escolha da lista ou digite outro prédio.',
              ),
              validator: (v) => _required(v, 'Informe o prédio.'),
            ),
            optionsViewBuilder: (context, onSelected, options) => Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240, maxWidth: 360),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (final option in options)
                        ListTile(
                          leading: const Icon(Icons.business_outlined),
                          title: Text(option),
                          onTap: () => onSelected(option),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          textField(
            controller: _codeController,
            label: 'Código da sala (ex.: LAB-01)',
            maxLength: 20,
            validator: (v) => _required(v, 'Informe o código da sala.'),
          ),
          const SizedBox(height: 12),
          textField(
            controller: _nameController,
            label: 'Nome',
            maxLength: 100,
            validator: (v) => _required(v, 'Informe o nome do espaço.'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(5)],
            validator: (v) {
              final capacity = int.tryParse(v?.trim() ?? '');
              if (capacity == null || capacity < 1) return 'A capacidade deve ser maior que zero.';
              if (capacity > 10000) return 'A capacidade deve ser no máximo 10000.';
              return null;
            },
            decoration: _decoration('Capacidade (pessoas)'),
          ),
          const SizedBox(height: 16),
          textField(
            controller: _descriptionController,
            label: 'Descrição (opcional)',
            keyboard: TextInputType.multiline,
            maxLines: 3,
            maxLength: 1000,
            validator: (_) => null,
          ),
          const SizedBox(height: 16),
          const Text('Quem pode solicitar este espaço', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          CheckboxListTile(
            title: const Text('Permitir todos', style: TextStyle(fontWeight: FontWeight.w600)),
            value: _allRolesState,
            tristate: true,
            onChanged: (_) => _toggleAllRoles(),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 1),
          for (final entry in venueRoleLabels.entries)
            CheckboxListTile(
              title: Text(entry.value),
              value: _roles.contains(entry.key),
              onChanged: (selected) => _toggleRole(entry.key, selected ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.only(left: 16),
            ),
          if (_rolesError != null)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(_rolesError!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_isEditing ? 'Salvar alterações' : 'Cadastrar espaço'),
          ),
        ],
      ),
    );
  }
}
