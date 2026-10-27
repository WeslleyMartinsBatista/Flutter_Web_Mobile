import 'package:flutter/material.dart';
import 'LoginView.dart';

class MenuSidebarView extends StatelessWidget {
  final Function(int) onSelecionarAba;

  const MenuSidebarView({
    Key? key,
    required this.onSelecionarAba,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Fundo escuro transparente (ao clicar fora, fecha o menu)
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Painel do Menu 50% da tela
        Material(
          color: const Color(0xFF071835),
          child: Container(
            width: larguraTela * 0.5,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF071835), Color(0xFF0A2A55)],
              ),
              border: Border(
                right: BorderSide(color: Colors.white24, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do Menu
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  
                  // Opções de Navegação
                  ListTile(
                    leading: const Icon(Icons.home_outlined, color: Colors.white),
                    title: const Text('Home', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      onSelecionarAba(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.search, color: Colors.white),
                    title: const Text('Pesquisar', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      onSelecionarAba(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: Colors.white),
                    title: const Text('Meu Perfil', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      onSelecionarAba(2);
                    },
                  ),
                  const Spacer(),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                    title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
                    onTap: () {
                      // 1. Fecha o Drawer/Menu lateral primeiro
                      Navigator.pop(context); 
                      
                      // 2. Redireciona para o Login destruindo a pilha de ecrãs anterior
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginView()),
                        (route) => false, // Remove todas as rotas anteriores da memória
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}