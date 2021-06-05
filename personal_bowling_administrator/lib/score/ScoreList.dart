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
/// The Appointments List sub-screen.
/// ********************************************************************************************************************
class ScoreList extends StatelessWidget {

  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## AppointmentssList.build()");

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
            // Add appointment.
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
              body : Column(
              children : [
                Expanded(
                  child : Container(
                    margin : EdgeInsets.symmetric(horizontal : 10),
                    child : CalendarCarousel<Event>(
                      thisMonthDayBorderColor : Colors.grey,
                      daysHaveCircularBorder : false,
                      markedDatesMap : _markedDateMap,
                      onDayPressed : (DateTime inDate, List<Event> inEvents) {
                        _showAppointments(inDate, inContext);
                      }
                    ) /* End CalendarCarousel. */
                  ) /* End Container. */
                ) /* End Expanded. */
              ] /* End Column.children. */
            ) /* End Column. */
          ); /* End Scaffold. */
        } /* End ScopedModelDescendant builder(). */
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Show a bottom sheet to see the appointments for the selected day.
  ///
  /// @param inDate    The date selected.
  /// @param inContext The build context of the parent widget.
  void _showAppointments(DateTime inDate, BuildContext inContext) async {

    print(
      "## AppointmentsList._showAppointments(): inDate = $inDate (${inDate.year},${inDate.month},${inDate.day})"
    );

    print("## AppointmentsList._showAppointments(): appointmentsModel.entityList.length = "
      "${scoreModel.entityList.length}");
    print("## AppointmentsList._showAppointments(): appointmentsModel.entityList = "
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
                                print("## AppointmentsList._showAppointments().ListView.builder(): "
                                  "appointment = $score");
                                // Filter out any appointment that isn't for the specified date.
                                if (score.scoretDate != "${inDate.year},${inDate.month},${inDate.day}") {
                                  return Container(height : 0);
                                }
                                print("## AppointmentsList._showAppointments().ListView.builder(): "
                                  "INCLUDING appointment = $score");
                                // If the appointment has a time, format it for display.
                                String scoretTime = "";
                                if (score.scoretTime != null) {
                                  List timeParts = score.scoretTime.split(",");
                                  TimeOfDay at = TimeOfDay(
                                    hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
                                  );
                                  scoretTime = " (${at.format(inContext)})";
                                }
                                // Return a widget for the appointment since it's for the correct date.
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
                                      // Edit existing appointment.
                                      onTap : () async { _editAppointment(inContext, score); }
                                    )
                                  ),
                                  secondaryActions : [
                                    IconSlideAction(
                                      caption : "Delete",
                                      color : Colors.red,
                                      icon : Icons.delete,
                                      onTap : () => _deleteAppointment(inBuildContext, score)
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


  /// Handle taps on an appointment to trigger editing.
  ///
  /// @param inContext     The BuildContext of the parent widget.
  /// @param inAppointment The Appointment being edited.
  void _editAppointment(BuildContext inContext, Score inAppointment) async {

    print("## AppointmentsList._editAppointment(): inAppointment = $inAppointment");

    // Get the data from the database and send to the edit view.
    scoreModel.entityBeingEdited = await ScoresDBWorker.db.get(inAppointment.id);
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
    if (scoreModel.entityBeingEdited.scoretTime == null) {
      scoreModel.setScoretTime(null);
    } else {
      List timeParts = scoreModel.entityBeingEdited.scoretTime.split(",");
      TimeOfDay scoretTime = TimeOfDay(
        hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1])
      );
      scoreModel.setScoretTime(scoretTime.format(inContext));
    }
    scoreModel.setStackIndex(1);
    Navigator.pop(inContext);

  } /* End _editAppointment. */


  /// Show a dialog requesting delete confirmation.
  ///
  /// @param  inContext     The parent build context.
  /// @param  inAppointment The appointment (potentially) being deleted.
  /// @return               Future.
  Future _deleteAppointment(BuildContext inContext, Score inAppointment) async {

    print("## AppointmentsList._deleteAppointment(): inAppointment = $inAppointment");

    return showDialog(
      context : inContext,
      barrierDismissible : false,
      builder : (BuildContext inAlertContext) {
        return AlertDialog(
          title : Text("Delete Score"),
          content : Text("Are you sure you want to delete ${inAppointment.title}?"),
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
                await ScoresDBWorker.db.delete(inAppointment.id);
                Navigator.of(inAlertContext).pop();
                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    backgroundColor : Colors.red,
                    duration : Duration(seconds : 2),
                    content : Text("Score deleted")
                  )
                );
                // Reload data from database to update list.
                scoreModel.loadData("appointments", ScoresDBWorker.db);
              }
            )
          ]
        );
      }
    );

  } /* End _deleteAppointment(). */


} /* End class. */
