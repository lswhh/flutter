import "dart:async";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "../utils.dart" as utils;
import "ScoresDBWorker.dart";
import "ScoreModel.dart" show ScoreModel, scoreModel;


/// ********************************************************************************************************************
/// The Appointments Entry sub-screen.
/// ********************************************************************************************************************
class ScoresEntry extends StatelessWidget {


  /// Controllers for TextFields.
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();


  // Key for form.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  /// Constructor.
  ScoresEntry() {

    print("## AppointmentsEntry.constructor");

    // Attach event listeners to controllers to capture entries in model.
    _titleEditingController.addListener(() {
      scoreModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      scoreModel.entityBeingEdited.description = _descriptionEditingController.text;
    });

  } /* End constructor. */


  /// The build() method.
  ///
  /// @param  inContext The BuildContext for this widget.
  /// @return           A Widget.
  Widget build(BuildContext inContext) {

    print("## AppointmentsEntry.build()");

    // Set value of controllers.
    if (scoreModel.entityBeingEdited != null) {
      _titleEditingController.text = scoreModel.entityBeingEdited.title;
      _descriptionEditingController.text = scoreModel.entityBeingEdited.description;
    }

    // Return widget.
    return ScopedModel(
      model : scoreModel,
      child : ScopedModelDescendant<ScoreModel>(
        builder : (BuildContext inContext, Widget inChild, ScoreModel inModel) {
          return Scaffold(
            bottomNavigationBar : Padding(
              padding : EdgeInsets.symmetric(vertical : 0, horizontal : 10),
              child : Row(
                children : [
                  TextButton(
                    child : Text("Cancel"),
                    onPressed : () {
                      // Hide soft keyboard.
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      // Go back to the list view.
                      inModel.setStackIndex(0);
                    }
                  ),
                  Spacer(),
                  TextButton(
                    child : Text("Save"),
                    onPressed : () { _save(inContext, scoreModel); }
                  )
                ]
              )
            ),
            body : Form(
              key : _formKey,
              child : ListView(
                children : [
                  // Title.
                  ListTile(
                    leading : Icon(Icons.subject),
                    title : TextFormField(
                      decoration : InputDecoration(hintText : "Title"),
                      controller : _titleEditingController,
                      validator : (String inValue) {
                        if (inValue.length == 0) { return "Please enter a title"; }
                        return null;
                      }
                    )
                  ),
                  // Description.
                  ListTile(
                    leading : Icon(Icons.description),
                    title : TextFormField(
                      keyboardType : TextInputType.multiline,
                      maxLines : 4,
                      decoration : InputDecoration(hintText : "Description"),
                      controller : _descriptionEditingController
                    )
                  ),
                  // Appointment Date.
                  ListTile(
                    leading : Icon(Icons.today),
                    title : Text("Date"),
                    subtitle : Text(scoreModel.chosenDate == null ? "" : scoreModel.chosenDate),
                    trailing : IconButton(
                      icon : Icon(Icons.edit),
                      color : Colors.blue,
                      onPressed : () async {
                        // Request a date from the user.  If one is returned, store it.
                        String chosenDate = await utils.selectDate(
                          inContext, scoreModel, scoreModel.entityBeingEdited.apptDate
                        );
                        if (chosenDate != null) {
                          scoreModel.entityBeingEdited.apptDate = chosenDate;
                        }
                      }
                    )
                  ),
                  // Appointment Time.
                  ListTile(
                    leading : Icon(Icons.alarm),
                    title : Text("Time"),
                    subtitle : Text(scoreModel.scoretTime == null ? "" : scoreModel.scoretTime),
                    trailing : IconButton(
                      icon : Icon(Icons.edit),
                      color : Colors.blue,
                      onPressed : () => _selectTime(inContext)
                    )
                  )
                ] /* End Column children. */
              ) /* End ListView. */
            ) /* End Form. */
          ); /* End Scaffold. */
        } /* End ScopedModelDescendant builder(). */
      ) /* End ScopedModelDescendant. */
    ); /* End ScopedModel. */

  } /* End build(). */


  /// Function for handling taps on the edit icon for apptDate.
  ///
  /// @param inContext  The BuildContext of the parent Widget.
  /// @return           Future.
  Future _selectTime(BuildContext inContext) async {

    // Default to right now, assuming we're adding an appointment.
    TimeOfDay initialTime = TimeOfDay.now();

    // If editing an appointment, set the initialTime to the current apptTime, if any.
    if (scoreModel.entityBeingEdited.apptTime != null) {
      List timeParts = scoreModel.entityBeingEdited.apptTime.split(",");
      // Create a DateTime using the hours, minutes and a/p from the apptTime.
      initialTime = TimeOfDay(hour : int.parse(timeParts[0]), minute : int.parse(timeParts[1]));
    }

    // Now request the time.
    TimeOfDay picked = await showTimePicker(context : inContext, initialTime : initialTime);

    // If they didn't cancel, update it on the appointment being edited as well as the apptTime field in the model so
    // it shows on the screen.
    if (picked != null) {
      scoreModel.entityBeingEdited.apptTime = "${picked.hour},${picked.minute}";
      scoreModel.setScoretTime(picked.format(inContext));
    }

  } /* End _selectTime(). */


  /// Save this contact to the database.
  ///
  /// @param inContext The BuildContext of the parent widget.
  /// @param inModel   The AppointmentsModel.
  void _save(BuildContext inContext, ScoreModel inModel) async {

      print("## AppointmentsEntry._save()");

      // Abort if form isn't valid.
      if (!_formKey.currentState.validate()) { return; }

      // Creating a new appointment.
      if (inModel.entityBeingEdited.id == null) {

        print("## AppointmentsEntry._save(): Creating: ${inModel.entityBeingEdited}");
        await ScoresDBWorker.db.create(scoreModel.entityBeingEdited);

      // Updating an existing appointment.
      } else {

        print("## AppointmentsEntry._save(): Updating: ${inModel.entityBeingEdited}");
        await ScoresDBWorker.db.update(scoreModel.entityBeingEdited);

      }

      // Reload data from database to update list.
      scoreModel.loadData("appointments", ScoresDBWorker.db);

      // Go back to the list view.
      inModel.setStackIndex(0);
      ScaffoldMessenger.of(inContext).showSnackBar(
          SnackBar(
          backgroundColor : Colors.green,
          duration : Duration(seconds : 2),
          content : Text("Appointment saved")
        )
      );
      // // Show SnackBar.
      // Scaffold.of(inContext).showSnackBar(
      //   SnackBar(
      //     backgroundColor : Colors.green,
      //     duration : Duration(seconds : 2),
      //     content : Text("Appointment saved")
      //   )
      // );

  } /* End _save(). */


} /* End class. */
