import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ppt_show/main/list.dart';
import 'actions.dart';
import 'global.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> folderPaths = [];
  List<FolderAndItemsExpansionTile> folderAndItems = [];
  final TextEditingController _searchController = TextEditingController();
  bool goodPwpointExePath = false;

  void _pickFolder() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    List<FileSystemEntity> folders = await listFolders(path!);
    setState(() {
      folderPaths.add(path);
      folderPaths.addAll(folders.map((e) => e.path));
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
      folderAndItems
          .removeWhere((element) => element.title == path.split('\\').last);
      folderPaths.remove(path);
    });
  }

  void removeFolderTile(String path) {
    setState(() {
      folderAndItems
          .removeWhere((element) => element.title == path.split('\\').last);
    });
  }

  void checkExe() async {
    bool result = await checkExePath();
    print("Result: $result");
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
        folderAndItems.add(FolderAndItemsExpansionTile(
          title: path,
          listItems: fileNames,
          //  onItemTap: (String item) => _openPPT(item),
          filterController: _searchController,
        ));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkExe();
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
        title: const Text('Main Screen'),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: TextField(
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 103, 182, 255),
                hintText: 'SearchBar',
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              controller: _searchController,
              cursorColor: Colors.black,
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
                    setState(() {
                      GlobalData.setExePath = path;
                      checkExe();
                    });
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
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: folderAndItems,
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
