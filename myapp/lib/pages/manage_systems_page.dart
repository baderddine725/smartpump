import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ManageSystemsPage extends StatefulWidget {
  const ManageSystemsPage({super.key});

  @override
  State<ManageSystemsPage> createState() => _ManageSystemsPageState();
}

class _ManageSystemsPageState extends State<ManageSystemsPage> {
  List<SystemItem> _systems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSystems();
  }

  Future<void> _loadSystems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await StorageService.getUserId();
      final token = await StorageService.getToken();

      if (userId == null || token == null) {
        setState(() {
          _error = 'Non connecté';
          _isLoading = false;
        });
        return;
      }

      final systemsList = await ApiService.getSystems(userId, token: token);
      _systems = systemsList.map((sys) {
        return SystemItem(
          id: sys['id'] as String? ?? '',
          name: sys['name'] as String? ?? 'Unknown',
          description: sys['description'] as String? ?? 'No description',
        );
      }).toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading systems: $e');
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gérer les systèmes',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 2,
              width: 120,
              color: Colors.blue,
              margin: const EdgeInsets.only(top: 2),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadSystems,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _systems.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun système disponible',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSystems,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: _systems.length,
                        itemBuilder: (context, index) {
                          return _buildSystemCard(_systems[index], index);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddSystemDialog();
        },
        backgroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(
          side: BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        child: const Icon(
          Icons.add,
          color: Color(0xFF2E7D32),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSystemCard(SystemItem system, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    system.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    system.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                _showEditSystemDialog(index);
              },
              tooltip: 'Modifier',
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                _showDeleteConfirmation(index);
              },
              tooltip: 'Supprimer',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSystemDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Ajouter un système',
          style: TextStyle(color: Color(0xFF2E7D32)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du système',
                  labelStyle: TextStyle(color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final userId = await StorageService.getUserId();
        final token = await StorageService.getToken();

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Non connecté')),
          );
          return;
        }

        await ApiService.createSystem(
          userId: userId,
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          token: token,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Système ajouté avec succès!')),
        );

        _loadSystems();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showEditSystemDialog(int index) async {
    final system = _systems[index];
    final nameController = TextEditingController(text: system.name);
    final descriptionController = TextEditingController(text: system.description);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Modifier le système',
          style: TextStyle(color: Color(0xFF2E7D32)),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du système',
                  labelStyle: TextStyle(color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Color(0xFF2E7D32)),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      try {
        final userId = await StorageService.getUserId();
        final token = await StorageService.getToken();

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Non connecté')),
          );
          return;
        }

        await ApiService.updateSystem(
          systemId: system.id,
          userId: userId,
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          token: token,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Système modifié avec succès!')),
        );

        _loadSystems();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(int index) async {
    final system = _systems[index];

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le système'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${system.name}"?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final userId = await StorageService.getUserId();
        final token = await StorageService.getToken();

        if (userId == null || token == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Non connecté')),
          );
          return;
        }

        await ApiService.deleteSystem(
          systemId: system.id,
          userId: userId,
          token: token,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Système supprimé avec succès!')),
        );

        _loadSystems();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }
}

class SystemItem {
  final String id;
  final String name;
  final String description;

  SystemItem({
    required this.id,
    required this.name,
    required this.description,
  });
}
