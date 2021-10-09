import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:doc_lock/models/my_file.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import 'db_service.dart';

class FileService {
  late Database db;
  FileService(BuildContext context) {
    db = Provider.of<DBService>(context, listen: false).db;
    print(db);
  }

  Future<List<MyFile>> getFiles({int id = 0}) async {
    List<MyFile> fileList = [];
    var res = await db.query(
      MyFile.table,
      where: '${MyFile.columnParentId} = ?',
      whereArgs: [id],
    );
    res.forEach((e) {
      fileList.add(MyFile.fromMap(e));
    });
    fileList.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return fileList;
  }

  Future<MyFile> createFolder(String name, {int parentDirId = 0}) async {
    MyFile myFile = MyFile(
      name: name,
      path: "",
      parentDirId: parentDirId,
      isDirectory: true,
      lastModified: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert(MyFile.table, myFile.toMap());
    return myFile;
  }

  Future<List<MyFile>> insertFile(
    List<File> files, {
    int parentDirId = 0,
  }) async {
    var uuid = Uuid();
    final dirPath = (await getApplicationDocumentsDirectory()).path;
    List<MyFile> myFiles = [];
    for (File file in files) {
      final storagePath =
          p.join(dirPath, "files", "${uuid.v1()}${p.extension(file.path)}");
      File newFile = await file.copy(storagePath);
      MyFile myFile = MyFile(
        name: p.basename(file.path),
        path: newFile.path,
        parentDirId: parentDirId,
        isDirectory: false,
        size: newFile.lengthSync(),
        lastModified: DateTime.now().millisecondsSinceEpoch,
      );
      String mimeType = lookupMimeType(myFile.name) ?? "";
      if(mimeType.startsWith("image/")) myFile.fileType = FileType.image;
      else if(mimeType.startsWith("video/")) myFile.fileType = FileType.video;
      else if(mimeType.startsWith("audio/")) myFile.fileType = FileType.audio;
      else myFile.fileType = FileType.other;
      await db.insert(MyFile.table, myFile.toMap());
      myFiles.add(myFile);
    }
    return myFiles;
  }

  Future<MyFile> rename(MyFile myFile, String newName) async {
    myFile.name = newName;
    myFile.lastModified = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      MyFile.table,
      myFile.toMap(),
      where: '${MyFile.columnId} = ?}',
      whereArgs: [myFile.id],
    );
    return myFile;
  }

  Future<void> delete(MyFile myFile, String newName) async {}
}
