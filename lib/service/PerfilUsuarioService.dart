import 'package:firebase_auth/firebase_auth.dart';
import '../database/MockDatabase.dart';
import '../model/UserModel.dart';

class PerfilUsuarioService {
  UserModel? obteerUsuarioAtual() {
    final userFirebase = FirebaseAuth.instance.currentUser;
    if (userFirebase == null) return null;

    // Tenta encontrar pelo UID primeiro; se não encontrar, tenta pelo e-mail
    try {
      return MockDatabase.usuarios.firstWhere(
        (u) => u.id == userFirebase.uid || u.email == userFirebase.email,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> atualizarPerfil({
    required String novoNome,
    required String novaBio,
    String? novaFotoUrl,
    String? novoBannerUrl,
  }) async {
    final usuario = obteerUsuarioAtual();
    if (usuario == null) return false;

    usuario.nome = novoNome;
    usuario.bio = novaBio;
    if (novaFotoUrl != null) usuario.fotoUrl = novaFotoUrl;
    if (novoBannerUrl != null) usuario.bannerUrl = novoBannerUrl;

    return true;
  }
}