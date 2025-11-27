import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nba_app3/database/model/team_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _teamsCollection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Usuário não logado");
    return _db.collection('users').doc(uid).collection('teams');
  }

  Future<void> saveTeam(MyTeam team) async {
    await _teamsCollection.add(team.toMap());
  }

  Stream<List<MyTeam>> getTeamsStream() {
    return _teamsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return MyTeam.fromMap(data, docId: doc.id);
      }).toList();
    });
  }

  Future<void> updateTeam(String docId, MyTeam team) async {
    if (docId.isEmpty) throw Exception("docId inválido");
    await _teamsCollection.doc(docId).update(team.toMap());
  }

  Future<void> deleteTeam(String docId) async {
    await _teamsCollection.doc(docId).delete();
  }
}
