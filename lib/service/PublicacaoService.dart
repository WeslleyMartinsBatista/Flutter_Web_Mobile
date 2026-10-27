import '../database/MockDatabase.dart';
import '../model/NotificacaoModel.dart';
import '../model/PublicacaoModel.dart';
import 'NotificacaoService.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicacaoService {
  
  List<PublicacaoModel> obterPublicacoesDoUsuario(String usuarioId) {
    try {
      final usuario = MockDatabase.usuarios.firstWhere(
        (u) => u.id == usuarioId,
      );
      return usuario.publicacoes;
    } catch (e) {
      return [];
    }
  }

  Future<bool> criarPublicacao({
    required String usuarioId,
    required String imagemUrl,
    String? legenda,
  }) async {
    try {
      // Procura o usuário por ID ou pelo e-mail do Firebase atual para evitar perda de referência
      final userFirebase = FirebaseAuth.instance.currentUser;
      
      final usuario = MockDatabase.usuarios.firstWhere(
        (u) => u.id == usuarioId || (userFirebase != null && u.email == userFirebase.email),
        orElse: () => MockDatabase.usuarios.first,
      );

      final novaPublicacao = PublicacaoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        usuarioId: usuario.id,
        imagemUrl: imagemUrl,
        dataHora: DateTime.now(),
        legenda: legenda,
      );

      // Adiciona diretamente na lista do modelo em memória
      usuario.publicacoes.insert(0, novaPublicacao); // Insere no topo para aparecer primeiro

      // Dispara a notificação para os seguidores
      notificarSeguidoresNovoPost(
        idAutor: usuario.id,
        nomeAutor: usuario.nome,
        fotoUrlAutor: usuario.fotoUrl,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  void notificarSeguidoresNovoPost({
    required String idAutor,
    required String nomeAutor,
    String? fotoUrlAutor,
  }) {
    try {
      final autor = MockDatabase.usuarios.firstWhere((u) => u.id == idAutor);

      for (String idSeguidor in autor.seguidores) {
        NotificacaoService.adicionarNotificacao(
          NotificacaoModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            idDestinatario: idSeguidor,
            idRemetente: autor.id,
            remetenteNome: nomeAutor,
            remetenteFotoUrl: fotoUrlAutor,
            titulo: 'Nova Publicação',
            mensagem: 'publicou uma nova foto.',
            tipo: TipoNotificacao.publicacao,
            dataHora: DateTime.now(),
          ),
        );
      }
    } catch (_) {}
  }
}