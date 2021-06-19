import "package:path/path.dart";
import "package:sqflite/sqflite.dart";
import "../utils.dart" as utils;
import "ScoreModel.dart";


/// ********************************************************************************************************************
/// Database provider class for appointments.
/// ********************************************************************************************************************
class ScoresDBWorker {


  /// Static instance and private constructor, since this is a singleton.
  ScoresDBWorker._();
  static final ScoresDBWorker db = ScoresDBWorker._();


  /// The one and only database instance.
  Database _db;


  /// Get singleton instance, create if not available yet.
  ///
  /// @return The one and only Database instance.
  Future get database async {

    if (_db == null) {
      _db = await init();
    }
    print("## appointments AppointmentsDBWorker.get-database(): _db = $_db");
    return _db;

  } /* End database getter. */


  /// Initialize database.
  ///
  /// @return A Database instance.
  Future<Database> init() async {

    String path = join(utils.docsDir.path, "scores.db");
    print("## scores scoresDBWorker.init(): path = $path");
    Database db = await openDatabase(path, version : 1, onOpen : (db) { },
      onCreate : (Database inDB, int inVersion) async {
        await inDB.execute(
          "CREATE TABLE IF NOT EXISTS scores ("
            "id INTEGER PRIMARY KEY,"
            "title TEXT,"
            "description TEXT,"
            "scoretDate TEXT,"
            "scoretTime TEXT"
          ")"
        );
      }
    );
    return db;

  } /* End init(). */


  /// Create a Appointment from a Map.
  Score scoreFromMap(Map inMap) {

    print("## scores AppointmentsDBWorker.scoreFromMap(): inMap = $inMap");
    Score score = Score();
    score.id = inMap["id"];
    score.title = inMap["title"];
    score.description = inMap["description"];
    score.scoretDate = inMap["scoretDate"];
    score.scoreTime = inMap["scoretTime"];
    print("## scores AppointmentsDBWorker.scoreFromMap(): appointment = $score");

    return score;

  } /* End appointmentFromMap(); */


  /// Create a Map from a Appointment.
  Map<String, dynamic> scoreToMap(Score inScore) {

    print("## scores ScoresDBWorker.scoreToMap(): inScore = $inScore");
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = inScore.id;
    map["title"] = inScore.title;
    map["description"] = inScore.description;
    map["scoretDate"] = inScore.scoretDate;
    map["scoretTime"] = inScore.scoreTime;
    print("## scores ScoresDBWorker.scoreToMap(): map = $map");

    return map;

  } /* End appointmentToMap(). */


  /// Create a appointment.
  ///
  /// @param inAppointment the Appointment object to create.
  Future create(Score inScore) async {

    print("## scores ScoresDBWorker.create(): inScore = $inScore");

    Database db = await database;

    // Get largest current id in the table, plus one, to be the new ID.
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM appointments");
    int id = val.first["id"];
    if (id == null) { id = 1; }

    // Insert into table.
    return await db.rawInsert(
      "INSERT INTO appointments (id, title, description, apptDate, apptTime) VALUES (?, ?, ?, ?, ?)",
      [
        id,
        inScore.title,
        inScore.description,
        inScore.scoretDate,
        inScore.scoreTime
      ]
    );

  } /* End create(). */


  /// Get a specific appointment.
  ///
  /// @param  inID The ID of the appointment to get.
  /// @return      The corresponding Appointment object.
  Future<Score> get(int inID) async {

    print("## appointments AppointmentsDBWorker.get(): inID = $inID");

    Database db = await database;
    var rec = await db.query("appointments", where : "id = ?", whereArgs : [ inID ]);
    print("## appointments AppointmentsDBWorker.get(): rec.first = $rec.first");
    return scoreFromMap(rec.first);

  } /* End get(). */


  /// Get all appointments.
  ///
  /// @return A List of Appointment objects.
  Future<List> getAll() async {

    Database db = await database;
    var recs = await db.query("appointments");
    var list = recs.isNotEmpty ? recs.map((m) => scoreFromMap(m)).toList() : [ ];

    print("## appointments AppointmentsDBWorker.getAll(): list = $list");

    return list;

  } /* End getAll(). */


  /// Update a appointment.
  ///
  /// @param inAppointment The appointment to update.
  Future update(Score inAppointment) async {

    print("## appointments AppointmentsDBWorker.update(): inAppointment = $inAppointment");

    Database db = await database;
    return await db.update(
      "appointments", scoreToMap(inAppointment), where : "id = ?", whereArgs : [ inAppointment.id ]
    );

  } /* End update(). */


  /// Delete a appointment.
  ///
  /// @param inID The ID of the appointment to delete.
  Future delete(int inID) async {

    print("## appointments AppointmentsDBWorker.delete(): inID = $inID");

    Database db = await database;
    return await db.delete("appointments", where : "id = ?", whereArgs : [ inID ]);

  } /* End delete(). */


} /* End class. */