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
      home: CepPage(),
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

  Future<void> buscarCep() async {
    final cep = cepController.text.trim();

    final response = await http.get(
      Uri.parse('https://viacep.com.br/ws/$cep/json/'),
    );

    if (response.statusCode == 200) {
      final dados = jsonDecode(response.body);

      setState(() {
        logradouroController.text = dados['logradouro'] ?? '';
        bairroController.text = dados['bairro'] ?? '';
        localidadeController.text = dados['localidade'] ?? '';
        ufController.text = dados['uf'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consulta CEP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: cepController,
              decoration: const InputDecoration(
                labelText: 'CEP',
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: buscarCep,
              child: const Text('Consultar'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: logradouroController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Logradouro',
              ),
            ),

            TextField(
              controller: bairroController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Bairro',
              ),
            ),

            TextField(
              controller: localidadeController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Localidade',
              ),
            ),

            TextField(
              controller: ufController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'UF',
              ),
            ),
          ],
        ),
      ),
    );
  }
}