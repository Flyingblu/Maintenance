import 'package:dio/dio.dart';
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
  final _formKey = GlobalKey<FormState>();

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

    return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            FormField<String>(
              builder: (formFieldState) => Column(children: [
                DropdownButton(
                  value: formFieldState.value,
                  items: roomUsageItem,
                  hint: Text(
                    'Room Usage',
                  ),
                  onChanged: (selectedVal) {
                    formFieldState.didChange(selectedVal);
                    setState(() => formFieldState.validate());
                  },
                ),
                formFieldState.hasError
                    ? Text(
                        formFieldState.errorText,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      )
                    : Container()
              ]),
              validator: (selectedValue) {
                if (selectedValue == null)
                  return "Please choose an option";
                else
                  return null;
              },
            ),
            FormField(
              builder: (formFieldState) => Column(children: [
                DropdownButton(
                  value: formFieldState.value,
                  items: categoryItem,
                  hint: Text(
                    'Problem Category',
                  ),
                  onChanged: (selectedVal) {
                    formFieldState.didChange(selectedVal);
                    setState(() => formFieldState.validate());
                  },
                ),
                formFieldState.hasError
                    ? Text(
                        formFieldState.errorText,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      )
                    : Container()
              ]),
              validator: (selectedValue) {
                if (selectedValue == null) {
                  return "Please choose an option";
                } else
                  return null;
              },
            ),
            Row(
              children: <Widget>[
                FormField(
                  builder: (formFieldState) => Column(children: [
                    DropdownButton(
                      value: formFieldState.value,
                      items: blockItem,
                      hint: Text(
                        'Block',
                      ),
                      onChanged: (selectedVal) {
                        formFieldState.didChange(selectedVal);
                        setState(() => formFieldState.validate());
                      },
                    ),
                    formFieldState.hasError
                        ? Text(
                            formFieldState.errorText,
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                          )
                        : Container()
                  ]),
                  validator: (selectedValue) {
                    if (selectedValue == null)
                      return "Please choose an option";
                    else
                      return null;
                  },
                ),
                FormField(
                  builder: (formFieldState) => Column(children: [
                    DropdownButton(
                      value: formFieldState.value,
                      items: wingItem,
                      hint: Text(
                        'Wing',
                      ),
                      onChanged: (selectedVal) {
                        formFieldState.didChange(selectedVal);
                        setState(() => formFieldState.validate());
                      },
                    ),
                    formFieldState.hasError
                        ? Text(
                            formFieldState.errorText,
                            style:
                                TextStyle(color: Colors.red[700], fontSize: 12),
                          )
                        : Container()
                  ]),
                  validator: (selectedValue) {
                    if (selectedValue == null)
                      return "Please choose an option";
                    else
                      return null;
                  },
                )
              ],
            ),
            TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Room Number'),
              validator: (currentValue) {
                if (currentValue.isEmpty)
                  return 'Please fill in room number';
                else
                  return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Description\nUp to 100 characters\n\n'),
              validator: (currentValue) {
                if (currentValue.isEmpty)
                  return 'Please fill in room number';
                else if (currentValue.length > 100)
                  return 'Description should be less than 100 characters';
                else
                  return null;
              },
            ),
            TextField(
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Telephone Number'),
            ),
            CheckboxListTile(
              title: Text('Recurring problem'),
              value: formData.isrecurringProblem,
              onChanged: (checked) {
                setState(() {
                  formData.isrecurringProblem = checked;
                });
                print(formData.isrecurringProblem);
              },
            ),
            RaisedButton(
              onPressed: () {
                _formKey.currentState.validate();
              },
              child: Text('Submit Form'),
            )
          ],
        ));
  }
}
