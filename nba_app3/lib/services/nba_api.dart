import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nba_app3/database/model/player_model.dart';
import 'package:nba_app3/database/model/team_model.dart';


class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => 'ApiException: $message';
}

class NbaApi {
  final String baseUrl = "https://v1.basketball.api-sports.io";
  final String apiKey = "971aa846ce98df069384f28378939647";

  Future<List<MyPlayer>> getPlayersFromTeam(int teamId, String season) async {
    final url = Uri.parse('$baseUrl/players?team=$teamId&season=$season');
    
    try {
      final response = await http.get(url, headers: {
        'x-rapidapi-host': 'v1.basketball.api-sports.io',
        'x-rapidapi-key': apiKey
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['response'];

        return data.map((json) => MyPlayer(
          apiId: json['id'],
          name: json['name'] ?? 'Sem Nome',
          position: json['position'] ?? 'N/A',
        )).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Erro API: $e");
      return [];
    }
  }

  Future<List<dynamic>> getTeamsNBA({int leagueId = 12, String? season, String? search}) async {
    final params = <String, String>{'league': leagueId.toString()};
    if (season != null) params['season'] = season;

    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/teams').replace(
      queryParameters: params,
    );
    

    final headers = {
      'x-rapidapi-key': apiKey,
      'x-rapidapi-host': 'v1.basketball.api-sports.io',
      'Accept': 'application/json',
    };

    final response = await http.get(uri, headers: headers);


    if (response.statusCode != 200) {
      throw ApiException('Erro: ${response.statusCode}');
    }

    final Map<String, dynamic> body = json.decode(response.body) as Map<String, dynamic>;
    if (!body.containsKey('response')) {
      throw ApiException('Formato inesperado');
    }

    return body['response'] as List<dynamic>;
  }
}