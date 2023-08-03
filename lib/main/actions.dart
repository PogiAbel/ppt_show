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
  try {
    process = await Process.run(GlobalData.getExePath, ['/o', '']);
  } catch (e) {
    throw Exception('Could not open file');
  }
  result = process.stdout.toString().toLowerCase().contains('powerpnt.exe');
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
