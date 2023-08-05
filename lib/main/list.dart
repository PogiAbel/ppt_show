import 'package:flutter/material.dart';
import 'package:ppt_show/main/actions.dart';
import 'package:ppt_show/main/global.dart';

class SelectedReordableList extends StatefulWidget {
  const SelectedReordableList({super.key});

  @override
  State<SelectedReordableList> createState() => _SelectedReordableListState();
}

class _SelectedReordableListState extends State<SelectedReordableList> {
  List<SelectableItem> reorderList(
      List<SelectableItem> list, int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final SelectableItem item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return list;
  }

  ListTile selectableListTile(SelectableItem item) {
    return ListTile(
      title: Text('${item.key} : ${item.title}'),
      key: Key(item.keyString),
      tileColor: item.selected ? Colors.red : null,
      onTap: () async {
        openPPT(item.path);
        setState(() {
          item.toggleSelected();
        });
      },
      trailing: TextButton(
        onPressed: () => GlobalData.removeItem(item.key),
        child: const Icon(Icons.delete),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: GlobalData.itemsStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<SelectableItem>> snapshot) {
        return ReorderableListView(
          children: snapshot.data?.isEmpty ?? true
              ? []
              : snapshot.data!
                  // .map((item) => StatefulBuilder(
                  //     key: Key(item.keys.first.toString()),
                  //     builder: ((context, setState) => MyListTile(item: item))))
                  .map((item) => selectableListTile(item))
                  .toList(),
          onReorder: (oldIndex, newIndex) {
            GlobalData.items = reorderList(snapshot.data!, oldIndex, newIndex);
          },
        );
      },
    );
  }
}

class MyListTile extends StatefulWidget {
  final Map<int, String> item;

  const MyListTile({
    super.key,
    required this.item,
  });

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(widget.item.keys.first.toString()),
      tileColor: _isPressed ? Colors.red : null,
      title: Text(
          '${widget.item.keys.first.toString()} : ${widget.item.values.last.split('\\').last}'),
      onTap: () {
        openPPT(widget.item.values.last);
        setState(() {
          _isPressed = true;
        });
      },
      trailing: TextButton(
        onPressed: () => GlobalData.removeItem(widget.item.keys.first),
        child: const Icon(Icons.delete),
      ),
    );
  }
}

class SelectableTile {
  final String key;
  final String path;
  bool isSelected;

  SelectableTile(
      {required this.key, required this.path, this.isSelected = false});

  String get title => path.split('\\').last;
}
