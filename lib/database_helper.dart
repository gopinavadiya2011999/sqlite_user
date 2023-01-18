import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_user/model/user_model.dart';

class DatabaseHelper {
  static const _dbName = 'userData';
  static const _dbVersion = 1;

  static const tableName = 'user';

  static const userId = 'userId';
  static const firstName = 'firstName';
  static const lastName = 'lastName';
  static const email = 'email';
  static const password = 'password';
  static const age = 'age';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $tableName(
    $userId TEXT  NOT NULL,
    $email TEXT NOT NULL,
    $password TEXT NOT NULL,
    $firstName TEXT NOT NULL,
    $lastName TEXT NOT NULL,
    $age TEXT NOT NULL
    )''');


  }

  Future<int> registerUser(UserModel userModel) async {
    Database database = await instance.database;
    return await database.insert(tableName, {
      'userId': userModel.userId,
      'firstName': userModel.firstName,
      'lastName': userModel.lastName,
      'email': userModel.email,
      'password': userModel.password,
      'age': userModel.age
    });
  }



  Future<List<Map<String, dynamic>>> getAllUser() async {
    Database database = await instance.database;
    return await database.query(tableName);
  }


  Future<int> updateUser(UserModel userModel) async {
    Database database = await instance.database;

    return database.update(tableName, userModel.toMap(),
        where: "userId = ?", whereArgs: [userModel.userId]);
  }

  Future<int> delete(UserModel userModel) async {
    Database database = await instance.database;

    return database.delete(tableName,
        where: "userId = ?", whereArgs: [userModel.userId]);
  }


}
