import 'package:doc_lock/models/my_file.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  late Database db;

  Future<void> openDB() async {
    db = await openDatabase(
      'doc.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        create table ${MyFile.table} ( 
          ${MyFile.columnId} integer primary key autoincrement, 
          ${MyFile.columnName} text not null,
          ${MyFile.columnPath} text not null,
          ${MyFile.columnParentId} integer not null,
          ${MyFile.columnSize} integer,
          ${MyFile.columnFileType} text,
          ${MyFile.columnLastModified} integer,
          ${MyFile.columnIsDirectory} integer not null)
      ''');
        MyFile myFile = MyFile(
          name: "root",
          path: "",
          parentDirId: -1,
          isDirectory: true,
        );
        await db.insert(MyFile.table, myFile.toMap());
      },
    );
  }
}
