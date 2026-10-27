import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../service/RegisterService.dart';

class RegisterController {
  final RegisterService _service = RegisterService();

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  Future<String?> realizarCadastro({
    required String nome,
    required String email,
    required String senha,
    required String confirmarSenha,
  }) async {
    // Validações de Negócio
    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      return 'Por favor, preencha todos os campos.';
    }

    if (senha != confirmarSenha) {
      return 'As senhas não coincidem.';
    }

    if (senha.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    isLoading.value = true;

    try {
      final usuario = await _service.cadastrarUsuario(
        nome: nome,
        email: email,
        senha: senha,
      );

      isLoading.value = false;

      if (usuario != null) {
        return null; // Retorna null em caso de sucesso (sem erros)
      } else {
        return 'Não foi possível concluir o cadastro.';
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      switch (e.code) {
        case 'weak-password':
          return 'A senha informada é muito fraca.';
        case 'email-already-in-use':
          return 'Este e-mail já está em uso.';
        case 'invalid-email':
          return 'O e-mail informado é inválido.';
        default:
          return 'Erro ao cadastrar usuário: ${e.message}';
      }
    } catch (e) {
      isLoading.value = false;
      return 'Ocorreu um erro inesperado: $e';
    }
  }

  void dispose() {
    isLoading.dispose();
  }
}