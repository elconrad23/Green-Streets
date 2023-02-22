import 'package:sqflite/sqflite.dart';
import 'my_constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommentsModel {
  static const String TABLE_NAME = 'comments';
  int id = 0;
  int timeOnJourney = 0;
  int rating = 0;
  String comment = '';
  String destination = '';

  tableCreate() async {
    // Get a location using getDatabasesPath
    //and open the database
    var db = await openDatabase(AppConfig.LOCAL_DB_PATH);

    if (!db.isOpen) {
      return;
    }
    // When creating the db, create the table
    try {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS ${CommentsModel.TABLE_NAME} (id INTEGER PRIMARY KEY autoincrement, comment TEXT, destination TEXT, timeOnJourney INTEGER, rating REAL)');
    } catch (e) {
      Fluttertoast.showToast(
        msg: "failed to create db because ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        // timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    }
  }
}
