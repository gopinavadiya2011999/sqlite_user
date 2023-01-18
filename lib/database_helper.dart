import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _dbName = 'smsForwarding';
  static const _dbVersion = 1;

  static const tableName = 'smsData';
  static const msgHistoryName = 'smsHistory';

  static const msgId = 'msgId';
  static const msg = 'msg';
  static const fromWho = 'fromWho';
  static const dateTime = 'dateTime';
  static const senderNo = 'senderNo';

  static const countryCode = 'countryCode';
  static const smsId = 'smsId';
  static const text = 'text';
  static const switchOn = 'switchOn';
  static const otpSwitch = 'otpSwitch';
  static const filterName = 'filterName';

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
    $smsId INTEGER  NOT NULL,
    $text TEXT NOT NULL,
    $filterName TEXT NOT NULL,
    $switchOn INTEGER NOT NULL,
    $otpSwitch INTEGER NOT NULL,
    $countryCode TEXT NOT NULL
    )''');

    await db.execute('''
    CREATE TABLE $msgHistoryName(
    $msgId INTEGER NOT NULL,
    $msg TEXT NOT NULL,
    $fromWho TEXT NOT NULL,
    $dateTime TEXT NOT NULL,
    $senderNo TEXT NOT NULL
    )''');
  }

  Future<int> insert(SmsModel shoppingModel) async {
    Database database = await instance.database;
    return await database.insert(tableName, {
      'smsId': shoppingModel.smsId,
      'text': shoppingModel.text,
      'filterName': shoppingModel.filterName,
      'switchOn': shoppingModel.switchOn,
      'otpSwitch': shoppingModel.otpSwitch,
      'countryCode': shoppingModel.countryCode,
    });
  }

  Future<int> insertMessage(MessageModel messageModel) async {
    Database database = await instance.database;
    return await database.insert(msgHistoryName, {
      'msgId': messageModel.msgId,
      'msg': messageModel.msg,
      'fromWho': messageModel.fromWho,
      'dateTime': messageModel.dateTime,
      'senderNo': messageModel.senderNo,
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database database = await instance.database;
    return await database.query(tableName);
  }

  Future<List<Map<String, dynamic>>> getAllSms() async {
    Database database = await instance.database;
    return await database.query(msgHistoryName);
  }

  Future<int> update(SmsModel shoppingModel) async {
    Database database = await instance.database;

    return database.update(tableName, shoppingModel.toMap(),
        where: "smsId = ?", whereArgs: [shoppingModel.smsId]);
  }

  Future<int> delete(SmsModel shoppingModel) async {
    Database database = await instance.database;

    return database.delete(tableName,
        where: "smsId = ?", whereArgs: [shoppingModel.smsId]);
  }

  Future<int> deleteSms(MessageModel messageModel) async {
    Database database = await instance.database;

    return database.delete(msgHistoryName,
        where: "msgId = ?", whereArgs: [messageModel.msgId]);
  }
}
