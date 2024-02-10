import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLdb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialisation();
      return _db;
    } else {
      return _db;
    }
  }

  //-------------------------------------
  Future<Database> initialisation() async {
    String db_path = await getDatabasesPath();
    String path = join(db_path, "StepbyStep");
    Database mydb = await openDatabase(path, onCreate: _createDB, version: 1);
    return mydb;
  }

  //----------------------------------------------------
  _createDB(Database db, int version) async {
    await db.execute('''
     CREATE TABLE "experiment" (
     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
     "date" TEXT NOT NULL,
     "title" TEXT NOT NULL,
     "description" TEXT,
      "image" TEXT,
      "status" TEXT
      )
     ''');
    print("=====================experiment created!==================");

    await db.execute('''
     CREATE TABLE "step" (
     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "id_exp" INTEGER NOT NULL,
     "date" TEXT NOT NULL,
     "title" TEXT NOT NULL,
     "description" TEXT,
      "status" TEXT,
      FOREIGN KEY (id_exp) REFERENCES experiment(id)
      )
     ''');
    print("=====================step created!==================");

    await db.execute('''
     CREATE TABLE "image" (
     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "id_exp" INTEGER NOT NULL,
      "id_step" INTEGER NOT NULL,
      "image" BLOB,
      "status" TEXT,
      FOREIGN KEY (id_exp) REFERENCES experiment(id),
      FOREIGN KEY (id_step) REFERENCES step(id)
      )
     ''');
    print("=====================image created!==================");
  }

  //------------------CRUD-------------------
  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    int rep = await mydb!.rawInsert(sql);
    return rep;
  }

//--------------------lecture ----------------
  Future<List<Map>> getData(String sql) async {
    Database? mydb = await db;
    List<Map> rep = await mydb!.rawQuery(sql);
    return rep;
  }

//--------------------------------------------
//---------------update-------------------------
  Future<int> updateData(String sql) async {
    Database? mydb = await db;
    int reponse = await mydb!.rawUpdate(sql);
    return reponse;
  }

//---------------------delete----------------------
  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    int reponse = await mydb!.rawDelete(sql);
    return reponse;
  }
//-------------------------

  deleteDB() async {
    try {
      deleteDatabase(
          "/data/user/0/com.example.step_by_step/databases/StepbyStep");
    } catch (e) {
      print(e);
    }
  }

  backupDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;

    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      File ourDBFile =
          File("/data/user/0/com.example.step_by_step/databases/StepbyStep");
      Directory? folderPathForFile =
          Directory("/storage/emulated/0/StepbyStep/");
      await folderPathForFile.create();
      Directory? folderPathForDBFile =
          Directory("/storage/emulated/0/StepbyStep/DatabasesBackup/");
      await folderPathForDBFile.create();
      await ourDBFile
          .copy("/storage/emulated/0/StepbyStep/DatabasesBackup/StepbyStep.db");
          
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  restoreDB() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
    var status1 = await Permission.storage.status;

    if (!status1.isGranted) {
      await Permission.storage.request();
    }

    try {
      await deleteDB();
      File ourDBFile =
          File("/storage/emulated/0/StepbyStep/Databases/StepbyStep.db");
      Directory? folderPathForDBFile =
          Directory("/data/user/0/com.example.step_by_step/databases");
      await folderPathForDBFile.create();
      await ourDBFile
          .copy("/data/user/0/com.example.step_by_step/databases/StepbyStep");

      _db = null;
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  importDB(File file) async {
    
    try {
      await deleteDB();
      //StepbyStep.zip file import
      Archive ourZipFile = ZipDecoder().decodeBytes(file.readAsBytesSync());
      for (ArchiveFile ourFile in ourZipFile) {
        String ourFileName = ourFile.name;
        if (ourFileName.contains("StepbyStep.db")) {
          File ourDBFile = File(
              "/data/user/0/com.example.step_by_step/databases/StepbyStep");
          await ourDBFile.writeAsBytes(ourFile.content);

          File ourFileToWrite =
              File("/data/user/0/com.example.step_by_step/$ourFileName");
          await ourFileToWrite.writeAsBytes(ourFile.content);
        } else {
          Directory ourImagesFolder =
              Directory("/data/user/0/com.example.step_by_step/Images");
          await ourImagesFolder.create();

          //get sub folder name
          String ourSubFolderName = ourFileName.split("_")[0];
          print(ourSubFolderName+ "=====================");

          //create sub folder
          Directory ourSubFolder = Directory(
              "/data/user/0/com.example.step_by_step/Images/$ourSubFolderName");
          await ourSubFolder.create();

          File ourFileToWrite = File(
              "/data/user/0/com.example.step_by_step/Images/$ourSubFolderName/$ourFileName");
          await ourFileToWrite.writeAsBytes(ourFile.content);
        }
      }

      _db = null;

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  exportDB() async {
    try {
      //get db file
      File ourDBFile =
          File("/data/user/0/com.example.step_by_step/databases/StepbyStep");

      Archive archive = Archive();

      //add the db file to the archive
      ArchiveFile ourDBArchiveFile = ArchiveFile(
          'StepbyStep.db', ourDBFile.lengthSync(), ourDBFile.readAsBytesSync());
      archive.addFile(ourDBArchiveFile);

      //archive the image folder to the compress
      Directory ourImagesFolder =
          Directory("/data/user/0/com.example.step_by_step/Images");
      List<FileSystemEntity> ourImageFiles =
          ourImagesFolder.listSync(recursive: true, followLinks: false);
      ourImageFiles.forEach((element) {
        if (FileSystemEntity.isFileSync(element.path)) {
          String ourImageFilePath = element.path;
          String ourImageFileName = basename(ourImageFilePath);
          ArchiveFile ourImageArchiveFile = ArchiveFile(
              ourImageFileName,
              File(ourImageFilePath).lengthSync(),
              File(ourImageFilePath).readAsBytesSync());
          archive.addFile(ourImageArchiveFile);
        }
      });

      File ourZipFile = File("/storage/emulated/0/Download/StepbyStep.zip");
      await ourZipFile.writeAsBytes(ZipEncoder().encode(archive)!);

      return ourZipFile;
    } catch (e) {
      print(e);
      return null;
    }
  }

  getDBPath() async {
    String databasePath = await getDatabasesPath();
    print("======================${databasePath}");
    Directory? externalStorangePath = await getExternalStorageDirectory();
    print("======================${externalStorangePath}");
  }
}
