import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nba_app3/database/model/team_model.dart';
import 'package:nba_app3/services/firestore_service.dart';
import 'package:nba_app3/view/create_team.dart';

class ViewMyTeamsPage extends StatefulWidget {
  const ViewMyTeamsPage({super.key});

  @override
  State<ViewMyTeamsPage> createState() => _ViewMyTeamsPageState();
}

class _ViewMyTeamsPageState extends State<ViewMyTeamsPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _confirmDelete(String docId, String teamName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Time"),
        content: Text("Tem certeza que deseja excluir o time '$teamName'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTeam(docId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam(String docId) async {
    try {
      await _firestoreService.deleteTeam(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time deletado da nuvem!'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Times"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<MyTeam>>(
        stream: _firestoreService.getTeamsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final teams = snapshot.data ?? [];

          if (teams.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _buildTeamCard(team);
            },
          );
        },
      ),
    );
  }

  Widget _buildTeamCard(MyTeam team) {
    File? imageFile;
    if (team.logoPath != null && team.logoPath!.isNotEmpty) {
      imageFile = File(team.logoPath!);
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          backgroundImage: (imageFile != null && imageFile.existsSync())
              ? FileImage(imageFile)
              : null,
          child: (imageFile == null || !imageFile.existsSync())
              ? const Icon(Icons.person, color: Colors.grey)
              : null,
        ),
        title: Text(team.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${team.state} • ${team.players.length} Jogadores"),
        children: [
          Container(
            color: Colors.grey[50],
            child: Column(
              children: [
                ...team.players.map((player) => ListTile(
                  leading: const Icon(Icons.person_outline, size: 20),
                  title: Text(player.name),
                  subtitle: Text(player.position),
                  dense: true,
                )),
                
                const Divider(), 
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (context) => CreateTeamPage(teamToEdit: team),
                             ),
                           );
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        label: const Text("Editar", style: TextStyle(color: Colors.blue)),
                      ),
                      
                      const SizedBox(width: 10),
                      TextButton.icon(
                        onPressed: () {
                          if (team.id != null) {
                            _confirmDelete(team.id!, team.name);
                          }
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text("Excluir Time", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "Nenhum time salvo na nuvem.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
