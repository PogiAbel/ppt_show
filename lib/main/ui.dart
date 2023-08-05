import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ppt_show/main/list.dart';
import 'actions.dart';
import 'global.dart';
import 'package:path_provider/path_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> folderPaths = [];
  Map<String, List<String>> folderAndItems = {};
  final TextEditingController _searchController = TextEditingController();
  bool goodPwpointExePath = false;
  bool? _allFolders = false;
  String selectedItem = "";
  Directory? appDocDir;

  void loadData() async {
    await setData();
    checkExe();
  }

  Future<void> setData() async {
    appDocDir = await getApplicationDocumentsDirectory();
    if (appDocDir != null) {
      var entries =
          await appDocDir!.list(recursive: true, followLinks: false).toList();
      for (var values in entries) {
        // get data.json
        if (values.path.endsWith('data.json')) {
          String data = File(values.path).readAsStringSync();
          Map<String, dynamic> dataDecoded = json.decode(data);
          GlobalData.setExePath = dataDecoded.keys.first;
          List<String> paths = dataDecoded.values.first.cast<String>();
          setState(() {
            folderPaths.addAll(paths);
          });
          for (var folder in folderPaths) {
            _getFiles(folder);
          }
        }
      }
    } else {
      await File('${appDocDir!.path}\\data.json').create();
    }
  }

  void _pickFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    List<FileSystemEntity> folders = await listFolders(path!);
    setState(() {
      if (!folderPaths.contains(path)) folderPaths.add(path);

      folderPaths.addAll(folders
          .map((e) => e.path)
          .where((element) => !folderPaths.contains(element)));

      for (var folder in folderPaths) {
        _getFiles(folder);
      }
    });
  }

  Future<String> _selectExe() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    return result?.files.single.path == null ? "" : result!.files.single.path!;
  }

  Future<List<FileSystemEntity>> listFolders(String path) async {
    Directory directory = Directory(path);
    var lister = directory.list(recursive: true, followLinks: false);
    var entityList =
        await lister.where((entity) => entity is Directory).toList();
    return entityList;
  }

  void _removeFolder(String path) async {
    setState(() {
      folderAndItems.removeWhere((key, value) => key == path);
      folderPaths.remove(path);
      if (selectedItem == path) {
        selectedItem =
            folderAndItems.isNotEmpty ? folderAndItems.keys.first : "";
      }
    });
  }

  void removeFolderTile(String path) {
    setState(() {
      folderAndItems.removeWhere((key, value) => key == path.split('\\').last);
    });
  }

  void checkExe() async {
    bool result = await checkExePath();
    setState(() {
      goodPwpointExePath = result;
    });
  }

  void _getFiles(String path) async {
    final Directory dir = Directory(path);
    List<String> fileNames = [];

    final List<FileSystemEntity> files = dir.listSync();
    for (FileSystemEntity entity in files) {
      if (entity.path.endsWith('.pptx') ||
          entity.path.endsWith('.ppt') ||
          entity.path.endsWith('.pps')) {
        fileNames.add(entity.path);
      }
    }
    if (fileNames.isNotEmpty) {
      setState(() {
        folderAndItems.addAll({path: fileNames});
        selectedItem = path;
      });
    }
  }

  List<Widget> _getSongs() {
    List<Widget> songs = [];
    String filter = _searchController.text;
    if (!_allFolders!) {
      if (folderAndItems.isNotEmpty) {
        songs = folderAndItems[selectedItem]!
            .where((element) => element.toLowerCase().contains(filter))
            .map((e) => ListTile(
                  title: Text(e.split('\\').last),
                  onTap: () async {
                    setState(() {
                      GlobalData.addItem(e);
                    });
                  },
                ))
            .toList();
      }
    } else {
      if (folderAndItems.isNotEmpty) {
        for (var item in folderAndItems.keys) {
          songs.addAll(folderAndItems[item]!
              .where((element) => element.toLowerCase().contains(filter))
              .map((e) => ListTile(
                    title: Text(e.split('\\').last),
                    onTap: () async {
                      setState(() {
                        GlobalData.addItem(e);
                      });
                    },
                  ))
              .toList());
        }
      }
    }
    setState(() {});
    return songs;
  }

  void writeFile() async {
    File('${appDocDir!.path}\\data.json')
        .writeAsString(jsonEncode({GlobalData.getExePath: folderPaths}));
  }

  void tryExe() {
    checkExe();
    if (goodPwpointExePath) {
      try {
        Process.run(GlobalData.getExePath, ['/b']);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPT launcher'),
        actions: [
          Row(
            children: [
              FilledButton(onPressed: checkExe, child: const Text('Check')),
              FilledButton(onPressed: writeFile, child: const Text('Mentés')),
              Checkbox(
                  value: _allFolders,
                  onChanged: (value) => setState(() {
                        _allFolders = value;
                      })),
              const Text("Összes mappából"),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 103, 182, 255),
                hintText: 'Keresés...',
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              controller: _searchController,
              cursorColor: Colors.black,
              onChanged: (value) => _getSongs(),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Center(
              child: Container(
                height: 30,
                color: goodPwpointExePath ? Colors.green : Colors.red,
                child: Center(
                    child: TextButton(
                  onPressed: () async {
                    String path = await _selectExe();
                    if (path == "") {
                      goodPwpointExePath = false;
                    } else {
                      setState(() {
                        GlobalData.setExePath = path;
                        checkExe();
                      });
                    }
                  },
                  child: Text(
                    'A powerpoint exe ${goodPwpointExePath ? 'megvan' : 'nincs meg'}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                )),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ListView(
                            children: folderPaths
                                .map((e) => ListTile(
                                    title: Text(e),
                                    onTap: () async {
                                      _getFiles(e);
                                    },
                                    trailing: TextButton(
                                        onPressed: () => _removeFolder(e),
                                        child: const Icon(Icons.delete))))
                                .toList(),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: _pickFolder,
                            child: const Icon(Icons.add)),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton(
                            value: selectedItem,
                            items: folderAndItems.keys
                                .map((key) => DropdownMenuItem(
                                      value: key,
                                      child: Text(key.split("\\").last),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedItem = value!;
                              });
                            }),
                        // Songs
                        Expanded(
                          flex: 1,
                          child: ListView(
                            children: _getSongs(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 4,
                    child: SelectedReordableList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
