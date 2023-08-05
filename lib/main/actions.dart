import 'dart:io';
import 'package:flutter/material.dart';

import 'global.dart';

Future<bool> openPPT(String filePath) async {
  try {
    await Process.run(GlobalData.getExePath, ['/o', filePath]);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> checkExePath() async {
  bool result = false;
  ProcessResult process;
  if (GlobalData.getExePath == null ||
      GlobalData.getExePath.isEmpty ||
      !GlobalData.getExePath
          .toString()
          .toLowerCase()
          .contains("powerpnt.exe")) {
    return false;
  }
  try {
    process = await Process.run(
        'if', ['exist', GlobalData.getExePath, 'echo', 'true'],
        runInShell: true);
  } catch (e) {
    throw Exception('Could not open file');
  }
  result = process.stdout.toString().toLowerCase().contains('true');
  return result;
}

class PopUp extends StatelessWidget {
  const PopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Error'),
      content: Text('Could not open file'),
    );
  }
}
