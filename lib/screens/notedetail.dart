import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/utils/helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note  note;
  NoteDetail(this.note, this.appBarTitle);
  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }


}
class NoteDetailState extends State<NoteDetail> {
  static var priorities=['High Priority','Low Priority'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;

  Note note;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  NoteDetailState(this.note ,this.appBarTitle);
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle=Theme.of(context).textTheme.title;
    titleController.text = note.title;
    descriptionController.text = note.description;
    return WillPopScope(
        onWillPop: () {
          movetolastscreen();
        },
      child:Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(Icons.arrow_back),
            onPressed: () {
            movetolastscreen();
            }),
      ),
      body: Padding(
          padding: EdgeInsets.only(top:15,left:10.0,right:10.0),
        child: ListView(
     children: <Widget>[
          ListTile(
            title: DropdownButton(
              items: priorities.map((String dropDownStringItem){
                return DropdownMenuItem<String> (
                  value: dropDownStringItem,
                  child:  Text(dropDownStringItem),
                );
              }).toList(),
              style: textStyle,
              value: getPriorityAsString(note.priority),
              onChanged: (valueSelectedByUser) {
                setState(() {
                  updatePriorityAsInt(valueSelectedByUser);
                });
              },
            ),
          ),
       Padding(
         padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
         child: TextField(
           controller: titleController,
           style: textStyle,
           keyboardType: TextInputType.multiline,
           maxLines: null,
           onChanged: (value){
               updateTitle();
           },
           decoration: InputDecoration(
             labelText: 'Title',
             labelStyle: textStyle,
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(5.0)
             )
           ),
         ),
       ),
    Padding(
    padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
    child: TextField(
    controller: descriptionController,
    style: textStyle,
    keyboardType: TextInputType.multiline,
    maxLines: null,
    onChanged: (value){
         updateDescription();
    },
    decoration: InputDecoration(
    labelText: 'Description',
    labelStyle: textStyle,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5.0)
    )
    ),
    ),
    ),
    Padding(
    padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
    child: Row(
    children: <Widget>[
      Expanded(
    child: RaisedButton(
    color: Theme.of(context).primaryColorDark,
    textColor: Theme.of(context).primaryColorLight,
    child: Text(
    'Save',
    textScaleFactor: 1.5,
    ),
    onPressed: (){
      setState(() {
         _save();
      });
    },
    ),
    ),
    Container(
    width: 5.0),
    Expanded(
    child: RaisedButton(
    color: Theme.of(context).primaryColorDark,
    textColor: Theme.of(context).primaryColorLight,
    child: Text(
    'Delete',
    textScaleFactor: 1.5,
    ),
    onPressed: (){
    setState(() {
         _delete();
    });
    },
    ),
    ),
    ],
    ),
    )
        ],
        ),
      ),
    ));
  }
  void movetolastscreen() {
    Navigator.pop(context, true);
  }
  void updatePriorityAsInt(String value) {
    switch(value) {
      case 'High Priority':
        note.priority = 1;
        break;
      case 'Low Priority':
        note.priority = 2;
        break;
    }
  }
  String getPriorityAsString(int value) {
    String priority;
    switch(value) {
      case 1:
        priority = priorities[0];
        break;
      case 2:
        priority = priorities[1];
        break;
    }
    return priority;
  }
  void updateTitle() {
    note.title = titleController.text;

  }
  void updateDescription() {
    note.description = descriptionController.text;
  }
  void _save() async {
    movetolastscreen();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      result = await helper.updateNote(note);
    } else {
      result = await helper.insertNote(note);
    }
    if (result != 0) {
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem in Saving Note');
    }
  }
  void _delete() async {
    movetolastscreen();
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured While Deleting Note');
    }
  }
  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
      builder: (_) => alertDialog
    );
  }
}