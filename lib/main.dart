import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  /// LISTA DE TAREFAS
  List _toDoList = [];

//TUDO QUE ENVOVE ARQUIVOS NÃO OCORRE IMEDIATAMENTE POR ISSO TEM QUE SER ASYNC
  /// ELE RECEBE O CAMINHO E CASO NÃO EXISTA CRIA O ARQUIVO data.json
  Future<File> _getFile() async {
    // ASSIM QUE O GET CONSEGUIR O DIRETORIO ELE SAIRÁ DE AWAIT
    final directory = await getApplicationDocumentsDirectory();
    return File(
        "${directory.path}/data.json"); // O ARQUIVO SERA GUARDADO EM directory/data.json
  }

// SALVA OS DADOS
  Future<File> _saveData(List list) async {
    String data = jsonEncode(list); // ENCODA O JSON
    final file = await _getFile(); // ELE IRA ESPERAR A PASTA
    return file.writeAsString(data); // SERA SALVO COMO TEXTO
  }

// LÊ OS DADOS
  Future<String> _readData() async {
    /// BLOCO TRY
    try {
      final file = await _getFile(); //RECEBE A LOCAIZAÇÃO
      return file.readAsString(); // TENTA LER COMO STRING
    } catch (e) {
      return "error"; //CASO HAJA ERRO RETORNA ERROR
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
