import 'package:flutter/material.dart';
import '../model/UserModel.dart';
import '../model/PublicacaoModel.dart';
import '../service/PerfilUsuarioService.dart';
import '../service/PublicacaoService.dart';

class PerfilUsuarioController {
  final PerfilUsuarioService _perfilService = PerfilUsuarioService();
  final PublicacaoService _publicacaoService = PublicacaoService();

  final ValueNotifier<UserModel?> usuario = ValueNotifier<UserModel?>(null);
  final ValueNotifier<List<PublicacaoModel>> publicacoes = ValueNotifier<List<PublicacaoModel>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  void carregarPerfil() {
    isLoading.value = true;

    final usuarioEncontrado = _perfilService.obteerUsuarioAtual();
    usuario.value = usuarioEncontrado;

    if (usuarioEncontrado != null) {
      _carregarPublicacoes(usuarioEncontrado.id);
    }

    isLoading.value = false;
  }

  void _carregarPublicacoes(String usuarioId) {
    final lista = _publicacaoService.obterPublicacoesDoUsuario(usuarioId);
    publicacoes.value = List.from(lista); // Cria uma nova instância de lista para forçar o ValueListenableBuilder a redesenhar
  }

  // Método para adicionar publicação
  Future<bool> adicionarPublicacao(String caminhoOuUrlImagem, {String? legenda}) async {
    if (usuario.value == null) return false;

    isLoading.value = true;

    final sucesso = await _publicacaoService.criarPublicacao(
      usuarioId: usuario.value!.id,
      imagemUrl: caminhoOuUrlImagem,
      legenda: legenda,
    );

    if (sucesso) {
      _carregarPublicacoes(usuario.value!.id); // Atualiza a lista reativa
    }

    isLoading.value = false;
    return sucesso;
  }

  Future<bool> salvarEdicaoPerfil({
    required String novoNome,
    required String novaBio,
    String? novaFotoUrl,
    String? novoBannerUrl,
  }) async {
    isLoading.value = true;

    final sucesso = await _perfilService.atualizarPerfil(
      novoNome: novoNome,
      novaBio: novaBio,
      novaFotoUrl: novaFotoUrl,
      novoBannerUrl: novoBannerUrl,
    );

    isLoading.value = false;

    if (sucesso) {
      carregarPerfil();
      return true;
    }
    return false;
  }

  void dispose() {
    usuario.dispose();
    publicacoes.dispose();
    isLoading.dispose();
  }
}