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
  String _myTextTitle = "";
  final _toDoController = TextEditingController();

  //PARA CONSEGUIR GUARDAR AS INFORMAÇÕES SOBRE OS ULTIMOS REMOVIDOS
  //UTILIZADO O MAP PARA CASO HAJA VARIAS REMOÇÕES DE UMA SÓ VEZ!
  Map<String, dynamic> _lastRemoved = Map();
  int _lastRemovedPos = 0;

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

  void _addToDo() {
    Map<String, dynamic> newToDo = Map();
    newToDo["title"] = _toDoController.text;
    _toDoController.text = "";
    newToDo["ok"] = false;
    _toDoList.add(newToDo);
    _saveData(_toDoList);
    setState(() {});
  }

  _buildTile(context, index, mkey) => Dismissible(
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          // ADICIONA OS ITENS PARA O LAST REMOVE
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedPos = index;
          // APAGA O ITEM
          _toDoList.removeAt(index);
          _saveData(_toDoList);

          // MOSTRA UMA SNACKBAR
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
            children: [
              Expanded(child: Text("Deseja desfazer a ação?")),
              TextButton(
                  onPressed: () {
                    _toDoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData(_toDoList);
                    setState(() {});
                  },
                  child: Text("Desfazer"))
            ],
          )));
        },
        background: Container(
          color: Colors.redAccent,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ),
        key: UniqueKey(),
        child: CheckboxListTile(
          value: _toDoList[index]["ok"],
          onChanged: (value) {
            _toDoList[index]["ok"] = !_toDoList[index]["ok"];
            _saveData(_toDoList);
            setState(() {});
          },
          secondary: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
          title: Text(_toDoList[index]["title"]),
        ),
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _readData().then((value) => _toDoList = jsonDecode(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_lastRemovedPos);
    // _toDoList = [];
    // _saveData(_toDoList);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 245, 245, 245),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "Listas de Tarefas",
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.w900, fontSize: 32),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _toDoController,
                          onSubmitted: (text) => _addToDo(),
                          decoration: InputDecoration(
                            labelText: "Nova Tarefa",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 9, bottom: 9, left: 8, right: 16),
                      child: IconButton(
                        onPressed: () => _addToDo(),
                        icon: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              child: ListView.builder(
                itemCount: _toDoList.length,
                itemBuilder: (context, index) =>
                    _buildTile(context, index, widget.key),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
