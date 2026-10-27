class PublicacaoModel {
  final String id;
  final String usuarioId;
  final String imagemUrl;
  final DateTime dataHora;
  final String? legenda; // <-- Adicione esta linha

  PublicacaoModel({
    required this.id,
    required this.usuarioId,
    required this.imagemUrl,
    required this.dataHora,
    this.legenda, // <-- Adicione esta linha para aceitar o parâmetro
  });
}