import 'package:path/path.dart' as p;

class MyFile {
  static String table = "files";
  static String columnId = 'id';
  static String columnName = 'name';
  static String columnPath = 'path';
  static String columnParentId = 'parent_id';
  static String columnSize = 'size';
  static String columnIsDirectory = 'directory';
  static String columnFileType = 'file_type';
  static String columnLastModified = 'modified';

  int? id;
  late String name;
  late String path;
  late int parentDirId;
  int? size;
  bool isDirectory;
  FileType? fileType;
  late int? lastModified;

  MyFile({
    this.id,
    required this.name,
    required this.path,
    required parentDirId,
    this.size = 0,
    this.isDirectory = true,
    this.fileType,
    this.lastModified,
  });

  factory MyFile.fromMap(Map map) {
    return MyFile(
      id: map[columnId],
      name: map[columnName],
      path: map[columnPath],
      parentDirId: map[columnParentId],
      size: map[columnSize],
      isDirectory: map[columnIsDirectory] == 0,
      fileType: stringToFileType(p.extension(map[columnFileType])),
      lastModified: map[columnLastModified],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      columnName: name,
      columnPath: path,
      columnParentId: parentDirId,
      columnSize: size,
      columnIsDirectory: isDirectory ? 0 : 1,
      columnFileType: fileTypeToString(fileType),
      columnLastModified: lastModified,
    };
    if (id != null) map[columnId] = id;
    return map;
  }

  static String fileTypeToString(FileType? t) {
    switch (t) {
      case FileType.image:
        return 'image';
      case FileType.video:
        return 'video';
      case FileType.audio:
        return 'audio';
      default:
        return 'other';
    }
  }

  static FileType stringToFileType(String? t) {
    switch (t) {
      case 'image':
        return FileType.image;
      case 'video':
        return FileType.video;
      case 'audio':
        return FileType.audio;
      default:
        return FileType.other;
    }
  }
}

enum FileType { image, video, audio, other }
