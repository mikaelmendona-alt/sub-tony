import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const CepPage(),
    );
  }
}

class CepPage extends StatefulWidget {
  const CepPage({super.key});

  @override
  State<CepPage> createState() => _CepPageState();
}

class _CepPageState extends State<CepPage> {
  final cepController = TextEditingController();
  final logradouroController = TextEditingController();
  final bairroController = TextEditingController();
  final localidadeController = TextEditingController();
  final ufController = TextEditingController();

  bool carregando = false;

  @override
  void dispose() {
    cepController.dispose();
    logradouroController.dispose();
    bairroController.dispose();
    localidadeController.dispose();
    ufController.dispose();
    super.dispose();
  }

  void _limparTudo() {
    cepController.clear();
    logradouroController.clear();
    bairroController.clear();
    localidadeController.clear();
    ufController.clear();
  }

  void _aviso(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> buscarCep() async {
    FocusScope.of(context).unfocus();
    final cep = cepController.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      _aviso('Informe um CEP válido com 8 dígitos.');
      return;
    }

    setState(() => carregando = true);

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br'),
      );

      if (response.statusCode == 200) {
        final dados = jsonDecode(response.body);

        if (dados['erro'] == true) {
          logradouroController.clear();
          bairroController.clear();
          localidadeController.clear();
          ufController.clear();
          _aviso('CEP não encontrado.');
          return;
        }

        setState(() {
          logradouroController.text = dados['logradouro'] ?? '';
          bairroController.text = dados['bairro'] ?? '';
          localidadeController.text = dados['localidade'] ?? '';
          ufController.text = dados['uf'] ?? '';
        });
      } else {
        _aviso('Erro no servidor (${response.statusCode}).');
      }
    } catch (_) {
      _aviso('Sem conexão com a internet.');
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca de CEP'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _limparTudo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Limpar campos',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: cepController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => buscarCep(),
              maxLength: 9,
              decoration: InputDecoration(
                labelText: 'Digite o CEP',
                hintText: '79400-000',
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: carregando ? null : buscarCep,
                icon: carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.location_searching),
                label: Text(carregando ? 'Buscando...' : 'Consultar CEP'),
              ),
            ),
            const SizedBox(height: 24),
            _campoResultado(logradouroController, 'Logradouro', Icons.signpost),
            const SizedBox(height: 12),
            _campoResultado(bairroController, 'Bairro', Icons.map),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _campoResultado(
                    localidadeController,
                    'Cidade',
                    Icons.location_city,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _campoResultado(ufController, 'UF', Icons.flag),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoResultado(
    TextEditingController controller,
    String label,
    IconData icone,
  ) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, color: Colors.blue),
        filled: true,
        fillColor: Colors.blue.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
