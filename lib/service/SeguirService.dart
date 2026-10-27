import '../database/MockDatabase.dart';
import '../model/NotificacaoModel.dart';
import 'NotificacaoService.dart';

class SeguirService {
  bool estaSeguindo(String meuId, String usuarioAlvoId) {
    final usuarioAlvo = MockDatabase.usuarios.firstWhere(
      (u) => u.id == usuarioAlvoId,
      orElse: () => MockDatabase.usuarios.first,
    );
    return usuarioAlvo.seguidores.contains(meuId);
  }

  bool alternarSeguir({required String meuId, required String usuarioAlvoId}) {
    final usuarioLogado = MockDatabase.usuarios.firstWhere(
      (u) => u.id == meuId,
      orElse: () => MockDatabase.usuarios.first,
    );
    
    final usuarioAlvo = MockDatabase.usuarios.firstWhere(
      (u) => u.id == usuarioAlvoId,
      orElse: () => MockDatabase.usuarios.first,
    );

    final jaSegue = usuarioAlvo.seguidores.contains(meuId);

    if (jaSegue) {
      // Deixar de seguir
      usuarioAlvo.seguidores.remove(meuId);
      usuarioLogado.seguindo.remove(usuarioAlvoId);
      return false;
    } else {
      // Seguir
      usuarioAlvo.seguidores.add(meuId);
      usuarioLogado.seguindo.add(usuarioAlvoId);

      // 🚀 GERA NOTIFICAÇÃO REAL PARA O USUÁRIO ALVO
      NotificacaoService.adicionarNotificacao(
        NotificacaoModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          idDestinatario: usuarioAlvo.id,
          idRemetente: usuarioLogado.id,
          remetenteNome: usuarioLogado.nome,
          remetenteFotoUrl: usuarioLogado.fotoUrl,
          titulo: 'Novo Seguidor',
          mensagem: 'começou a seguir você.',
          tipo: TipoNotificacao.seguidor,
          dataHora: DateTime.now(),
        ),
      );

      return true;
    }
  }
}