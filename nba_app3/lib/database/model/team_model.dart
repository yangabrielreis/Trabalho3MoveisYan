import 'player_model.dart';

class MyTeam {
  String? id;
  String name;
  String state;
  String? logoPath;
  List<MyPlayer> players;

  MyTeam({
    this.id,
    required this.name,
    required this.state,
    this.logoPath,
    required this.players,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': state,
      'logo_path': logoPath,
      'players': players.map((p) => p.toMap()).toList(),
    };
  }

  factory MyTeam.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MyTeam(
      id: docId,
      name: map['name'] ?? '',
      state: map['state'] ?? '',
      logoPath: map['logo_path'],
      players: map['players'] != null
          ? List<MyPlayer>.from(
              (map['players'] as List).map((x) => MyPlayer.fromMap(x)))
          : [],
    );
  }
}
