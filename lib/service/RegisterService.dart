import 'package:firebase_auth/firebase_auth.dart';
import '../database/MockDatabase.dart';
import '../model/UserModel.dart';

class RegisterService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    // 1. Cria a conta no Firebase Auth
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final String? uid = userCredential.user?.uid;

    if (uid != null) {
      final novoUsuario = UserModel(
        id: uid,
        nome: nome,
        email: email,
        senha: '', // Gerenciada pelo Firebase Auth
        seguidores: [],
        seguindo: [],
        publicacoes: [],
        mensagens: [],
      );

      // 2. Registra na base local para disponibilizar em pesquisas e perfis
      MockDatabase.usuarios.add(novoUsuario);

      return novoUsuario;
    }

    return null;
  }
}