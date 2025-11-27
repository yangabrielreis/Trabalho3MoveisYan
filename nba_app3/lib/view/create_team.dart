import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:nba_app3/database/model/team_model.dart';
import 'package:nba_app3/database/model/player_model.dart';
import 'package:nba_app3/services/nba_api.dart';
import 'package:nba_app3/services/firestore_service.dart';

class CreateTeamPage extends StatefulWidget {
  final MyTeam? teamToEdit;

  const CreateTeamPage({super.key, this.teamToEdit});

  @override
  _CreateTeamPageState createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final _nameController = TextEditingController();
  String? _selectedState;
  File? _logoImage;
  List<MyPlayer> _selectedPlayers = [];
  bool _isSaving = false;

  final FirestoreService _firestoreService = FirestoreService();

  final List<String> _usStates = [
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
    "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
    "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
    "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
    "New Hampshire", "New Jersey", "New Mexico", "New York",
    "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
    "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
    "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
    "West Virginia", "Wisconsin", "Wyoming"
  ];

  @override
  void initState() {
    super.initState();
    if (widget.teamToEdit != null) {
      _loadDataForEdit();
    }
  }

  void _loadDataForEdit() {
    final team = widget.teamToEdit!;
    _nameController.text = team.name;
    if (_usStates.contains(team.state)) {
      _selectedState = team.state;
    }
    if (team.logoPath != null && team.logoPath!.isNotEmpty) {
      _logoImage = File(team.logoPath!);
    }
    _selectedPlayers = List.from(team.players);
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  void _saveOrUpdateTeam() async {
    if (_nameController.text.isEmpty || _selectedState == null || _selectedPlayers.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha tudo e escolha 5 jogadores!"))
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      MyTeam teamData = MyTeam(
        id: widget.teamToEdit?.id,
        name: _nameController.text,
        state: _selectedState!,
        logoPath: _logoImage?.path ?? "",
        players: _selectedPlayers,
      );

      if (widget.teamToEdit != null) {
        await _firestoreService.updateTeam(widget.teamToEdit!.id!, teamData);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Time atualizado!"), backgroundColor: Colors.blue));
        }
      } else {
        await _firestoreService.saveTeam(teamData);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Time criado!"), backgroundColor: Colors.green));
        }
      }
      
      if (mounted) Navigator.pop(context);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openPlayerSearch() async {
    final List<MyPlayer>? selectedPlayers = await showDialog<List<MyPlayer>>(
      context: context,
      builder: (BuildContext context) {
        return const PlayerSearchModal();
      },
    );

    if (selectedPlayers != null && selectedPlayers.isNotEmpty) {
      setState(() {
        for (var newPlayer in selectedPlayers) {
          bool jaExiste = _selectedPlayers.any((p) => 
              p.apiId == newPlayer.apiId && p.name == newPlayer.name);
          
          if (!jaExiste) {
            if (_selectedPlayers.length < 5) {
              _selectedPlayers.add(newPlayer);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Limite de 5 jogadores atingido!"))
              );
              break;
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.teamToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Time" : "Criar Novo Time")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome do Time"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedState,
              hint: const Text("Escolha um Estado"),
              isExpanded: true,
              items: _usStates.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedState = val),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                color: Colors.grey[300],
                child: _logoImage == null 
                  ? const Icon(Icons.camera_alt, size: 50) 
                  : Image.file(_logoImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text("Jogadores (${_selectedPlayers.length}/5)", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            
            ..._selectedPlayers.map((p) => ListTile(
              title: Text(p.name),
              subtitle: Text(p.position),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => _selectedPlayers.remove(p)),
              ),
            )).toList(),

            ElevatedButton(
              onPressed: _selectedPlayers.length < 5 ? _openPlayerSearch : null,
              child: const Text("Adicionar Jogador"),
            ),
            const SizedBox(height: 30),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isEditing ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15)
              ),
              onPressed: _isSaving ? null : _saveOrUpdateTeam,
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text(isEditing ? "ATUALIZAR TIME" : "SALVAR TIME"),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerSearchModal extends StatefulWidget {
  const PlayerSearchModal({super.key});

  @override
  State<PlayerSearchModal> createState() => _PlayerSearchModalState();
}

class _PlayerSearchModalState extends State<PlayerSearchModal> {
  final NbaApi _api = NbaApi();
  
  List<dynamic> _nbaTeams = [];
  List<MyPlayer> _playersList = [];
  final List<MyPlayer> _tempSelectedPlayers = [];
  
  int? _selectedTeamId;
  bool _isLoadingTeams = true;
  bool _isLoadingPlayers = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _loadNbaTeams();
  }

  Future<void> _loadNbaTeams() async {
    try {
      final teams = await _api.getTeamsNBA(season: '2022-2023');
      final validTeams = teams.where((t) {
        final name = t['name'].toString();
        return !name.contains('Team');
      }).toList();

      setState(() {
        _nbaTeams = validTeams;
        _isLoadingTeams = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTeams = false;
        _errorText = "Erro ao carregar times: $e";
      });
    }
  }

  Future<void> _loadPlayers(int teamId) async {
    setState(() {
      _isLoadingPlayers = true;
      _selectedTeamId = teamId;
      _playersList = [];
    });

    try {
      final players = await _api.getPlayersFromTeam(teamId, '2023-2024');
      setState(() {
        _playersList = players;
        _isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() => _isLoadingPlayers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 600,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Buscar Jogadores", 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${_tempSelectedPlayers.length} selecionado(s)", 
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(height: 15),
            
            if (_errorText != null)
              Container(padding: const EdgeInsets.all(8), color: Colors.red[100], child: Text(_errorText!)),

            _isLoadingTeams
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: "Selecione o Time", border: OutlineInputBorder()),
                    value: _selectedTeamId,
                    items: _nbaTeams.map((team) {
                      return DropdownMenuItem<int>(
                        value: int.tryParse(team['id'].toString()) ?? 0,
                        child: Text(team['name'].toString(), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _loadPlayers(value);
                    },
                  ),
            
            const SizedBox(height: 10),
            const Divider(),
            
            Expanded(
              child: _isLoadingPlayers
                  ? const Center(child: CircularProgressIndicator())
                  : _selectedTeamId == null
                      ? const Center(child: Text("Escolha um time acima."))
                      : ListView.separated(
                          itemCount: _playersList.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final player = _playersList[index];
                            final isSelected = _tempSelectedPlayers.any((p) => p.apiId == player.apiId && p.name == player.name);

                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.person, color: Colors.blue),
                              title: Text(player.name),
                              subtitle: Text(player.position ?? '-'),
                              trailing: Icon(
                                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                color: isSelected ? Colors.green : Colors.grey,
                              ),
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _tempSelectedPlayers.removeWhere((p) => p.apiId == player.apiId);
                                  } else {
                                    _tempSelectedPlayers.add(player);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
            
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _tempSelectedPlayers);
                  },
                  child: const Text("Concluir Seleção"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
