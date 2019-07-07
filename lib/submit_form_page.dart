import 'package:flutter/material.dart';
import 'config.dart';
import 'my_question.dart' as myQuestion;

class SubmitFormPage extends StatefulWidget {
  SubmitFormPage();

  @override
  _SubmitFormPageState createState() => _SubmitFormPageState();
}

class _SubmitFormPageState extends State<SubmitFormPage> {
  myQuestion.Form formData;
  var maintenance = myQuestion.Maintenance(campus_id, passwd);
  Map<String, String> filledForm = {};

  _SubmitFormPageState() {
    maintenance.getForm().then((form) {
      if (mounted) {
        setState(() => formData = form);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (formData == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    List<DropdownMenuItem<String>> roomUsageItem = [];
    List<DropdownMenuItem<String>> categoryItem = [];
    List<DropdownMenuItem<String>> blockItem = [];
    List<DropdownMenuItem<String>> wingItem = [];

    formData.roomUsage.forEach((item) =>
        roomUsageItem.add(DropdownMenuItem(child: Text(item), value: item)));
    formData.category.forEach((item) =>
        categoryItem.add(DropdownMenuItem(child: Text(item), value: item)));
    formData.blockID.forEach((item) =>
        blockItem.add(DropdownMenuItem(child: Text(item), value: item)));
    formData.wingID.forEach((item) =>
        wingItem.add(DropdownMenuItem(child: Text(item), value: item)));

    return Column(
      children: <Widget>[
        DropdownButton(
          value: filledForm['roomUsage'],
          items: roomUsageItem,
          hint: Text(
            'Room Usage',
          ),
          onChanged: (selectedVal) =>
              setState(() => filledForm['roomUsage'] = selectedVal),
        ),
        DropdownButton(
          value: filledForm['category'],
          items: categoryItem,
          hint: Text(
            'Problem Category',
          ),
          onChanged: (selectedVal) =>
              setState(() => filledForm['category'] = selectedVal),
        ),
        DropdownButton(
          value: filledForm['blockID'],
          items: blockItem,
          hint: Text(
            'Block',
          ),
          onChanged: (selectedVal) =>
              setState(() => filledForm['blockID'] = selectedVal),
        ),
        DropdownButton(
          value: filledForm['wingID'],
          items: wingItem,
          hint: Text(
            'Wing',
          ),
          onChanged: (selectedVal) =>
              setState(() => filledForm['wingID'] = selectedVal),
        ),
        TextField(
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Room Number'),
        ),
        TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Description')),
        TextField(
          decoration: InputDecoration(
              border: InputBorder.none, hintText: 'Telephone Number'),
        ),
        CheckboxListTile(title: Text('Recurring problem'),
        value: false,)
      ],
    );
  }
}
