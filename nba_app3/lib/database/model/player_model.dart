class MyPlayer {
  int? id;
  String name;
  String position;
  int? apiId; 

  MyPlayer({this.id, required this.name, required this.position, this.apiId});

  Map<String, dynamic> toMap() => {
    'name': name,
    'position': position,
    'api_id': apiId,
  };

  factory MyPlayer.fromMap(Map<String, dynamic> map) {
    return MyPlayer(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      apiId: map['api_id'],
    );
  }
}