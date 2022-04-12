import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Private method to get local path
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  // print(directory.path);
  return directory.path;
}

/// Private method to get categories file
Future<File> get _categoriesFile async {
  final path = await _localPath;
  return File('$path/categories.txt');
}

/// Private method to get muted events file
Future<File> get _mutedeventsFile async {
  final path = await _localPath;
  return File('$path/mutedevents.txt');
}

/// async method to read content from file
/// Takes argument [fileName] of type String as name of the file
Future<String?> readContent(String fileName) async {
  // File declared
  final File file;
  try {
    // Condition to select respective file
    switch (fileName.toLowerCase()) {
      case "categories":
        file = await _categoriesFile;
        break;
      case "mutedevents":
        file = await _mutedeventsFile;
        break;
      default:
        file = await _categoriesFile;
        break;
    }
    // if File exists
    if (file.existsSync()) {
      // get contents via async call
      String contents = await file.readAsString();
      // return the contents of the file
      return contents;
    } else {
      // if no file, return null
      return null;
    }
  } catch (e) {
    // If encountering an error, return
    return 'Error! ${e.toString()}';
  }
}

/// async method to write content to file
/// Takes argument [fileName] of type String as name of the file
/// Takes argument [object] as List<dynamic> to write content
Future<File> writeContent(String fileName, List<dynamic> object) async {
  // File declared
  final File file;
  // Condition to select respective file
  switch (fileName.toLowerCase()) {
    case "categories":
      file = await _categoriesFile;
      break;
    case "mutedevents":
      file = await _mutedeventsFile;
      break;
    default:
      file = await _categoriesFile;
      break;
  }
  // jsonEncode the argument object
  String jsonObject = jsonEncode(object);
  // print("WRITING TO FILE: $jsonObject");
  // Write to file
  return file.writeAsString(jsonObject);
}

/// Method returns list of string as comma separated
/// Takes argument [ls] as type list and any additionalString like 'Uncat' added with comma
String getListAsCommaSepratedString(List<dynamic> ls, String additonalString) {
  return (ls.join(',') == null)
      ? additonalString
      : ls.join(',').toString() + ",$additonalString";
}
