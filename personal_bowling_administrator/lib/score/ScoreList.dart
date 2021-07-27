import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:scoped_model/scoped_model.dart";
import "package:intl/intl.dart";
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import "package:flutter_calendar_carousel/classes/event.dart";
import "package:flutter_calendar_carousel/classes/event_list.dart";
import "ScoresDBWorker.dart";
import "ScoreModel.dart" show Score, ScoreModel, scoreModel;


/// ********************************************************************************************************************
/// The Score List sub-screen.
/// ********************************************************************************************************************
class ScoreList extends StatelessWidget {

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## ScoresList.build()");

    // The list of dates with scores.
    EventList<Event> _markedDateMap = EventList();
    for (int i = 0; i < scoreModel.entityList.length; i++) {
      Score score = scoreModel.entityList[i];
      List dateParts = score.scoretDate.split(",");
      DateTime scoretDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      _markedDateMap.add(
          scoretDate, Event(date : scoretDate, icon : Container(decoration : BoxDecoration(color : Colors.blue)))
      );
    }

    // Return widget.
    return ScopedModel<ScoreModel>(
      model : scoreModel,
      child : ScopedModelDescendant<ScoreModel>(
        builder : (inContext, inChild, inModel) {
          return Scaffold(
            // Add Score.
            floatingActionButton : FloatingActionButton(
              child : Icon(Icons.add, color : Colors.white),
              onPressed : () async {
                scoreModel.entityBeingEdited = Score();
                DateTime now = DateTime.now();
                scoreModel.entityBeingEdited.scoretDate = "${now.year},${now.month},${now.day}";
                scoreModel.setChosenDate(DateFormat.yMMMMd("en_US").format(now.toLocal()));
                scoreModel.setScoretTime(null);
                scoreModel.setStackIndex(1);
              }
            ),
              body: Container(
                  margin : EdgeInsets.symmetric(horizontal : 10),
                  child : CalendarCarousel<Event>(
                      thisMonthDayBorderColor : Colors.grey,
                      daysHaveCircularBorder : true,
                      markedDatesMap : _markedDateMap,
                      onDayPressed : (DateTime inDate, List<Event> inEvents) {
                        _showScores(inDate, inContext);
                      }
                  ) /* End CalendarCarousel. */
              ) /* End Container. */
            //   body : Column(
            //   children : [
            //     Expanded(
            //       child : Container(
            //         margin : EdgeInsets.symmetric(horizontal : 10),
            //         child : CalendarCarousel<Event>(
            //           thisMonthDayBorderColor : Colors.grey,
            //           daysHaveCircularBorder : false,
            //           markedDatesMap : _markedDateMap,
            //           onDayPressed : (DateTime inDate, List<Event> inEvents) {
            //             _showAppointments(inDate, inContext);
            //           }
            //         ) /* End CalendarCarousel. */
            //       ) /* End Container. */
            //     ) /* End Expanded. */
            //   ] /* End Column.children. */
            // ) /* End Column. */
          ); /* End Scaffold. */
        } /* End ScopedModelDescendant builder(). */
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Show a bottom sheet to see the scores for the selected day.
  ///
  /// @param inDate    The date selected.
  /// @param inContext The build context of the parent widget.
  void _showScores(DateTime inDate, BuildContext inContext) async {

    print(
      "## ScoresList._showScores(): inDate = $inDate (${inDate.year},${inDate.month},${inDate.day})"
    );

    print("## ScoresList._showScores(): scoreModel.entityList.length = "
      "${scoreModel.entityList.length}");
    print("## ScoresList._showScores(): scoreModel.entityList = "
      "${scoreModel.entityList}");

    showModalBottomSheet(
      context : inContext,
      builder : (BuildContext inContext) {
        return ScopedModel<ScoreModel>(
          model : scoreModel,
          child : ScopedModelDescendant<ScoreModel>(
            builder : (BuildContext inContext, Widget inChild, ScoreModel inModel) {
              return Scaffold(
                body : Container(
                  child : Padding(
                    padding : EdgeInsets.all(10),
                    child : GestureDetector(
                      child : Column(
                        children : [
                          Text(
                            DateFormat.yMMMMd("en_US").format(inDate.toLocal()),
                            textAlign : TextAlign.center,
                            style : TextStyle(color : Theme.of(inContext).accentColor, fontSize : 24)
                          ),
                          Divider(),
                          Expanded(
                            child : ListView.builder(
                              itemCount : scoreModel.entityList.length,
                              itemBuilder : (BuildContext inBuildContext, int inIndex) {
                                Score score = scoreModel.entityList[inIndex];
                                print("## ScoreList._showScores().ListView.builder(): "
                                  "appointment = $score");
                                // Filter out any appointment that isn't for the specified date.
                                if (score.scoretDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                  return Container(height : 0);
                                }
                                print("## ScoreList._showScores().ListView.builder(): "
                                  "INCLUDING score = $score");
                                // If the score has a time, format it for display.
                                String scoretTime = "";
                                if (score.scoreTime != null) {
                                  List timeParts = score.scoreTime.split(",");
                                  TimeOfDay at = TimeOfDay(
                                    hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
                                  );
                                  scoretTime = " (${at.format(inContext)})";
                                }
                                // Return a widget for the score since it's for the correct date.
                                return Slidable(
                                  actionPane: SlidableDrawerActionPane(),
                                  actionExtentRatio : .25,
                                  child : Container(
                                  margin : EdgeInsets.only(bottom : 8),
                                    color : Colors.grey.shade300,
                                    child : ListTile(
                                      title : Text("${score.title}$scoretTime"),
                                      subtitle : score.description == null ?
                                        null : Text("${score.description}"),
                                      // Edit existing score.
                                      onTap : () async { _editScore(inContext, score); }
                                    )
                                  ),
                                  secondaryActions : [
                                    IconSlideAction(
                                      caption : "Delete",
                                      color : Colors.red,
                                      icon : Icons.delete,
                                      onTap : () => _deleteScore(inBuildContext, score)
                                    )
                                  ]
                                ); /* End Slidable. */
                              } /* End itemBuilder. */
                            ) /* End ListView.builder. */
                          ) /* End Expanded. */
                        ] /* End Column.children. */
                      ) /* End Column. */
                    ) /* End GestureDetector. */
                  ) /* End Padding. */
                ) /* End Container. */
              ); /* End Scaffold. */
            } /* End ScopedModel.builder. */
          ) /* End ScopedModelDescendant. */
        ); /* End ScopedModel(). */
      } /* End dialog.builder. */
    ); /* End showModalBottomSheet(). */

  } /* End _showAppointments(). */


  /// Handle taps on an score to trigger editing.
  ///
  /// @param inContext     The BuildContext of the parent widget.
  /// @param inScore       The Score being edited.
  void _editScore(BuildContext inContext, Score inScore) async {

    print("## ScoreList._editScore(): inScore = $inScore");

    // Get the data from the database and send to the edit view.
    scoreModel.entityBeingEdited = await ScoresDBWorker.db.get(inScore.id);
    // Parse out the apptDate and apptTime, if any, and set them in the model
    // for display.
    if (scoreModel.entityBeingEdited.scoretDate == null) {
      scoreModel.setChosenDate(null);
    } else {
      List dateParts = scoreModel.entityBeingEdited.scoretDate.split(",");
      DateTime scoretDate = DateTime(
        int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])
      );
      scoreModel.setChosenDate(
        DateFormat.yMMMMd("en_US").format(scoretDate.toLocal())
      );
    }
    if (scoreModel.entityBeingEdited.scoreTime == null) {
      scoreModel.setScoretTime(null);
    } else {
      List timeParts = scoreModel.entityBeingEdited.scoreTime.split(",");
      TimeOfDay scoretTime = TimeOfDay(
        hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
      );
      scoreModel.setScoretTime(scoretTime.format(inContext));
    }
    scoreModel.setStackIndex(1);
  } /* End _editScore. */


  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext     The parent build context.
  /// @param  inScore       The score (potentially) being deleted.
  /// @return               Future.
  Future _deleteScore(BuildContext inContext, Score inScore) async {

    print("## ScoreList._deleteScore(): inScore = $inScore");

    return showDialog(
      context : inContext,
      barrierDismissible : false,
      builder : (BuildContext inAlertContext) {
        return AlertDialog(
          title : Text("Delete Score"),
          content : Text("Are you sure you want to delete ${inScore.title}?"),
          actions : [
            TextButton(child : Text("Cancel"),
              onPressed: () {
                // Just hide dialog.
                Navigator.of(inAlertContext).pop();
              }
            ),
            TextButton(child : Text("Delete"),
              onPressed : () async {
                // Delete from database, then hide dialog, show SnackBar, then re-load data for the list.
                await ScoresDBWorker.db.delete(inScore.id);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    backgroundColor : Colors.red,
                    duration : Duration(seconds : 2),
                    content : Text("Score deleted")
                  )
                );
                // Reload data from database to update list.
                scoreModel.loadData("scores", ScoresDBWorker.db);
              }
            )
          ]
        );
      }
    );

  } /* End _deleteScore(). */


} /* End class. */
