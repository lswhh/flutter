import "../BaseModel.dart";


/// A class representing this PIM entity type.
class Score {


  /// The fields this entity type contains.
  int id;
  String title;
  String description;
  String scoretDate; // YYYY,MM,DD
  String scoretTime; // HH,MM


  /// Just for debugging, so we get something useful in the console.
  String toString() {
    return "{ id=$id, title=$title, description=$description, apptDate=$scoretDate, apptDate=$scoretTime }";
  }


} /* End class. */


/// ********************************************************************************************************************
/// The model backing this entity type's views.
/// ********************************************************************************************************************
class ScoreModel extends BaseModel {


  /// The appointment time.  Needed to be able to display what the user picks in the Text widget on the entry screen.
  String scoretTime;


  /// For display of the appointment time chosen by the user.
  ///
  /// @param inApptTime The appointment date in HH:MM form.
  void setScoretTime(String inScoretTime) {

    scoretTime = inScoretTime;
    notifyListeners();

  } /* End setApptTime(). */


} /* End class. */


// The one and only instance of this model.
ScoreModel scoreModel = ScoreModel();
