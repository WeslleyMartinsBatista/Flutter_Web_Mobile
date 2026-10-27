import '../model/NotificacaoModel.dart';

class NotificacaoService {
  // Lista global que armazenará as notificações em memória durante a execução
  static final List<NotificacaoModel> _notificacoes = [];

  // Adiciona uma nova notificação
  static void adicionarNotificacao(NotificacaoModel notificacao) {
    _notificacoes.insert(0, notificacao); // Adiciona no início (mais recente primeiro)
  }

  // Obtém apenas as notificações destinadas ao usuário logado
  static List<NotificacaoModel> obterNotificacoesDoUsuario(String idUsuarioLogado) {
    return _notificacoes
        .where((n) => n.idDestinatario == idUsuarioLogado)
        .toList();
  }
}