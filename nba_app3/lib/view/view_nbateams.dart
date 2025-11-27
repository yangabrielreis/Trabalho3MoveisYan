import 'package:flutter/material.dart';
import 'package:nba_app3/services/nba_api.dart';

class ViewNbaTeamsPage extends StatefulWidget {
  const ViewNbaTeamsPage({super.key});

  @override
  State<ViewNbaTeamsPage> createState() => _ViewNbaTeamsState();
}

class _ViewNbaTeamsState extends State<ViewNbaTeamsPage> {
  List<dynamic> _teams = [];
  bool _isLoading = true;
  String _errorMessage = '';
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTeams();
    });
  }

  Future<void> _fetchTeams({String? query}) async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String? searchTerm = (query != null && query.isNotEmpty) ? query : null;

      final result = await NbaApi().getTeamsNBA(
        season: '2022-2023', 
        search: searchTerm, 
      );

      final filteredList = result.where((team) {
        final name = team['name'].toString();
        return !name.startsWith('Team') && 
               !name.contains('All-Stars');
      }).toList();

      setState(() {
        _teams = filteredList;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = "Erro: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Times da NBA'),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Pesquisar na NBA...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _fetchTeams();
                      },
                    )
                  : null,
              ),
              onSubmitted: (value) => _fetchTeams(query: value),
            ),
          ),
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)));
    }

    if (_teams.isEmpty) {
      return const Center(child: Text("Nenhum time encontrado."));
    }

    return ListView.separated(
      itemCount: _teams.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final team = _teams[index];
        final name = team['name'] ?? 'Sem nome';
        final logoUrl = team['logo'];

        return ListTile(
          leading: logoUrl != null
              ? Image.network(logoUrl, width: 50, errorBuilder: (_,__,___) => Icon(Icons.error))
              : const Icon(Icons.sports_basketball),
          title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("ID: ${team['id']}"),
        );
      },
    );
  }
}
