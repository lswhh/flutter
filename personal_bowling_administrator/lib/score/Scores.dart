import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "ScoresDBWorker.dart";
import "ScoreList.dart";
import "ScoresEntry.dart";
import "ScoreModel.dart" show ScoreModel, scoreModel;


/// ********************************************************************************************************************
/// The Appointments screen.
/// ********************************************************************************************************************
class Scores extends StatelessWidget {


  /// Constructor.
  Scores() {

    print("## Appointments.constructor");

    // Initial load of data.
    scoreModel.loadData("appointments", ScoresDBWorker.db);

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## Appointments.build()");

    return ScopedModel<ScoreModel>(
      model : scoreModel,
      child : ScopedModelDescendant<ScoreModel>(
        builder : (BuildContext inContext, Widget inChild, ScoreModel inModel) {
          return IndexedStack(
              index: inModel.stackIndex,
              children: [
                ScoreList(),
                ScoresEntry()
              ] /* End IndexedStack children. */
          ); /* End IndexedStack. */
        }
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


} /* End class. */
