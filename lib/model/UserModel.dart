import 'package:flutter_web_mobile/model/MessageModel.dart';
import 'package:flutter_web_mobile/model/PublicacaoModel.dart';

class UserModel {
  String id;
  String nome;
  String email;
  String senha;
  List<MessageModel> mensagens;
  String? fotoUrl;
  String? bannerUrl;
  String bio;
  List<String> seguidores;          // IDs
  List<String> seguindo;            // IDs
  List<PublicacaoModel> publicacoes;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.mensagens,
    this.fotoUrl,
    this.bannerUrl,
    this.bio = 'Entusiasta do Flutter & Desenvolvimento Mobile!',
    List<String>? seguidores,
    List<String>? seguindo,
    List<PublicacaoModel>? publicacoes,
  })  : seguidores = seguidores ?? [],
        seguindo = seguindo ?? [],
        publicacoes = publicacoes ?? [];
}