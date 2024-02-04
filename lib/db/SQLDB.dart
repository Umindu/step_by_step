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
      "image" TEXT
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
      "image" TEXT,
      FOREIGN KEY (id_exp) REFERENCES experiment(id)
      )
     ''');
    print("=====================step created!==================");

    await db.execute('''
     CREATE TABLE "image" (
     "id" INTEGER PRIMARY KEY AUTOINCREMENT,
      "id_step" INTEGER NOT NULL,
      "image" BLOB,
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
}
