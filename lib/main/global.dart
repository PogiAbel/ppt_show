import 'dart:async';

class GlobalData {
  static String _exeFilePath =
      'C:\\Program Files\\Microsoft Office\\root\\Office16\\powerpnt.exe';
  static final StreamController<List<SelectableItem>> _itemsController =
      StreamController<List<SelectableItem>>.broadcast();
  static List<SelectableItem> _selectedItems = [];

  static List<SelectableItem> get listItems => _selectedItems;

  static set items(List<SelectableItem> value) {
    _selectedItems = value;
    remakeKeys();
    _itemsController.add(_selectedItems);
  }

  static remakeKeys() {
    for (var i = 0; i < _selectedItems.length; i++) {
      _selectedItems[i].key = i + 1;
    }
  }

  static addItem(String value) {
    _selectedItems.add(SelectableItem(_selectedItems.length + 1, value));
    _itemsController.add(_selectedItems);
  }

  static removeItem(int key) {
    _selectedItems.removeWhere((element) => element.key == key);
    remakeKeys();
    _itemsController.add(_selectedItems);
  }

  static Stream<List<SelectableItem>> get itemsStream =>
      _itemsController.stream;

  static get getExePath => _exeFilePath;
  static set setExePath(String value) {
    _exeFilePath = value;
  }
}

class SelectableItem {
  int key;
  String path;
  bool selected = false;
  SelectableItem(this.key, this.path);

  String get title => path.split('\\').last;
  String get keyString => key.toString();

  void toggleSelected() {
    selected = true;
  }
}
