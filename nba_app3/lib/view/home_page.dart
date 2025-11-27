import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_nbateams.dart';
import 'view_myteams.dart';
import 'create_team.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "NBA Fantasy Manager",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar saída'),
                  content: const Text('Deseja realmente sair da conta?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sair'),
                    ),
                  ],
                ),
              );

              if (confirmed != true) return;

              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao sair: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/gif/lebron.gif',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/nba.png',
                      frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                        return Transform.translate(
                          offset: const Offset(0, -140),
                          child: child,
                        );
                      },
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 40),
                    _buildMenuButton(
                      context,
                      title: "Ver Times NBA",
                      icon: Icons.public,
                      color: Colors.blueGrey.withValues(alpha: 0.65),
                      page: ViewNbaTeamsPage(),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      title: "Meus Times Salvos",
                      icon: Icons.list_alt,
                      color: Colors.indigo.withValues(alpha: 0.65),
                      page: ViewMyTeamsPage(),
                    ),
                    const SizedBox(height: 20),
                    _buildMenuButton(
                      context,
                      title: "Criar Novo Time",
                      icon: Icons.add_circle_outline,
                      color: Colors.green.withValues(alpha: 0.65),
                      page: CreateTeamPage(),
                    ),
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required String title,
    required IconData icon,
    required Widget page,
    required Color color
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      icon: Icon(icon, size: 28),
      label: Text(title),
    );
  }
}
